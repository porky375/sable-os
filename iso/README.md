# Live ISO

The profile currently uses archiso's supported UEFI systemd-boot path to
bootstrap the live environment. The installed system uses Limine. Replacing
the live-media boot path with Limine is an M2 task and must not be represented
as complete until a generated ISO boots on OVMF and both hardware targets.

The profile intentionally contains no Arch or CachyOS repository. It cannot
build until the independent repositories contain every listed package and the
placeholder repository URL is replaced.
