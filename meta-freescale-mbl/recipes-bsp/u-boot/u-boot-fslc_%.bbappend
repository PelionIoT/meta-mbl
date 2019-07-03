# Copyright (c) 2018-2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# MBL_UBOOT_VERSION should be updated to match version pointed to by SRCREV
MBL_UBOOT_VERSION = "2018.11-rc1"

SRCREV = "c0c4ee5fce01ec0818c4f27ce029d9b16c8849ad"
SRCREV_imx7d-pico-mbl = "c72a23701bd9b15dab35e0d43c468ab051739af3"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/u-boot.git;protocol=https;nobranch=1 "
SRC_URI_imx7d-pico-mbl = "git://gitlab.denx.de/u-boot.git"

SRC_URI_append_imx7d-pico-mbl = " file://u-boot-dtb.cfgout"

LIC_FILES_CHKSUM = "file://Licenses/README;md5=30503fd321432fc713238f582193b78e"

DEPENDS += "flex-native bison-native"

do_compile_append_imx7s-warp-mbl() {
	# Link device tree to default name for fit image signature verification usage.
	ln -snf ${B}/dts/dt.dtb ${B}/${UBOOT_DTB_BINARY}
	# Generate u-boot-dtb.cfgout for board early initlization.
	oe_runmake u-boot-dtb.imx
}

DCD_FILE_PATH_imx7s-warp-mbl = "${B}"
DCD_FILE_PATH_imx7d-pico-mbl = "${WORKDIR}"

do_deploy_append() {
	install -D -p -m 0644 ${DCD_FILE_PATH}/u-boot-dtb.cfgout ${DEPLOYDIR}
}
