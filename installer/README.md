# Installer

This directory contains Sable's branded Calamares installer preview. It is
functional only inside the disposable development VM and is not ready for
physical disks.

The preview currently provides:

- Whole-disk, existing-free-space, and expert partitioning.
- A 1 GiB EFI system partition and Btrfs by default.
- Separate `@`, `@home`, `@snapshots`, and `@var_log` subvolumes.
- Removal of the live account and passwordless live-session sudo.
- Limine fallback installation with normal and recovery entries.
- Optional Windows chainloading when its EFI loader is present.

Automatic shrinking is deliberately disabled. The alpha may use an entire
disk, existing unallocated space, or expert manual partitioning.

`installer-preflight` requires the preview marker, UEFI, virtualization, and a
second disk. `scripts/run-dev-image` attaches a sparse 32 GiB disposable target
at `images/sable-installer-target.raw`. No host block device is passed through
to the VM.

Before enabling physical installation:

1. Test cancelled and interrupted installs in QEMU; successful and injected
   failure paths have been validated on regular-file targets.
2. Verify encrypted-root boot and then enable LUKS in the UI.
3. Verify byte-for-byte preservation of simulated Windows partitions.
4. Test recovery entries and rollback from the installed target.
5. Review every command that runs inside the target root.
