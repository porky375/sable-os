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
| `schemas/` | Stable JSON interfaces for packs and snapshots |
| `scripts/` | Build, validation, and developer utilities |
| `docs/` | Architecture, security, testing, roadmap, and AI handoff |

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

The current development machine uses a 160 GiB image on `ExtraStorage`, mounted
at `/run/media/$USER/SABLE_BUILD`. The helper refuses read-only host volumes
rather than forcing Windows-managed filesystems writable.

See [docs/AI_HANDOFF.md](docs/AI_HANDOFF.md) before continuing substantial
implementation.

## Licensing

Project-authored code is licensed under MIT. Package recipes and redistributed
software retain their respective upstream licenses. No Kali branding or
repository is redistributed.
