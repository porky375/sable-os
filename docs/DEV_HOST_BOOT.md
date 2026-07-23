# Development Host Boot

The current CachyOS development host uses Limine 12.5.2 on the Linux EFI
system partition. This is separate from the boot design of an installed Sable
system.

## Current Layout

- Linux ESP: `/dev/nvme0n1p2`, mounted at `/boot/efi`.
- Limine entry: `Boot0006`, `/EFI/limine/BOOTX64.EFI`.
- GRUB fallback: `Boot0000`, `/EFI/cachyos/grubx64.efi`.
- Boot order: Limine first, GRUB second.
- Limine config: `/boot/efi/limine.conf`.
- Default entry: Windows, with a three-second menu.
- Linux artifacts: `/boot/efi/EFI/limine/kernels`.

The menu also provides current and LTS CachyOS entries plus direct GRUB
chainloading. Kernel, microcode, and initramfs paths include BLAKE2b hashes.

## Updates

The Pacman hook at
`/etc/pacman.d/hooks/95-sable-host-limine-sync.hook` runs
`/usr/local/bin/sable-host-limine-sync` after updates to Limine, AMD
microcode, or either CachyOS kernel.

To change the default, edit `/etc/default/sable-host-limine` and set
`limine_default_entry` to `Windows`, `CachyOS`, or `CachyOS LTS`, then run:

```bash
sudo /usr/local/bin/sable-host-limine-sync
```

## Recovery

The firmware boot picker can start the `cachyos` entry directly. From Linux,
request GRUB for only the next boot with:

```bash
sudo efibootmgr -n 0000
```

Restore GRUB as the permanent first entry with:

```bash
sudo efibootmgr -o 0000,0006,0003,0002,0004,0005
```

Recovery material:

- Important Snapper snapshot `136`.
- Full pre-migration ESP archive:
  `/run/media/$USER/SABLE_BUILD/backups/linux-esp-before-limine-20260723.tar`.
- Per-run backups under `/var/lib/sable-host-boot/backups`.

Do not overwrite the separate Windows EFI system partition.
