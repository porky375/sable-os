#!/usr/bin/env bash
# shellcheck disable=SC2034
# mkarchiso sources this file and consumes these declarations.

iso_name="sable"
iso_label="SABLE_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Sable contributors"
iso_application="Sable Live Environment"
iso_version="0.1.0"
install_dir="sable"
buildmodes=('iso')
bootmodes=('uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '12')
file_permissions=(
    ["/etc/shadow"]="0:0:400"
    ["/root"]="0:0:750"
)
