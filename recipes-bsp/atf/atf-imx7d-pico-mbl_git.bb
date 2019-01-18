# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

require atf.inc

DEPENDS += "u-boot-tools-native"

SRCREV_atf = "4aaa03a1088c04ad39ecd00bcefe9c5192ba982e"

# Notes on uboot.cfgout
# This is a file automatically generated by u-boot when compiling up a pico
# image. uboot.cfgout is a necessary input when generating a .imx image
# To regenerate uboot.cfgout just do
# "make pico-pi-imx7d_defconfig;make u-boot.imx CROSS_COMPILE=your-x-compiler-"
# This uboot.cfgout file will be removed later here because we can use the
# one from u-boot when u-boot is updated.
SRC_URI +="file://u-boot.cfgout.pico;name=uboot.cfgout;"
SRCREV_uboot.cfgout="6bb815da1bc986dc717a59cc6d2552f8"
LICENSE += "& GPL-2.0"
LIC_FILES_CHKSUM += "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

PLATFORM = "picopi"

# We do not compile bl2 and fip.bin here, because we can speicify two raw images in wks file.
MBL_UNIFIED_BIN = "bl2.bin.imx"

ATF_COMPILE_FLAGS += " \
      AARCH32_SP=optee \
      ARCH=aarch32 \
      ARM_ARCH_MAJOR=7 \
      ARM_CORTEX_A7=yes \
      CROSS_COMPILE=${TARGET_PREFIX} \
      NEED_BL2=yes \
      HW_CONFIG=${DEPLOY_DIR_IMAGE}/${KERNEL_DEVICETREE} \
"

do_compile_append() {

    # Get the entry point
    ENTRY=`${HOST_PREFIX}readelf ${B}/${PLATFORM}/bl2/bl2.elf -h | grep "Entry" | awk '{print $4}'`

    # Generate the .imx binary
    uboot-mkimage -n ${WORKDIR}/u-boot.cfgout.pico -T imximage -e ${ENTRY} -d ${B}/${PLATFORM}/bl2.bin ${B}/${PLATFORM}/bl2.bin.imx

    # Create signed FIP image.
    oe_runmake ${ATF_COMPILE_FLAGS} BL2=${B}/${PLATFORM}/bl2.bin BL2_AT_EL3=0 fip
}

do_deploy_append() {
	install -D -p -m 0644 ${B}/${PLATFORM}/${FIP_BIN} ${DEPLOYDIR}
}
