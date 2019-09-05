# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

require atf-imx6-imx7-mbl_git.inc

PLATFORM = "imx6ul_picopi"

FILESEXTRAPATHS_prepend:="${THISDIR}/files:"

LICENSE_append = " & GPLv2+"
LIC_FILES_CHKSUM_append = " file://README-uboot;md5=030fd86c891b64ce88b7aa3cff0fbd44"

# Indicates to the ATF build it should attempt to build DDR init code
ATF_COMPILE_FLAGS += "BUILD_UBOOT_DRAM_INIT=1"

SRC_URI = " \
    git://github.com/ARM-software/arm-trusted-firmware.git;protocol=https;nobranch=1;name=atf \
    file://0001-pico-copy-warp7-folder-as-it-is.patch \
    file://0002-picopi-Change-name-from-warp7-to-picopi.patch \
    file://0003-pico-change-uart-pinmux-to-enable-serial-console.patch \
    file://0004-pico-add-mmc-io-config.patch \
    file://0005-pico-io_storage-Remove-DTB-from-FIP.patch \
    file://0006-plat-picopi-Rebase-to-latest-master-branch-with-enab.patch \
    file://0007-pico-fix-build-failure-due-to-header-path.patch \
    file://0008-pico-Fixup-header-paths.patch \
    file://0009-picopi-Implement-plat_get_mbedtls_heap.patch \
    file://0010-plat-imx8m-Add-support-for-exeucting-a-TEE.patch \
    file://0011-plat-imx8m-Configure-CAAM-job-rings-master-ID-for-i..patch \
    file://0012-plat-imx8-Add-imx8mm_private.h-to-the-build.patch \
    file://0013-plat-imx8-Add-image-io-storage-logic-for-MBL-TBB-FIP.patch \
    file://0014-plat-imx8mm-Add-initial-defintions-to-facilitate-FIP.patch \
    file://0015-plat-imx8-Add-image-load-logic-for-MBL-TBB-FIP-booti.patch \
    file://0016-plat-imx8mm-Add-in-BL2-with-FIP.patch \
    file://0017-plat-imx8mm-Enable-Trusted-Boot.patch \
    file://0018-plat-imx8m-Set-AIPSTZ-config-for-when-TEE-is-switche.patch \
    file://0019-plat-Add-FIP-offset-to-make-it-fexiable-to-change.patch \
    file://0020-imx7-imx_regs-Define-the-number-of-AIPS-blocks-to-co.patch \
    file://0021-imx7-imx_regs-Remove-AIPS4-defintion.patch \
    file://0022-imx-imx_aips-Iterate-over-number-of-elements-defined.patch \
    file://0023-imx7-imx_io_mux-Rename-common-imx_io_mux-to-imx7-spe.patch \
    file://0024-plat-imx7-imx7_clock-Aggregate-imx7-clocks-into-one-.patch \
    file://0025-imx-imx_wdog-Only-initialize-the-number-of-watchdogs.patch \
    file://0026-imx-imx_io_mux-Remove-unuse-imx_io_mux.h-header.patch \
    file://0027-imx-imx_clock-Remove-unuse-imx_clock.h-header.patch \
    file://0028-plat-imx7-imx6_clock-Add-a-simple-i.MX6-clock-setup.patch \
    file://0029-imx-imx_io_mux-Add-imx_io_muxc_set_pad_select_input.patch \
    file://0030-imx6-imx6ul_picopi-atf_uboot_compat-Add-simple-compa.patch \
    file://0031-imx6-imx6ul_picopi-Add-in-new-imx6ul-picopi-port.patch \
    file://0001-imx-imx6-uboot_ddr_init-Import-u-boot-DDR-init-code.patch \
    file://0002-README-uboot-Include-the-README-file-from-u-boot.patch \
    git://github.com/ARMmbed/mbedtls.git;protocol=https;branch=development;name=mbedtls;destsuffix=mbedtls	\
"
