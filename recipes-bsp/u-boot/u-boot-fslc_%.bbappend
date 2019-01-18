# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SRCREV_imx7s-warp-mbl = "c9c520b295d65cba77233fff7155e3338f5219c0"
SRCREV_imx7d-pico-mbl = "bfc74dec32951e9596a6d93099e5a0ac8a96a56a"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/u-boot.git;protocol=https;nobranch=1 "

LIC_FILES_CHKSUM = "file://Licenses/README;md5=30503fd321432fc713238f582193b78e"

DEPENDS += "flex-native bison-native"

do_compile_append_imx7s-warp-mbl() {
	ln -snf ${B}/dts/dt.dtb ${B}/${UBOOT_DTB_BINARY}
}

# This function is temp temporary solution to install u-boot. It will be
# removed when u-boot # is booted by optee-os, instead of SPL, because we
# need u-boot.bin, not u-boot.img in that case.
do_deploy_append_imx7d-pico-mbl() {
	install -D -p -m 0644 ${B}/u-boot.img ${DEPLOYDIR}
}
