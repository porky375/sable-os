# Architecture

## Trust Boundary

The release unit is a signed repository snapshot, not an individual package
uploaded ad hoc. A snapshot pins the kernel, Hyprland, plugins, desktop shell,
and package database as a tested set. Promotion copies immutable artifacts from
`testing` to `stable`; it never rebuilds during promotion.

## Bootstrap

1. Stage 0 uses a documented host toolchain to build pacman, the compiler
   toolchain, glibc, and the minimal base.
2. Stage 1 creates a Sable build root from those packages.
3. Stage 2 rebuilds the base inside that root and verifies that no parent
   distribution repository or package remains.
4. Stage 3 builds desktop packages, the live ISO, and installer from signed
   Sable repositories only.

Every bootstrap source has an HTTPS origin, immutable revision, cryptographic
hash, upstream signature where available, and license metadata.

## Desktop

`desktopd` owns persistent desktop/workspace state and exposes
`org.sable.Desktop1`. The QuickShell process renders trusted shell surfaces.
The settings application edits versioned settings through `desktopd`.

The Hyprland plugin is intentionally narrow: server-side decorations, snap
preview hooks, and compositor-level input behavior that cannot be implemented
reliably by the shell. It contains no settings storage or package-management
logic.

Games and fullscreen clients bypass shell decorations, opacity, and blur.
Client-side decorated applications retain their native controls.

## Storage

Installed systems use:

- A dedicated FAT32 EFI system partition.
- Optional LUKS2 around the Btrfs system partition.
- `@` for the root system.
- `@home` for user data, excluded from root rollback.
- `@snapshots` for Snapper snapshots.
- `@var_log` for logs that survive root rollback.

Updates create a pre-update snapshot. Limine recovery entries point the
initramfs at a selected root subvolume while retaining two known-good kernel
sets on the EFI partition.
