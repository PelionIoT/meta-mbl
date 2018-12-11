# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SRCREV = "407a3560f72a3be781cd062b509a7726406a5c6f"
DEPENDS_append += " mbl-boot-scr u-boot-tools-native"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/u-boot.git;protocol=https;nobranch=1 \
           file://dummy.its \
"

LIC_FILES_CHKSUM = "file://Licenses/README;md5=30503fd321432fc713238f582193b78e"

UBOOT_CONFIG[sd] = "warp7_bl33_defconfig,sdcard"

DEPENDS += "flex-native bison-native"

do_compile[depends] += " mbl-boot-scr:do_compile"

do_compile_append_imx7s-warp-mbl() {
	ln -f -s ${WORKDIR}/dummy.its ${B}/dummy.its
	ln -f -s ${DEPLOY_DIR_IMAGE}/mblkey.key ${B}/mblkey.key
	ln -f -s ${DEPLOY_DIR_IMAGE}/mblkey.crt ${B}/mblkey.crt
	uboot-mkimage -f ${WORKDIR}/dummy.its -k ${B} -K ${B}/warp7_bl33_defconfig/dts/dt.dtb -r ${B}/dummy.itb
	cat ${B}/warp7_bl33_defconfig/u-boot-nodtb.bin > ${B}/u-boot.bin
	cat ${B}/warp7_bl33_defconfig/dts/dt.dtb >> ${B}/u-boot.bin
}

do_deploy_append_imx7s-warp-mbl() {

	install -d ${DEPLOYDIR}
	# override u-boot.bin with dtb which contains the pub key
	install -m 0644 ${B}/u-boot.bin ${DEPLOYDIR}
	install -m 0644 ${B}/warp7_bl33_defconfig/u-boot.cfg ${DEPLOYDIR}
}
