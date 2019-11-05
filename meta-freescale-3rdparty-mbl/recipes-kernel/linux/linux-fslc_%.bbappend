# Based on: recipes-kernel/linux/linux-warp7_4.1.bb
# In open-source project: https://github.com/Freescale/meta-freescale-3rdparty
#
# Original file: Copyright (C) 2016 NXP Semiconductors
# Modifications: Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

inherit mbl-kernel-config
require recipes-kernel/linux/linux-mbl.inc

PV = "${LINUX_VERSION}+git${SRCPV}"
LINUX_VERSION = "4.14.112"
SRCREV = "46d7ce67b4e5bab34e42b4e857a7e0cbe9580998"
SRCREV_imx6ul-des0258-mbl = "83d967e82fe285635be7845c6b578fee2c441996"

KBUILD_DEFCONFIG_imx7s-warp-mbl ?= "warp7_mbl_defconfig"
KBUILD_DEFCONFIG_imx7d-pico-mbl ?= "pico_mbl_mx6_mx7_defconfig"
KBUILD_DEFCONFIG_imx6ul-pico-mbl ?= "pico_mbl_mx6_mx7_defconfig"
KBUILD_DEFCONFIG_imx6ul-des0258-mbl ?= "imx6ul_des0258_defconfig"

FILESEXTRAPATHS_prepend:="${THISDIR}/files:"

SRC_URI = "git://github.com/ARMmbed/linux-mbl.git;protocol=https;nobranch=1 \
           file://0001-menuconfig-check-lxdiaglog.sh-Allow-specification-of.patch \
           file://mqueue-mbl.cfg \
           file://cgroups-mbl.cfg \
           file://namespaces-mbl.cfg \
           file://watchdog-mbl.cfg \
           "
SRC_URI_append_imx6ul-pico-mbl = " file://imx6ul-disable-cpu-idle-mbl.cfg"

LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

# We need to copy and rename the KBUILD_DEFCONFIG because the do_preconfigure
# task defined in fsl-kernel-localversion.bbclass looks for the defconfig at
# ${WORKDIR}/defconfig when it creates the final kernel .config file
do_preconfigure_prepend() {
	cp ${S}/arch/arm/configs/${KBUILD_DEFCONFIG} ${WORKDIR}/defconfig
}

# TO-BE-REMOVED: workaround until the following upstream patch
# gets merged and adapted to warrior-dev branch
# https://patchwork.openembedded.org/patch/161618/
do_clean[depends] += "make-mod-scripts:do_clean"
