# Sable

Sable is an independent x86-64 Linux desktop distribution project. It
integrates upstream Linux components into its own signed pacman repositories,
installer, recovery model, and Wayland desktop.

The first supported target is modern UEFI hardware with AMD or Intel graphics.
The project is in foundation stage: do not install it on a machine containing
important data.

## Design

- Linux LTS by default, with a tested current kernel as an option.
- glibc, systemd, Mesa, NetworkManager, PipeWire, AppArmor, and Btrfs.
- Hyprland with a Sable shell, settings application, and pinned decoration
  plugin.
- Signed pacman repositories promoted from `testing` to `stable`.
- Calamares installer, Limine boot manager, LUKS2 option, and root-only
  snapshot rollback.
- Native system packages and verified Flatpaks for large desktop applications.
- Curated network diagnostics by default; larger security packs are optional.

## Repository Layout

| Path | Purpose |
| --- | --- |
| `packages/` | Native package recipes and metapackages |
| `repo/` | Repository configuration, signing, promotion, and snapshots |
| `iso/` | Live ISO profile and root filesystem overlay |
| `installer/` | Calamares branding, configuration, and safety policy |
| `boot/` | Limine templates and recovery-entry generation |
| `desktop/` | Desktop state service, shell, settings, and compositor plugin |
| `assets/` | Versioned wallpapers and other release artwork |
| `schemas/` | Stable JSON interfaces for packs and snapshots |
| `scripts/` | Build, validation, and developer utilities |
| `docs/` | Architecture, security, testing, roadmap, and AI handoff |
| `ai/` | Multi-model collaboration protocol and command reference |

## Start Here

Run read-only environment checks:

```bash
./scripts/doctor
```

Run repository validation:

```bash
./scripts/check
```

Create a build workspace on a writable volume with at least 100 GiB free:

```bash
./scripts/prepare-build-storage /path/to/writable/data-volume
./scripts/mount-build-storage /path/to/writable/data-volume/sable-build.ext4
```

The current fallback build root is volatile `/dev/shm`; do not reboot while it
contains the only copy of useful artifacts. ExtraStorage is presently
unmounted because its NTFS/FUSE path previously stalled under build I/O. See
[docs/BUILD_STORAGE.md](docs/BUILD_STORAGE.md) for the verified resumable
migration helper and the safer native-Linux-filesystem recommendation.

See [docs/AI_HANDOFF.md](docs/AI_HANDOFF.md) before continuing substantial
implementation.

Models sharing this checkout coordinate work through `./scripts/ai-collab`.
Run `./scripts/ai-collab context` for a current handoff packet and see
[ai/README.md](ai/README.md) for the claim and messaging protocol.

Development-host Limine maintenance and recovery are documented in
[docs/DEV_HOST_BOOT.md](docs/DEV_HOST_BOOT.md).

The disposable stage-0 VM image is documented in
[dev-image/README.md](dev-image/README.md). It boots through Limine into the
Sable graphical session, but remains explicitly non-release until its Arch
bootstrap packages have been rebuilt into Sable repositories.

The default desktop and boot artwork is
`assets/wallpapers/sable-default.png`. The VM start menu includes a guarded
installer preview that targets only the attached disposable virtual disk.

## Licensing

Project-authored code is licensed under MIT. Package recipes and redistributed
software retain their respective upstream licenses. No Kali branding or
repository is redistributed.
