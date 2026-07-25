# Bootstrap Developer Image

This directory defines a disposable UEFI virtual-machine disk that boots
through Limine into the Sable Hyprland session.

The image is a stage-0 development aid, not a Sable release. It is seeded from
signed Arch Linux packages while the independent Sable repositories are being
built. The guest identifies itself as `Sable Bootstrap Preview`, and release
tooling must never publish this image.

The preview includes the versioned Sable wallpaper, a guarded Calamares
installer, Firefox, Thunar, Kitty, NetworkManager, PipeWire, Bluetooth,
display and volume controls, screenshots, clipboard integration,
notifications, a lock screen, archive support, and a system monitor. The
`sable` user's password is `sable`; graphical login is automatic and
development sudo remains passwordless.

Build it on the dedicated external workspace:

```bash
export SABLE_BUILD_ROOT=/run/media/$USER/SABLE_BUILD
./scripts/build-dev-image
./scripts/test-dev-image
./scripts/run-dev-image
```

The interactive runner attaches a sparse 32 GiB file as a second virtual disk.
The installer is permitted to write only from inside a VM and no host block
device is exposed. Both the RAM-backed live image and installer target are
lost when the host reboots.

After a successful Calamares run, boot the installed target as the VM's only
disk:

```bash
./scripts/run-installed-image
```

Set `SABLE_RESET_OVMF=1` when a clean installed-VM firmware state is required.
Installed systems use a Sable-themed ReGreet login on Hyprland. The live image
retains its development-only automatic login; Calamares enables `greetd` only
after removing the live account and passwordless sudo.

Validate an installed target without changing it:

```bash
./scripts/test-installed-image
```

The test boots the target with a QEMU snapshot overlay, waits for the
installed-only greeter readiness service, captures its framebuffer, and
rejects a blank render when ImageMagick is available.

The whole-disk path was validated on 2026-07-24: Calamares erased only the
32 GiB regular-file target, created the EFI and Btrfs layout, copied the live
root, removed live credentials, installed Limine, booted the target by itself,
and reached the Sable desktop through the installer-created account.

The automated test requires both `SABLE_GUI_READY` and
`SABLE_FUNCTIONAL_READY`. The latter verifies desktop applications,
NetworkManager, the Sable state service, and its D-Bus registration inside the
guest.

The builder accepts only a regular image file below a build root containing
`.sable-build-volume`. It never accepts or writes a physical block device.
