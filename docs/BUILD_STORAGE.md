# Build Storage

Last updated: 2026-07-24

Owner: `claude` (task `persistent-build-storage`, handed off by `codex`).

Sable builds are large and must never default to `/home`. This document
describes the persistent build-storage model, the migration off volatile RAM,
and the NTFS hazard that motivated hardening.

## Why not `/dev/shm`

When the ExtraStorage NTFS mount stalled under heavy build I/O, the workspace
fell back to `/dev/shm/sable-build`. `/dev/shm` is **tmpfs — volatile RAM**:

- it is lost on reboot, so no build state is durable;
- it competes with process memory (this host has 30 GiB RAM; a 7.5 GiB
  workspace already consumed a large share);
- it cannot hold a full toolchain + package build closure.

`/dev/shm` is acceptable only as a short-lived scratch fallback. Persistent
work must live on a real disk.

## Host storage reality (2026-07-24)

| Device | Size | FS | Role | Usable for builds? |
|--------|------|----|------|--------------------|
| `nvme0n1p1` → `/home` | 232 GiB | btrfs | system | No — ~6 GiB free |
| `sda2` `ExtraStorage` | 931 GiB | NTFS | data | Yes (designated build disk) |
| `sdb2` `2TB` | 1.8 TiB | NTFS | **Windows C:** (slow BX500) | No — off-limits, degraded QLC |

There is no unpartitioned space and no native Linux data partition, and
automation must never partition, format, resize, or repair a physical disk.
The only viable persistent host is therefore a **regular image file on
ExtraStorage**.

## The persistent build image model

Build storage is a regular `ext4` image file on a persistent, writable
filesystem, loop-mounted read-write. This keeps every guarantee we need:

- `prepare-build-storage` creates only a regular file (`sable-build.ext4`);
  it never touches a partition or block device.
- `mount-build-storage` loop-mounts that file through udisks (unprivileged)
  and exports `SABLE_BUILD_ROOT` = the mount point.
- Builds run against `SABLE_BUILD_ROOT`; the physical disk is only ever the
  passive host of one large file.

```bash
# once ExtraStorage is mounted read-write at /run/media/$USER/ExtraStorage:
scripts/prepare-build-storage /run/media/$USER/ExtraStorage 160
scripts/mount-build-storage  /run/media/$USER/ExtraStorage/sable-build.ext4
# -> SABLE_BUILD_ROOT=/run/media/$USER/SABLE_BUILD
```

## The NTFS / ntfs-3g hazard

Loop-mounting an ext4 image whose backing file lives on NTFS means every build
write passes through **ntfs-3g (FUSE)**. Under sustained heavy I/O that layer
has entered prolonged uninterruptible (`D` state) I/O on this host, wedging the
build. Mitigations, in order of preference:

1. **Preallocate the image** so it does not grow at runtime.
   `prepare-build-storage` now uses `fallocate` when the host filesystem
   supports it, falling back to a sparse `truncate` only when it does not
   (NTFS). A preallocated backing file avoids fragmentation-driven FUSE thrash.
2. **Mount NTFS cleanly and read-write.** Fully shut down Windows (no fast
   startup / hibernation) before mounting; a dirty NTFS volume mounts
   read-only, which `prepare-build-storage` and `mount-build-storage` detect
   and refuse with a clear message.
3. **Recover a wedged mount** by waiting for I/O to drain, then lazy-unmounting
   the volume (`udisksctl unmount`); never `kill -9` ntfs-3g mid-write.

### Recommended durable fix (out of this task's scope)

An ext4-on-NTFS loop is inherently fragile for sustained builds. The durable
fix is a **native Linux filesystem** for the build root — either free space on
the btrfs `/home` disk, or a dedicated partition created interactively by the
user (never by automation). Tracked as an open item for `codex`/the user.

## Migrating off `/dev/shm`

`migrate-build-storage` performs a **safe, resumable** copy from the tmpfs
workspace to a mounted build image. It needs no privileges (it only rsyncs
between two mounted directories); the privileged, hang-prone step is mounting
the NTFS host, which this tool never performs — if the target is not already a
mounted Sable build image, it prints the exact privileged prerequisites and
stops (exit 3).

```bash
# 1. Preview (default; changes nothing):
SABLE_BUILD_ROOT=/run/media/$USER/SABLE_BUILD scripts/migrate-build-storage

# 2. Perform the resumable migration and checksum-verify it:
SABLE_BUILD_ROOT=/run/media/$USER/SABLE_BUILD scripts/migrate-build-storage --apply

# 3. Only after verifying the target, free the RAM copy:
scripts/migrate-build-storage --apply --reclaim /dev/shm/sable-build /run/media/$USER/SABLE_BUILD
```

Properties:

- **Resumable:** partial transfers are kept (`--partial-dir`); re-running
  continues and repairs any differing file.
- **Verified:** a checksum pass (`rsync -c`) must show zero content
  differences before the migration is reported complete.
- **Non-destructive:** the source is deleted only with `--reclaim`, only after
  verification, and only when it is a `/dev/shm/*` path or a marked build
  volume.

## Safety invariants

- Never partition, format, resize, or repair a physical disk from automation.
- Only ever format a newly created regular image file, after confirming the
  parent filesystem is writable and not read-only.
- Never write to a block device directly; migration writes only into an
  existing mounted directory.
- Never default large builds to `/home`.
- Report status before any operation that requires privileges.
