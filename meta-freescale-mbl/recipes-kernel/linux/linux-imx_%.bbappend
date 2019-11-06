# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

inherit mbl-kernel-config
require recipes-kernel/linux/linux-mbl.inc

FILESEXTRAPATHS_prepend:="${THISDIR}/files:"

S = "${WORKDIR}/git"

PV = "${LINUX_VERSION}+git${SRCPV}"
LINUX_VERSION = "4.14.112"
SRCREV = "2e56e2ce9e3296e46dd74c5c01f4ee14a0f4059a"

KBUILD_DEFCONFIG_imx8mmevk-mbl = "imx8mmevk_mbl_defconfig"

SRC_URI = "git://git@github.com/ARMmbed/linux-mbl.git;protocol=ssh;nobranch=1 \
           file://0001-menuconfig-check-lxdiaglog.sh-Allow-specification-of.patch \
           file://watchdog-mbl.cfg \
          "
SRCBRANCH ?= ""
LOCALVERSION = "mbl"

# We need to copy and rename the KBUILD_DEFCONFIG because the do_preconfigure
# task defined in fsl-kernel-localversion.bbclass looks for the defconfig at
# ${WORKDIR}/defconfig when it creates the final kernel .config file
do_preconfigure_prepend() {
	cp ${S}/arch/arm64/configs/${KBUILD_DEFCONFIG} ${WORKDIR}/defconfig
}

# TO-BE-REMOVED: workaround until the following upstream patch
# gets merged and adapted to warrior-dev branch
# https://patchwork.openembedded.org/patch/161618/
do_clean[depends] += "make-mod-scripts:do_clean"
