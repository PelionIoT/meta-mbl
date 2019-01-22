# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SRCREV = "218463f1bd26073cf52884682bbbd3699067e3b3"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/u-boot.git;protocol=https;nobranch=1 "

LIC_FILES_CHKSUM = "file://Licenses/README;md5=30503fd321432fc713238f582193b78e"

DEPENDS += "flex-native bison-native"

do_compile_append_imx7s-warp-mbl() {
	ln -snf ${B}/dts/dt.dtb ${B}/${UBOOT_DTB_BINARY}
}


do_deploy_append_imx7d-pico-mbl() {
	install -D -p -m 0644 ${B}/u-boot-dtb.cfgout ${DEPLOYDIR}/u-boot.cfgout
}

do_deploy_append_imx7s-warp-mbl() {
	install -D -p -m 0644 ${B}/u-boot.cfgout ${DEPLOYDIR}
}
