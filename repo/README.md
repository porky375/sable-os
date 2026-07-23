# Package Repositories

The project publishes three repositories:

- `sable-core`: toolchain, kernel, init, storage, networking, graphics, and release
  configuration.
- `sable-desktop`: Hyprland version set, desktop service, shell, settings, themes,
  and portals.
- `sable-extra`: security packs, gaming support, and optional native software.

Packages are built into `testing`. A release snapshot is signed and tested as a
whole before immutable artifacts are copied to `stable`. Promotion must never
rebuild packages.

Release signing requires `SABLE_SIGNING_KEY` to contain the fingerprint of an
available GPG signing subkey. Never store this value or private keys in Git.
