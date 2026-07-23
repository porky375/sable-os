# Roadmap

## M0: Foundation

- [x] Establish repository structure and project identity.
- [x] Record architecture, safety invariants, and AI handoff.
- [x] Pass local repository validation.
- [x] Configure a writable external build root.
- [x] Publish the initial public GitHub repository.

## M1: Independent Base

- [ ] Pin and review every stage-0 bootstrap input.
- [ ] Build the compiler, glibc, pacman, systemd, and base utilities.
- [ ] Rebuild the base from the project build root.
- [ ] Prove the runtime package closure has no parent-distribution packages.
- [ ] Boot the base root filesystem in QEMU/OVMF.

## M2: Desktop Image

- [ ] Package Linux LTS, Mesa, networking, audio, Bluetooth, and Flatpak.
- [ ] Package pinned Hyprland and the desktop components.
- [ ] Implement event-driven shell integration and settings migrations.
- [ ] Build and boot the live ISO.

## M3: Install And Recover

- [ ] Integrate Calamares storage policy and branding.
- [ ] Support optional LUKS2 and the Btrfs subvolume layout.
- [ ] Install and update Limine entries safely.
- [ ] Verify update snapshots and rollback.
- [ ] Simulate Windows dual boot without partition resizing.

## M4: Alpha

- [ ] Package security-core and optional tool packs.
- [ ] Validate Steam/Proton, GameMode, MangoHud, and fullscreen behavior.
- [ ] Pass QEMU, AMD, and Intel hardware gates.
- [ ] Sign and publish the installable alpha.
- [ ] Begin fortnightly promoted snapshots.
