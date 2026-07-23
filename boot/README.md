# Boot And Recovery

`render-limine-config` writes configuration to standard output. The installer
must generate it into a temporary file, validate every referenced EFI path,
then atomically replace the installed configuration.

Windows chainloading is added only when
`EFI/Microsoft/Boot/bootmgfw.efi` is found. The installer never modifies the
Windows EFI files.

Recovery entries use immutable snapshot metadata. At least two known-good
kernel and initramfs sets remain under `EFI/os_name`.
