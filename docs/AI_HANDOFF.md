# AI Handoff

Last updated: 2026-07-24

## Mission

Build Sable into an independent, installable Linux desktop distribution.
The runtime must use only project repositories plus explicitly configured
Flatpak remotes. Arch/CachyOS may seed the bootstrap toolchain, but may not
remain in the final dependency closure.

## Current Milestone

M1 independent-base milestone:

- Complete the transitive source and build-dependency closure.
- Build a disposable host-seeded pass, then rebuild it from Sable-built tools.
- Generate the first `sable-core` developer repository.
- Prove the runtime closure contains no parent-distribution packages.
- Boot that independently rebuilt base under QEMU/OVMF.

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
  ShellCheck 0.11.0, EDK2 OVMF 202605, QEMU desktop UI modules, and socat.
- Pre-update Snapper snapshot `133` is marked important; automatic Pacman
  snapshots `134` and `135` bracket the successful host upgrade.
- Development-host boot: Limine `Boot0006` is first, GRUB `Boot0000` remains
  second, and `BootNext` targets Limine. See `docs/DEV_HOST_BOOT.md`.
- Important Snapper snapshot `136` and a full ESP archive were created before
  the Limine migration.
- Bootstrap preview disk:
  `/run/media/$USER/SABLE_BUILD/images/sable-bootstrap.raw`. It has a
  dedicated GPT, FAT32 ESP, Btrfs root, Limine 12.5.2, Linux LTS, Hyprland,
  QuickShell, and the Sable desktop service.
- The preview is seeded exclusively from signed Arch `core` and `extra`
  packages and is labelled `Sable Bootstrap Preview`. It is not releasable or
  independent; its purpose is to validate Sable boot and desktop integration
  while M1 rebuilds the package closure.

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
- Bootstrap dependency audit: `bootstrap/dependencies.toml`
- Bootstrap build order and acceptance gates: `docs/STAGE0_BOOTSTRAP.md`

Changing any interface requires a schema-version bump, migration, tests, and
an update to this document.

## Safe Commands

```bash
cd ~/Projects/sable-os
./scripts/doctor
./scripts/check
cargo test --workspace
```

## Multi-model Coordination

Models sharing this checkout must coordinate through `./scripts/ai-collab`.
The tool stores its atomic local workboard and append-only event log in the
ignored `.sable-ai/` directory.

Before editing, a model must register itself and claim the paths it will
change. Overlapping active claims are rejected. Models may exchange notes,
transfer ownership with an explicit handoff, and mark tasks complete, blocked,
or available. Use `./scripts/ai-collab context` to generate a current context
packet from this handoff, Git state, active claims, and recent events.

The exact command contract and collaboration rules are documented in
`ai/README.md`. Durable architecture decisions and completed-session
validation still belong in this file; `.sable-ai/` is only live coordination
state.

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

1. Finish and review the transitive stage-0 dependency manifest and build
   order, including durable signed-tag verification for forge-hosted sources.
2. Build the temporary compiler and userspace tool passes from the verified
   source cache, recording non-release host-seed provenance.
3. Rebuild the first `sable-core` package set inside a Sable-only clean root.
4. Generate an unsigned developer repository, then establish offline release
   signing before any public promotion.
5. Replace the bootstrap preview's Arch package closure with Sable packages.
6. Replace remaining shell prototype data with live D-Bus events from
   `desktopd`.
7. Integrate and test Limine snapshot entries.
8. Build the Calamares live ISO and test only on disposable virtual disks.

## Handoff Completion Rule

Before ending a substantial work session:

- Run `./scripts/check`.
- Record exact test results and blockers below.
- Mark completed roadmap items in `docs/ROADMAP.md`.
- Leave no process running unless its PID and purpose are recorded.

## Latest Validation

Validation completed on 2026-07-24:

- `./scripts/check`: passed.
- Multi-model collaboration self-test: registration, conflicting claims,
  directed notes, task handoff, completion, and release all passed.
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
- Limine host test: a disposable FAT32 ESP booted the current CachyOS kernel,
  AMD microcode, and initramfs under QEMU/OVMF and reached early userspace.
- Bootstrap source review: `bootstrap/check-sources` now passes with pinned
  revisions and SHA-256 values for the six initial stage-0 targets.
- Bootstrap dependency audit: `bootstrap/check-dependencies` validates a
  four-phase, 60-component closure model. It remains `DRAFT`, with 54
  components unpinned and three explicit frontier subtrees; independence is
  not asserted.
- Stage-0 source cache: all six pinned archives were fetched over HTTPS to the
  external build volume and passed offline SHA-256 verification. The atomic
  provenance lock is at
  `/run/media/$USER/SABLE_BUILD/sources/stage0/sources.lock.json`.
- Host seed provenance: the disposable CachyOS/Arch build seed records 154
  exact package versions and validates its package-set digest at
  `/run/media/$USER/SABLE_BUILD/provenance/host-seed.json`. This seed is
  explicitly non-release and does not establish Sable independence.
- Physical ESP integrity: installed kernels and initramfs files byte-match
  `/boot`; firmware order and Windows/GRUB chainload targets were verified.
- Bootstrap preview: OVMF loaded the fallback Limine EFI executable, displayed
  the branded Sable menu, booted Linux LTS from the ESP, mounted the Btrfs
  root, autologged into Hyprland, started `desktopd` and QuickShell, rendered
  the wallpaper and taskbar, and emitted `SABLE_GUI_READY`.
- Bootstrap preview rebuild: confirmed the FAT32 ESP contains
  `EFI/BOOT/BOOTX64.EFI`, Linux LTS, its initramfs, and the Sable Limine
  configuration; a fresh automated OVMF test reached `SABLE_GUI_READY`.
- Functional preview: the VM now reaches `SABLE_FUNCTIONAL_READY` only after
  Hyprland, QuickShell, NetworkManager, desktopd, its D-Bus name, and the
  expected desktop applications are available.
- Default artwork: `assets/wallpapers/sable-default.png` is a versioned
  1920x1080 Sable wallpaper used by both the desktop and Limine unless a
  developer explicitly sets `SABLE_WALLPAPER`.
- Installer preview: the start menu launches branded Calamares only inside the
  VM. The runner attaches a sparse 32 GiB target, preflight blocks physical
  machines, and the target flow configures Btrfs subvolumes, removes live
  credentials, and installs Limine.
- Installer end-to-end gate: on 2026-07-24 Calamares erased the disposable
  regular-file `/dev/vdb`, created the 1 GiB EFI and 31 GiB Btrfs layout,
  installed the live root, finalized the installer-created user, and reached
  its completion page. The target then booted as QEMU's only disk through the
  Limine fallback loader into Linux LTS; logging in as the created user started
  Hyprland and reached the Sable desktop. `scripts/run-installed-image`
  reproduces the target-only boot. Physical installation, LUKS, interrupted
  installs, simulated Windows preservation, and rollback remain blocked.
- Installed login gate: Calamares finalization now replaces live autologin with
  `greetd` and a monochrome ReGreet session using the Sable wallpaper. A real
  target authenticated the installer-created user and reached Hyprland.
  `scripts/test-installed-image` boots through Limine with a snapshot overlay,
  requires `SABLE_GREETER_READY`, captures the framebuffer, and rejects a
  near-empty render.
- Build storage: `/dev/shm/sable-build` remains the current volatile fallback.
  ExtraStorage and 2TB are unmounted NTFS volumes, and prior sustained I/O
  through the ExtraStorage loop image stalled. `scripts/migrate-build-storage`
  is resumable and checksum-verified, but live migration is on hold pending a
  durable storage choice. See `docs/BUILD_STORAGE.md`.
- Release repository gates: `repo/verify-runtime-closure` rejects parent
  repositories and packages; `repo/verify-repository-signatures` verifies
  package and database signatures. Both selftests run in `scripts/check`, and
  `repo/publish-package` verifies its destination against the signing key
  before reporting publication success.
- Automated framebuffer captures:
  `/run/media/$USER/SABLE_BUILD/images/sable-limine.png` and
  `/run/media/$USER/SABLE_BUILD/images/sable-desktop.png`.

Known blockers:

- The ISO repository URL is intentionally invalid until hosting exists.
- The bootable preview contains signed Arch bootstrap packages and therefore
  cannot be promoted as an independent Sable build.
