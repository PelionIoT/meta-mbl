# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

inherit mbl-uboot-sign

SRCBRANCH = "imx_v2018.03_4.14.78_1.0.0_ga-mbl"
SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/u-boot.git;protocol=https;nobranch=1 \
"
SRC_URI_append_imx8mmevk = "file://0002-imx8mmevk-mbl-set-noenv.patch"

# MBL_UBOOT_VERSION should be updated to match version pointed to by SRCREV
MBL_UBOOT_VERSION = "2018.03"

SRCREV = "e9cb2c6d8a6227a189702ab2cfc7b1273689ddb2"

FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot-imx:"

do_compile_append_imx8mmevk-mbl() {
	# Link device tree to default name for fit image signature verification usage.
	ln -sf ${config}/dts/dt.dtb ${B}/${UBOOT_DTB_BINARY}
}

do_deploy_append() {
    # Fixup the name expected by the incoming imx-boot recipe
    cd ${DEPLOYDIR}/${BOOT_TOOLS}
    install -m 0777 ${B}/${config}/u-boot-nodtb.bin  ${DEPLOYDIR}/${BOOT_TOOLS}/u-boot-nodtb.bin
}

RM_WORK_EXCLUDE_ITEMS += "recipe-sysroot-native"
