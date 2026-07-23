# Testing

## Validation Layers

1. Static checks validate shell, JSON, TOML, YAML, package recipes, and schema
   examples.
2. Unit tests cover desktop state mutations, persistence, schema migrations,
   pack validation, and snapshot metadata.
3. Package tests build in disposable clean roots and inspect dependency closure.
4. ISO tests boot and install under QEMU/OVMF onto disposable image files.
5. Desktop tests run in a nested compositor and exercise window and workspace
   behavior.
6. Hardware gates cover one AMD and one Intel graphics system.

## Destructive-Test Rule

Automated installer tests must reject block devices and accept only regular
files created inside `OS_NAME_BUILD_ROOT`. Test scripts verify the target with
`test -f`, `readlink -f`, and an allowed-root prefix before invoking partition
tools.

## Alpha Acceptance

- Unencrypted and LUKS2 installs boot after an automated virtual install.
- Existing Windows partitions remain byte-for-byte unchanged in dual-boot
  simulation.
- A deliberately broken kernel update can be rolled back from Limine.
- Desktop state survives service and session restarts.
- Fullscreen games are opaque, blur-free, and unobstructed by shell layers.
- Network, audio, Bluetooth, suspend/resume, and Flatpak work on both hardware
  targets.
