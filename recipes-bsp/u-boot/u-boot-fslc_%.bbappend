# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SRCREV = "c0c4ee5fce01ec0818c4f27ce029d9b16c8849ad"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/u-boot.git;protocol=https;nobranch=1 "

LIC_FILES_CHKSUM = "file://Licenses/README;md5=30503fd321432fc713238f582193b78e"

DEPENDS += "flex-native bison-native"

do_compile_append_imx7s-warp-mbl() {
	ln -snf ${B}/dts/dt.dtb ${B}/${UBOOT_DTB_BINARY}
}
