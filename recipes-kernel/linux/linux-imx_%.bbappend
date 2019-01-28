# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

S = "${WORKDIR}/git"

LINUX_VERSION = "4.14.95"
SRCREV = "38b3f4015b1f354265277603507a576365eeb932"

KBUILD_DEFCONFIG_imx8mmevk-mbl = "imx8mmevk_mbl_defconfig"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/linux.git;protocol=https;nobranch=1"
SRCBRANCH ?= ""
LOCALVERSION = "mbl"

do_preconfigure_prepend() {
	cp ${S}/arch/arm64/configs/${KBUILD_DEFCONFIG} ${WORKDIR}/defconfig
}
