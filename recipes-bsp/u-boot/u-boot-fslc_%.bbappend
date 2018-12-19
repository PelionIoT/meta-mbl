# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SRCREV_imx7s-warp-mbl = "c9c520b295d65cba77233fff7155e3338f5219c0"
SRCREV_imx7d-pico-mbl = "bfc74dec32951e9596a6d93099e5a0ac8a96a56a"
DEPENDS_append += " mbl-boot-scr"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/u-boot.git;protocol=https;nobranch=1 "

LIC_FILES_CHKSUM = "file://Licenses/README;md5=30503fd321432fc713238f582193b78e"

DEPENDS += "flex-native bison-native"

do_compile_append_imx7s-warp-mbl() {
	ln -snf ${B}/dts/dt.dtb ${B}/${UBOOT_DTB_BINARY}
}
