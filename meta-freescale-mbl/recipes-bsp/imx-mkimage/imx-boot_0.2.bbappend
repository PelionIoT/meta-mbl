# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# This file contains imx8mmevk-mbl BSP changes needed for the current
# (non-standard) form of the BSP. These changes will be removed when
# the BSP adopts the atf-${MACHINE}bb/atf.inc generic code.
do_compile[depends] += " u-boot-imx:do_deploy"
do_compile[depends] += " optee-os:do_deploy"
do_compile[depends] += " atf-${MACHINE}:do_deploy"
do_compile[depends] += " firmware-imx-8m:do_deploy"

DEPENDS += " virtual/atf"
ATF_MACHINE_NAME_mx8mm = "bl2-${MACHINE}.bin"

FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"
SRC_URI += "file://0001-iMX8M-Add-a-FIP-entry-into-the-mkimage-command.patch \
	    file://0002-iMX8M-Del-UBOOT-OPTEE-FDT-entry-into-the-mkimage-command.patch \
	    file://0003-iMX8M-Del-FIP-entry-in-FIT-image.patch \
"

do_compile_prepend() {
    install -m 0644 ${DEPLOY_DIR_IMAGE}/optee/tee.bin ${BOOT_STAGING}
}
