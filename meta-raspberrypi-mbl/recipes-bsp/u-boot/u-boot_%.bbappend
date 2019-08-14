# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

inherit mbl-uboot-sign

# Don't let meta-raspberrypi's boot script overwrite meta-mbl's
RDEPENDS_${PN}_remove = "rpi-u-boot-scr"
DEPENDS_remove = "rpi-u-boot-scr"

FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot:"
SRC_URI_append_raspberrypi3-mbl = " \
		file://0002-rpi3-Enable-boot-kernel-from-fit-image.patch \
		file://change-text-base-mbl.cfg \
		file://enable-fit-mbl.cfg \
		file://enable-random-macaddr-mbl.cfg \
		file://enable-fastboot.cfg \
"

do_compile_append_raspberrypi3-mbl() {
    # Link device tree to default name for fit image signature verification usage.
    ln -sf dts/dt.dtb ${UBOOT_DTB_BINARY}
}

do_deploy_append() {
    ln -sf ${UBOOT_NODTB_IMAGE}  ${DEPLOYDIR}/${UBOOT_NODTB_BINARY}
}
