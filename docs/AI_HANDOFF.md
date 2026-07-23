# AI Handoff

Last updated: 2026-07-23

## Mission

Build `os_name` into an independent, installable Linux desktop distribution.
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
- Source checkout: `~/Projects/os_name`.
- Public repository: `https://github.com/porky375/os_name`.
- Default branch: `main`; implementation changes use `agent/*` branches and
  draft pull requests.
- Root filesystem: Btrfs, approximately 14 GiB free at project creation.
- Candidate build disk: `/dev/sda2`, label `ExtraStorage`, 660 GiB free.
- Blocker: `/dev/sda2` mounted read-only at
  `/run/media/thomash/ExtraStorage`. Do not force it writable. Windows must be
  fully shut down and the NTFS volume repaired before it can host builds.
- Missing host tools at project creation: `archiso`, QEMU, CMake, Calamares,
  and ShellCheck. `sudo` requires interactive authentication.

## Architecture Decisions

- Package manager: pacman/makepkg with project-owned signed repositories.
- Repositories: `os-core`, `os-desktop`, `os-extra`; `testing` and `stable`.
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

- D-Bus service: `org.os_name.Desktop1`
- D-Bus object: `/org/os_name/Desktop1`
- Customization pack schema: `schemas/desktop-pack.schema.json`
- Snapshot schema: `schemas/snapshot.schema.json`
- Project identity source: `config/project.env`

Changing any interface requires a schema-version bump, migration, tests, and
an update to this document.

## Safe Commands

```bash
cd ~/Projects/os_name
./scripts/doctor
./scripts/check
cargo test --workspace
```

Commands that create package, ISO, or VM artifacts must set
`OS_NAME_BUILD_ROOT` to a dedicated writable volume. Never default large builds
to `/home`.

## Next Work

1. Obtain a writable build volume with at least 100 GiB free.
2. Install host dependencies using `scripts/bootstrap-host` after reviewing its
   package list and authenticating `sudo`.
3. Complete the stage-0 package manifest and pin upstream source revisions.
4. Build the first clean-chroot `os-core` package set.
5. Generate an unsigned developer repository, then establish offline release
   signing before any public promotion.
6. Boot the root filesystem under QEMU/OVMF.
7. Replace shell prototype data with live D-Bus events from `desktopd`.
8. Integrate and test Limine snapshot entries.
9. Build the Calamares live ISO and test only on disposable virtual disks.

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
- D-Bus smoke test: registered `org.os_name.Desktop1`, then created, renamed,
  reordered, and listed a workspace successfully.
- Limine rendering smoke test: generated LTS, current, recovery, and Windows
  chainload entries.
- Installer preflight: passed UEFI check and warned about the mounted Windows
  filesystem.
- GitHub Actions PR validation: passed formatting, Clippy, tests, ShellCheck,
  repository checks, and checkout post-processing.

Known blockers:

- Host build dependencies need interactive sudo authentication.
- The large NTFS volume is read-only and must not be forced writable.
- Stage-0 source revisions and hashes are intentionally unpinned.
- The ISO repository URL is intentionally invalid until hosting exists.
- Physical Limine installation intentionally exits before writing anything.
