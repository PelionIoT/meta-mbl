# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

DEPENDS += "u-boot-tools-native"

SRCREV_atf = "d079f702fb167d2dbedef4e2ac7ab571268b2949"

inherit mbl-artifact-names

require atf.inc

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
	uboot-mkimage -n ${DEPLOY_DIR_IMAGE}/u-boot-dtb.cfgout -T imximage -e ${ENTRY} -d ${B}/${PLATFORM}/${ATF_BL2_FILENAME} ${B}/${PLATFORM}/${MBL_UNIFIED_BIN}

	# Create signed FIP image.
	oe_runmake ${ATF_COMPILE_FLAGS} BL2=${B}/${PLATFORM}/${ATF_BL2_FILENAME} BL2_AT_EL3=0 fip
}

do_deploy_append() {
	install -D -p -m 0644 ${B}/${PLATFORM}/${FIP_BIN} ${DEPLOYDIR}
}
