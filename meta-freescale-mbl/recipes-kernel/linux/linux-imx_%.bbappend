# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_prepend:="${THISDIR}/files:"

S = "${WORKDIR}/git"

PV = "${LINUX_VERSION}+git${SRCPV}"
LINUX_VERSION = "4.14.112"
SRCREV = "345ccb0b8bbe26f1040c4b8d54ed5e2e999e0588"

KBUILD_DEFCONFIG_imx8mmevk-mbl = "imx8mmevk_mbl_defconfig"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/linux.git;protocol=https;nobranch=1 \
           file://0001-menuconfig-check-lxdiaglog.sh-Allow-specification-of.patch \
          "
SRCBRANCH ?= ""
LOCALVERSION = "mbl"

do_preconfigure_prepend() {
	cp ${S}/arch/arm64/configs/${KBUILD_DEFCONFIG} ${WORKDIR}/defconfig
}

# TO-BE-REMOVED: workaround until the following upstream patch
# gets merged and adapted to warrior-dev branch
# https://patchwork.openembedded.org/patch/161618/
do_clean[depends] += "make-mod-scripts:do_clean"
