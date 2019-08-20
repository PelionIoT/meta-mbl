# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

require atf-imx6-imx7-mbl_git.inc

SRCREV_atf = "c7fc62d3c33bee9c18dcb3351e601fac21d2a5ff"

PLATFORM = "imx6ul_picopi"

FILESEXTRAPATHS_prepend:="${THISDIR}/files:"

LICENSE_append = " & GPLv2+"
LIC_FILES_CHKSUM_append = " file://README-uboot;md5=030fd86c891b64ce88b7aa3cff0fbd44"

# Indicates to the ATF build it should attempt to build DDR init code
ATF_COMPILE_FLAGS += "BUILD_UBOOT_DRAM_INIT=1"

SRC_URI = " \
    git://git.linaro.org/landing-teams/working/mbl/arm-trusted-firmware.git;protocol=https;nobranch=1;name=atf	\
    file://0001-imx-imx6-uboot_ddr_init-Import-u-boot-DDR-init-code.patch					\
    file://0002-README-uboot-Include-the-README-file-from-u-boot.patch						\
    git://github.com/ARMmbed/mbedtls.git;protocol=https;branch=development;name=mbedtls;destsuffix=mbedtls	\
"
