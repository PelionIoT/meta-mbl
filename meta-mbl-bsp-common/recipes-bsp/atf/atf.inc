# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT


DESCRIPTION = "ARM Trusted Firmware"

DEPENDS += " openssl-native coreutils-native optee-os u-boot virtual/kernel"

PROVIDES += "virtual/atf"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

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
    file://0032-drivers-imx-mxc_usdhc-Add-enhencement-for-IMX8.patch \
    file://0033-imx8mm-Add-mmc-as-fip-image-storage.patch \
    file://0034-imx8mm-increase-FIP-image-size.patch \
    git://github.com/ARMmbed/mbedtls.git;protocol=https;branch=development;name=mbedtls;destsuffix=mbedtls \
"

# MBL_ATF_VERSION should be updated to match version pointed to by SRCREV
MBL_ATF_VERSION = "2.1"
SRCREV_atf = "89a4d269146c90e944ea36d4afb39b27d82b23e2"
SRCREV_mbedtls = "1ab9b5714852c6810c0a0bfd8c3b5c60a9a15482"

LICENSE = "BSD-3-Clause & Apache-2.0"
LIC_FILES_CHKSUM = "file://license.rst;md5=90153916317c204fade8b8df15739cde \
                    file://${WORKDIR}/mbedtls/apache-2.0.txt;md5=3b83ef96387f14655fc854ddc3c6bd57"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

SRCREV_FORMAT = "atf"
PACKAGE_ARCH = "${MACHINE_ARCH}"
PV = "${MBL_ATF_VERSION}+git${SRCPV}"

# The ATF makefiles don't support parallel make
PARALLEL_MAKE=""

# LDFLAGS is configured in bitbake.conf as linker flags to be passed to CC.
# It sets it to include "-Wl,-O1". The ATF build system inherits LDFLAGS
# from the environment and passes it directly to LD when building BL1,
# in conflict with the bitbake view. This then causes an error message
# in the ATF trace (aarch64-linux-gnu-ld.bfd: unrecognized option '-Wl,-O1').
# This problem is avoided by clearing LDFLAGS.
LDFLAGS[unexport] = "1"


# MBL_FIP_ROM_OFFSET is to configure the FIP image offset on eMMC/SD/etc
# storage. The default offset is 1MB and it can be override in machine.conf.
MBL_FIP_ROM_OFFSET ?= "0x100000"

ATF_COMPILE_FLAGS = "-C ${S} \
      BL32=${DEPLOY_DIR_IMAGE}/optee/tee-header_v2.bin \
      BL32_EXTRA1=${DEPLOY_DIR_IMAGE}/optee/tee-pager_v2.bin \
      BL32_EXTRA2=${DEPLOY_DIR_IMAGE}/optee/tee-pageable_v2.bin \
      BL33=${DEPLOY_DIR_IMAGE}/${UBOOT_IMAGE} \
      BUILD_BASE=${B} \
      BUILD_PLAT=${B}/${PLATFORM} \
      CRASH_REPORTING=1 \
      CRTTOOL=${S}/tools/cert_create/cert_create \
      CRTTOOLPATH=${S}/tools/fiptool \
      GENERATE_COT=1 \
      MBEDTLS_DIR=${WORKDIR}/mbedtls \
      PLAT=${PLATFORM} \
      TRUSTED_BOARD_BOOT=1 \
      USE_TBBR_DEFS=1 \
      FIP_ROM_OFFSET=${MBL_FIP_ROM_OFFSET} \
"

PACKAGECONFIG[silent] = ""
ATF_COMPILE_FLAGS += "${@bb.utils.contains("PACKAGECONFIG", "silent", " LOG_LEVEL=0", " LOG_LEVEL=40", d)}"

# Default name of fip binary from ATF build.
FIP_BIN = "fip.bin"
MBL_UNIFIED_BIN_PATH ?= ""

do_compile[depends] += " virtual/kernel:do_deploy virtual/bootloader:do_deploy optee-os:do_deploy"
do_compile () {
    # Use existing key if provided to create signed FIP image.
    if [ -e "${MBL_ROT_KEY}" ]; then
	mkdir -p ${B}/${PLATFORM}
	cp ${MBL_ROT_KEY} ${B}/${PLATFORM}/rot_key.pem
    fi

   export PATH=${STAGING_DIR_NATIVE}${bindir}/aarch64-linux-gnu/bin:$PATH

   # We build cert_create here prior because we need to change the OPENSSL_DIR for using
   # the lib from openssl-native. And disable build of the cert_create later when building ATF.
   oe_runmake -C ${S}/tools/cert_create \
       PLAT=${PLATFORM} \
       OPENSSL_DIR="${STAGING_DIR_NATIVE}/usr"

   # Due to LDFLAGS is unexported to solve the build fail, we need to
   # manually add the libdir back. As well as changing the LDLIBS to
   # link to the libraries we want.
   export LD_LIBRARY_PATH=${STAGING_DIR_NATIVE}${libdir}:$LD_LIBRARY_PATH
   oe_runmake -C ${S}/tools/fiptool \
      LDLIBS="-lcrypto -L${STAGING_DIR_NATIVE}${libdir}" \
      INCLUDE_PATHS="-I../../include/tools_share -I${STAGING_DIR_NATIVE}${includedir}"

   oe_runmake ${ATF_COMPILE_FLAGS} all
}

inherit deploy

do_deploy() {
    install -d ${DEPLOYDIR}/${MBL_UNIFIED_BIN_PATH}
    install -D -p -m 0644 ${B}/${PLATFORM}/${MBL_UNIFIED_BIN} ${DEPLOYDIR}/${MBL_UNIFIED_BIN_PATH}/${MBL_UNIFIED_BIN}
    install -D -p -m 0644 ${B}/${PLATFORM}/rot_key.pem ${DEPLOYDIR}
}

addtask deploy after do_compile

inherit noinstall
