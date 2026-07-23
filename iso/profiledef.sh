#!/usr/bin/env bash

iso_name="os_name"
iso_label="OS_NAME_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="os_name contributors"
iso_application="os_name Live Environment"
iso_version="0.1.0"
install_dir="os_name"
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
