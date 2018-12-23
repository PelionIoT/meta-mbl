# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

PROVIDES += "virtual/atf"

# This recipe builds the ARM Trusted Firmware for RaspberryPi3.
# - TF-A and OPTEE as 64-bit (aarch64) are built with the aarch64 toolchain
#   because the boot loader of VideoCore4 will boot to 64-bit ARM bootloaders.
#   The TF-A secure monitor changes to 32-bit mode before running U-Boot.
# - The recipe imports mbedtls into the ATF build directory to build libmbedtls.a
#   and incorporated into the firmware.
DEPENDS_append += " linaro-aarch64-toolchain-native "

SRC_URI_append = "git://github.com/ARM-software/arm-trusted-firmware.git;protocol=https;branch=master;name=atf"
SRCREV_atf = "3ba929571517347a12e027c629703ced0db0b255"

require atf.inc

PARALLEL_MAKE=""

PLATFORM = "rpi3"

ATF_COMPILE_FLAGS_append = " \
      CROSS_COMPILE=aarch64-linux-gnu- \
      RPI3_BL33_IN_AARCH32=1 \
      NEED_BL32=yes \
      SPD=opteed \
      fip \
"

MBL_UNIFIED_BIN = "armstub8.bin"
MBL_UNIFIED_BIN_PATH = "bcm2835-bootfiles"

do_compile_prepend_raspberrypi3-mbl() {
    export PATH=${STAGING_DIR_NATIVE}${bindir}/aarch64-linux-gnu/bin:$PATH
}