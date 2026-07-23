# AI Handoff

Last updated: 2026-07-23

## Mission

Build Sable into an independent, installable Linux desktop distribution.
The runtime must use only project repositories plus explicitly configured
Flatpak remotes. Arch/CachyOS may seed the bootstrap toolchain, but may not
remain in the final dependency closure.

## Current Milestone

Foundation milestone:

- Establish the monorepo and stable interfaces.
- Implement a persistent desktop state service.
- Define package, repository, ISO, installer, boot, and test tooling.
- Validate locally without modifying physical partitions or the live desktop.

## Current Environment

- Host: CachyOS, x86-64, Hyprland/Wayland.
- CPU/GPU target available: AMD desktop with Radeon RX 7600 class graphics.
- Source checkout: `~/Projects/sable-os`.
- Public repository: `https://github.com/porky375/sable-os`.
- Default branch: `main`; implementation changes use `agent/*` branches and
  draft pull requests.
- Root filesystem: Btrfs, approximately 14 GiB free at project creation.
- Candidate build disk: `/dev/sda2`, label `ExtraStorage`, 660 GiB free.
- Secondary candidate: `/dev/sdb2`, label `2TB`, 356 GiB free.
- Build workspace: a 160 GiB ext4 image at
  `/run/media/$USER/ExtraStorage/sable-build.ext4`, mounted by UDisks at
  `/run/media/$USER/SABLE_BUILD`.
- Host build tools installed: archiso 88, QEMU 11.0.2, CMake 4.4.0,
  ShellCheck 0.11.0, and EDK2 OVMF 202605.
- Pre-update Snapper snapshot `133` is marked important; automatic Pacman
  snapshots `134` and `135` bracket the successful host upgrade.

## Architecture Decisions

- Package manager: pacman/makepkg with project-owned signed repositories.
- Repositories: `sable-core`, `sable-desktop`, `sable-extra`; `testing` and `stable`.
- Core: glibc, systemd, Linux LTS, Mesa, NetworkManager, PipeWire, Btrfs.
- Desktop: pinned Hyprland, QuickShell/QML shell, Rust state service, Qt/QML
  settings, and a C++ version-pinned decoration plugin.
- Installer: branded Calamares; whole disk, existing free space, or expert
  manual layouts. Never automatically shrink Windows.
- Boot: Limine, two-second default boot, optional Windows chainload, recovery
  submenu.
- Applications: native core plus verified Flatpaks.
- Security: no telemetry, no enabled servers, unprivileged tools, explicit
  elevation.

## Interfaces

- D-Bus service: `org.sable.Desktop1`
- D-Bus object: `/org/sable/Desktop1`
- Customization pack schema: `schemas/desktop-pack.schema.json`
- Snapshot schema: `schemas/snapshot.schema.json`
- Project identity source: `config/project.env`

Changing any interface requires a schema-version bump, migration, tests, and
an update to this document.

## Safe Commands

```bash
cd ~/Projects/sable-os
./scripts/doctor
./scripts/check
cargo test --workspace
```

Commands that create package, ISO, or VM artifacts must set
`SABLE_BUILD_ROOT` to a dedicated writable volume. Never default large builds
to `/home`.

Prepare and mount the build image:

```bash
./scripts/prepare-build-storage /run/media/$USER/ExtraStorage 160
./scripts/mount-build-storage /run/media/$USER/ExtraStorage/sable-build.ext4
```

The first command creates only a regular ext4 image file. It does not resize,
format, or otherwise modify a physical partition.

## Next Work

1. Install host dependencies using `scripts/bootstrap-host` after reviewing its
   package list and authenticating `sudo`.
2. Complete the stage-0 package manifest and pin upstream source revisions.
3. Build the first clean-chroot `sable-core` package set.
4. Generate an unsigned developer repository, then establish offline release
   signing before any public promotion.
5. Boot the root filesystem under QEMU/OVMF.
6. Replace shell prototype data with live D-Bus events from `desktopd`.
7. Integrate and test Limine snapshot entries.
8. Build the Calamares live ISO and test only on disposable virtual disks.

## Handoff Completion Rule

Before ending a substantial work session:

- Run `./scripts/check`.
- Record exact test results and blockers below.
- Mark completed roadmap items in `docs/ROADMAP.md`.
- Leave no process running unless its PID and purpose are recorded.

## Latest Validation

Validation completed on 2026-07-23:

- `./scripts/check`: passed.
- Rust unit tests: 4 passed.
- JSON Schema example tests: 2 passed.
- `cargo clippy --workspace --all-targets -- -D warnings`: passed.
- `qmllint desktop/shell/shell.qml`: passed.
- `qmllint desktop/settings/Main.qml`: passed.
- D-Bus smoke test: registered `org.sable.Desktop1`, then created, renamed,
  reordered, and listed a workspace successfully.
- Limine rendering smoke test: generated LTS, current, recovery, and Windows
  chainload entries.
- Installer preflight: passed UEFI check and warned about the mounted Windows
  filesystem.
- GitHub Actions PR validation: passed formatting, Clippy, tests, ShellCheck,
  repository checks, and checkout post-processing.
- Sable identity migration: no stale `os_name`, `os-name`, old D-Bus, old
  repository, or old package identifiers remain.
- Renamed D-Bus smoke test: `org.sable.Desktop1` successfully created, renamed,
  reordered, and listed a workspace.
- Storage safety test: the preparation helper rejected the read-only 2 TB NTFS
  volume before creating any file.
- Build storage lifecycle: prepared a 160 GiB ext4 image, initialized the
  workspace, detached its loop device, and mounted it again successfully.

Known blockers:

- Host build dependencies need interactive sudo authentication.
- Stage-0 source revisions and hashes are intentionally unpinned.
- The ISO repository URL is intentionally invalid until hosting exists.
- Physical Limine installation intentionally exits before writing anything.
