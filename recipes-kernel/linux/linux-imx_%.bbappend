# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

S = "${WORKDIR}/git"

LINUX_VERSION = "4.14.103"
SRCREV = "dc1c3f7a5fd722997bbc6b0159c087e9114e90ee"

KBUILD_DEFCONFIG_imx8mmevk-mbl = "imx8mmevk_mbl_defconfig"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/linux.git;protocol=https;nobranch=1"
SRCBRANCH ?= ""
LOCALVERSION = "mbl"

do_preconfigure_prepend() {
	cp ${S}/arch/arm64/configs/${KBUILD_DEFCONFIG} ${WORKDIR}/defconfig
}
