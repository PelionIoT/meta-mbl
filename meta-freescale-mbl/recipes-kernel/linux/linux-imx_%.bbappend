# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_prepend:="${THISDIR}/files:"

S = "${WORKDIR}/git"

LINUX_VERSION = "4.14.103"
SRCREV = "a71c476381803789482c8897b28c4a4463b11e3b"

KBUILD_DEFCONFIG_imx8mmevk-mbl = "imx8mmevk_mbl_defconfig"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/linux.git;protocol=https;nobranch=1 \
           file://0001-menuconfig-check-lxdiaglog.sh-Allow-specification-of.patch \
          "
SRCBRANCH ?= ""
LOCALVERSION = "mbl"

do_preconfigure_prepend() {
	cp ${S}/arch/arm64/configs/${KBUILD_DEFCONFIG} ${WORKDIR}/defconfig
}
