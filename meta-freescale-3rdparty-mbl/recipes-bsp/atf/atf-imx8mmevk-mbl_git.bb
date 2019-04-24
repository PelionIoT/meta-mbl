# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT
inherit mbl-artifact-names

DEPENDS += "u-boot-tools-native"

PROVIDES += "imx-atf"
require recipes-bsp/atf/atf.inc

SRCREV = "d40bc61c4a9ebff664408bca9b02656093fc4121"
LIC_FILES_CHKSUM_remove = "file://license.rst;md5=c709b197e22b81ede21109dbffd5f363"
LIC_FILES_CHKSUM_append = "file://license.rst;md5=3b83ef96387f14655fc854ddc3c6bd57"

PLATFORM = "imx8mm"

# SPD= tells ATF to use optee for runtime SPD instead of internal ATF code.
# CROSS_COMPILE points to the necessary cross compiler, something required due to the
#               older codebase we are working with for i.MX8
# GENERATE_COT subtracted because we are not signing the FIP yet
ATF_COMPILE_FLAGS += " SPD=opteed \
                       CROSS_COMPILE=aarch64-oe-linux- "
ATF_COMPILE_FLAGS_remove = " GENERATE_COT=1 "

# This is the name the imx boot tools expects "bl31-imx8mm.bin"
MBL_UNIFIED_BIN="bl31-${PLATFORM}.bin"

do_compile_append() {
	# Create signed FIP image.
	oe_runmake ${ATF_COMPILE_FLAGS} fip

	# Concatonate bl31.bin and FIP into a single image - allowing for the BootROM
	# to load both in one go
	dd if=/dev/zero of=${B}/${PLATFORM}/${MBL_UNIFIED_BIN} bs=1M count=1
	dd if=${B}/${PLATFORM}/bl31.bin of=${B}/${PLATFORM}/${MBL_UNIFIED_BIN}
	dd if=${B}/${PLATFORM}/fip.bin of=${B}/${PLATFORM}/${MBL_UNIFIED_BIN} skip=33 bs=4k oflag=append conv=notrunc
}

do_deploy() {
	install -d ${DEPLOYDIR}/imx-boot-tools
	install -D -p -m 0644 ${B}/${PLATFORM}/${MBL_UNIFIED_BIN} ${DEPLOYDIR}/imx-boot-tools
}
