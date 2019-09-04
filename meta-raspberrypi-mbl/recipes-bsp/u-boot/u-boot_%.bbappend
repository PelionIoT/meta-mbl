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
		${@bb.utils.contains_any('PACKAGECONFIG','noconsole silent',' file://0003-set-silent-envs.patch','',d)} \
		${@bb.utils.contains('PACKAGECONFIG', 'minimal', '', ' file://enable-random-macaddr-mbl.cfg', d)} \
		${@bb.utils.contains('PACKAGECONFIG', 'minimal', '', ' file://enable-fastboot-mbl.cfg', d)} \
		${@bb.utils.contains('PACKAGECONFIG', 'minimal', ' file://0001-rpi3-disable-PXE-and-DHCP-boot.patch', '', d)} \
"

do_configure_prepend_raspberrypi3-mbl() {
    # change default boot partition
    sed -i 's/setenv devplist 1/setenv devplist ${UBOOT_DEFAULT_BOOT_PARTITION}/' ${S}/include/config_distro_bootcmd.h
}

do_compile_append_raspberrypi3-mbl() {
    # Copy device tree to default name for fit image signature verification usage.
    cp dts/dt.dtb ${UBOOT_DTB_BINARY}
}

do_deploy_append() {
    ln -sf ${UBOOT_NODTB_IMAGE}  ${DEPLOYDIR}/${UBOOT_NODTB_BINARY}
}
