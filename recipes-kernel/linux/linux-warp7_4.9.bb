# Copyright (C) 2016 NXP Semiconductors
# Released under the MIT license (see COPYING.MIT for the terms)

include recipes-kernel/linux/linux-fslc.inc

DESCRIPTION = "Linux kernel based on lsk \
with additional patches to cover devices specific on WaRP7 board."

DEPENDS += "lzop-native bc-native"

SRCBRANCH = "mbl"
SRCREV = "57911eaae746e7fe6d6b5aeeb1e2ca32aab68b16"
LOCALVERSION = "-${SRCBRANCH}-warp7"

KBUILD_DEFCONFIG_imx7s-warp ?= "warp7_mbl_defconfig"

SRC_URI = "git://git@github.com/ARMmbed/mbl-linux.git;protocol=ssh;branch=${SRCBRANCH}"

COMPATIBLE_MACHINE = "(imx7s-warp)"

do_configure () {
        oe_runmake ${KBUILD_DEFCONFIG_imx7s-warp}
}
