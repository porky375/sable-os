# Roadmap

## M0: Foundation

- [x] Establish repository structure and project identity.
- [x] Record architecture, safety invariants, and AI handoff.
- [x] Pass local repository validation.
- [x] Configure a writable external build root.
- [x] Publish the initial public GitHub repository.
- [x] Boot a non-release bootstrap preview through Limine into the Sable GUI.

## M1: Independent Base

- [x] Pin and review the six initial stage-0 target inputs.
- [x] Enumerate the transitive bootstrap closure and two-pass build order.
- [ ] Pin and review every transitive stage-0 input.
- [x] Fetch and verify the currently pinned source cache with provenance metadata.
- [x] Record and verify the disposable host seed package closure.
- [ ] Build the compiler, glibc, pacman, systemd, and base utilities.
- [ ] Rebuild the base from the project build root.
- [ ] Prove the runtime package closure has no parent-distribution packages.
- [ ] Boot the base root filesystem in QEMU/OVMF.

## M2: Desktop Image

- [ ] Package Linux LTS, Mesa, networking, audio, Bluetooth, and Flatpak.
- [ ] Package pinned Hyprland and the desktop components.
- [ ] Implement event-driven shell integration and settings migrations.
- [x] Add the versioned default desktop and boot wallpaper.
- [ ] Build and boot the live ISO.

## M3: Install And Recover

- [x] Integrate guarded Calamares storage policy and branding.
- [x] Boot the branded, physical-disk-blocked installer preview in the VM.
- [x] Verify the unencrypted Btrfs subvolume layout and installed desktop boot.
- [x] Add and automatically verify the installed graphical login.
- [ ] Support optional LUKS2.
- [x] Install Limine into a disposable VM target and boot it independently.
- [ ] Update Limine entries safely across kernel upgrades.
- [ ] Verify update snapshots and rollback.
- [ ] Simulate Windows dual boot without partition resizing.

## M4: Alpha

- [ ] Package security-core and optional tool packs.
- [ ] Validate Steam/Proton, GameMode, MangoHud, and fullscreen behavior.
- [ ] Pass QEMU, AMD, and Intel hardware gates.
- [ ] Sign and publish the installable alpha.
- [x] Gate package publication on repository signatures and parent-repository closure policy.
- [ ] Begin fortnightly promoted snapshots.
