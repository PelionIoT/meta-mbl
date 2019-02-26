# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

DEPENDS += "u-boot-tools-native"

SRCREV_atf = "15f73461e18e4596623182fa8058416c83c055fd"

require atf.inc

PLATFORM_imx7d-pico-mbl = "picopi"
PLATFORM_imx7s-warp-mbl = "warp7"

# We do not compile bl2 and fip.bin here, because we can speicify two raw images in wks file.
MBL_UNIFIED_BIN = "bl2.bin.imx"

ATF_COMPILE_FLAGS += " \
      AARCH32_SP=optee \
      ARCH=aarch32 \
      ARM_ARCH_MAJOR=7 \
      ARM_CORTEX_A7=yes \
      CROSS_COMPILE=${TARGET_PREFIX} \
      NEED_BL2=yes \
"

do_compile_append() {
	# Get the entry point
	ENTRY=`${HOST_PREFIX}readelf ${B}/${PLATFORM}/bl2/bl2.elf -h | grep "Entry" | awk '{print $4}'`

	# Generate the .imx binary
	uboot-mkimage -n ${DEPLOY_DIR_IMAGE}/u-boot.cfgout -T imximage -e ${ENTRY} -d ${B}/${PLATFORM}/bl2.bin ${B}/${PLATFORM}/bl2.bin.imx

	# Create signed FIP image.
	oe_runmake ${ATF_COMPILE_FLAGS} BL2=${B}/${PLATFORM}/bl2.bin BL2_AT_EL3=0 fip
}

do_deploy_append() {
	install -D -p -m 0644 ${B}/${PLATFORM}/${FIP_BIN} ${DEPLOYDIR}
}
