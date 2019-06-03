# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# MBL_UBOOT_VERSION should be updated to match version pointed to by SRCREV
MBL_UBOOT_VERSION = "2018.11-rc1"

SRCREV = "c0c4ee5fce01ec0818c4f27ce029d9b16c8849ad"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/u-boot.git;protocol=https;nobranch=1 "

LIC_FILES_CHKSUM = "file://Licenses/README;md5=30503fd321432fc713238f582193b78e"

DEPENDS += "flex-native bison-native"

do_compile_append_imx7s-warp-mbl() {
	# Link device tree to default name for fit image signature verification usage.
	ln -snf ${B}/dts/dt.dtb ${B}/${UBOOT_DTB_BINARY}
	# Generate u-boot-dtb.cfgout for board early initlization.
	oe_runmake u-boot-dtb.imx
}

do_deploy_append() {
	install -D -p -m 0644 ${B}/u-boot-dtb.cfgout ${DEPLOYDIR}
}
