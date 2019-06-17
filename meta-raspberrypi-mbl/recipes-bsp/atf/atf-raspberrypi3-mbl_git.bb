# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

inherit mbl-artifact-names

require recipes-bsp/atf/atf.inc

# This recipe builds the ARM Trusted Firmware for RaspberryPi3.
# - TF-A and OPTEE as 64-bit (aarch64) are built with the aarch64 toolchain
#   because the boot loader of VideoCore4 will boot to 64-bit ARM bootloaders.
#   The TF-A secure monitor changes to 32-bit mode before running U-Boot.
# - The recipe imports mbedtls into the ATF build directory to build libmbedtls.a
#   and incorporated into the firmware.
DEPENDS += "arm-aarch64-toolchain-native"

# MBL_ATF_VERSION should be updated to match version pointed to by SRCREV
MBL_ATF_VERSION = "2.0"
SRCREV_atf = "c48d02bade88b07fa7f43aa44e5217f68e5d047f"

FILESEXTRAPATHS_prepend := "${THISDIR}/atf-raspberrypi3-mbl:"
SRC_URI_append_raspberrypi3-mbl = " file://0001-rpi3-Use-mmc-driver-to-load-FIP-from-raw-sectors.patch \
"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM_remove = "file://license.rst;md5=c709b197e22b81ede21109dbffd5f363"
LIC_FILES_CHKSUM_append = "file://license.rst;md5=3b83ef96387f14655fc854ddc3c6bd57"

PLATFORM = "rpi3"

ATF_COMPILE_FLAGS += " \
      CROSS_COMPILE=aarch64-linux-gnu- \
      RPI3_BL33_IN_AARCH32=1 \
      NEED_BL32=yes \
      SPD=opteed \
      RPI3_PRELOADED_DTB_BASE=0x03000000 \
      fip \
"

# RPi3 customises MBL_UNIFIED_BIN to be armstub8.bin
MBL_UNIFIED_BIN = "armstub8.bin"
MBL_UNIFIED_BIN_PATH = "bcm2835-bootfiles"

do_compile_prepend_raspberrypi3-mbl() {
    export PATH=${STAGING_DIR_NATIVE}${bindir}/aarch64-linux-gnu/bin:$PATH
}

# This is binary name for part 1 of the raspberrypi3 FIP image, which contains:
# - Trusted Boot Firmware BL2
# - Trusted Boot Firmware BL2 certificate
# - Trusted Key Certificate.
MBL_FIP1_BIN_FILENAME="fip1.bin"

# This is binary name for part 2 of the raspberrypi3 FIP image, which contains:
# - EL3 Runtime Firmware BL31
# - Secure Payload BL32 (Trusted OS)
# - Secure Payload BL32 Extra1 (Trusted OS Extra1)
# - Secure Payload BL32 Extra2 (Trusted OS Extra2)
# - Non-Trusted Firmware BL33
# - Trusted key certificate
# - SoC Firmware key certificate
# - Trusted OS Firmware key certificate
# - Non-Trusted Firmware key certificate
# - Trusted Boot Firmware BL2 certificate
# - SoC Firmware content certificate
# - Trusted OS Firmware content certificate
# - Non-Trusted Firmware content certificate
MBL_FIP2_BIN_FILENAME="fip2.bin"

# The MBL FIP image normally contains the components as documented in the
# comment to MBL_FIP_BIN_FILENAME in mbl-artifact-names. However, on
# raspberrypi3 the FIP image is split into 2 parts:
#
# - fip1.bin: this part contains:
#   - Trusted Boot Firmware BL2
#   - Trusted Boot Firmware BL2 certificate
#   - Trusted Key Certificate.
#   - And fip1.bin is bound with BL1 and stored in the special file
#     armstub8.bin, which is loaded into memory from the SDCard by the
#     Videocore GPU.
# - fip2.bin: this part contains:
#   - EL3 Runtime Firmware BL31
#   - Secure Payload BL32 (Trusted OS)
#   - Secure Payload BL32 Extra1 (Trusted OS Extra1)
#   - Secure Payload BL32 Extra2 (Trusted OS Extra2)
#   - Non-Trusted Firmware BL33
#   - Trusted key certificate
#   - SoC Firmware key certificate
#   - Trusted OS Firmware key certificate
#   - Non-Trusted Firmware key certificate
#   - SoC Firmware content certificate
#   - Trusted OS Firmware content certificate
#   - Non-Trusted Firmware content certificate
do_compile_append() {
    export PATH=${STAGING_DIR_NATIVE}${bindir}/aarch64-linux-gnu/bin:$PATH

    ${S}/tools/${MBL_FIPTOOL_NAME}/${MBL_FIPTOOL_NAME} info \
        ${B}/${PLATFORM}/${MBL_FIP_BIN_FILENAME}

    cp -f ${B}/${PLATFORM}/${MBL_FIP_BIN_FILENAME} ${B}/${PLATFORM}/${MBL_FIP2_BIN_FILENAME}
    ${S}/tools/${MBL_FIPTOOL_NAME}/${MBL_FIPTOOL_NAME} create \
        ${B}/${PLATFORM}/${MBL_FIP1_BIN_FILENAME} \
        --tb-fw ${B}/${PLATFORM}/bl2.bin \
	--tb-fw-cert ${B}/${PLATFORM}/${TRUSTED_BOOT_FW_CERT} \
	--trusted-key-cert ${B}/${PLATFORM}/${TRUSTED_KEY_CERT}
    ${S}/tools/${MBL_FIPTOOL_NAME}/${MBL_FIPTOOL_NAME} remove \
        ${B}/${PLATFORM}/${MBL_FIP2_BIN_FILENAME} \
        --tb-fw \
	--tb-fw-cert
    cat ${B}/${PLATFORM}/bl1_pad.bin ${B}/${PLATFORM}/${MBL_FIP1_BIN_FILENAME} > ${B}/${PLATFORM}/${MBL_UNIFIED_BIN}
}

do_deploy_append() {
    install -p -m 0644 ${B}/${PLATFORM}/${MBL_FIP2_BIN_FILENAME} ${DEPLOYDIR}
}
