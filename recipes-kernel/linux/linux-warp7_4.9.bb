# Copyright (C) 2016 NXP Semiconductors
# Released under the MIT license (see COPYING.MIT for the terms)

include recipes-kernel/linux/linux-fslc.inc

DESCRIPTION = "Linux kernel based on lsk \
with additional patches to cover devices specific on WaRP7 board."

DEPENDS += "lzop-native bc-native"

SRCBRANCH = "linaro"
SRCREV = "${AUTOREV}"
LOCALVERSION = "-${SRCBRANCH}-warp7"

SRC_URI = "git://git@github.com/ARMmbed/mbl-linux.git;protocol=ssh;branch=${SRCBRANCH} \
           file://defconfig"

COMPATIBLE_MACHINE = "(imx7s-warp)"
