# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

INITRAMFS_IMAGE = "mbl-console-image-initramfs"

FILESEXTRAPATHS_prepend:="${THISDIR}/files:${THISDIR}/linux-raspberrypi:"

SRC_URI += "file://*-mbl.cfg \
"
SRC_URI += "file://0001-rpi3-optee-update-DTS.patch \
"

# LOADADDR is 0x00080000 by default. But we need to put FIP between
# 0x00020000 ~ 0x00200000. Thus we move kernel to another address.
KERNEL_EXTRA_ARGS += " LOADADDR=0x04000000 "

do_configure_prepend() { 
    ${S}/scripts/kconfig/merge_config.sh -m -O ${B} ${B}/.config ${WORKDIR}/*-mbl.cfg    
}
