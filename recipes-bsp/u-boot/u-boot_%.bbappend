# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Don't let meta-raspberrypi's boot script overwrite meta-mbl's
RDEPENDS_${PN}_remove = "rpi-u-boot-scr"
DEPENDS_remove = "rpi-u-boot-scr"

DEPENDS_append = " u-boot-tools-native mbl-boot-scr"

FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot:"
SRC_URI_append_raspberrypi3-mbl = " file://0100-rpi3-Change-u-boot-loading-address.patch \
		file://0002-rpi3-Enable-boot-kernel-from-fit-image.patch \
		file://dummy.its \
"

do_compile[depends] += "mbl-boot-scr:do_compile"
do_compile_append_rpi() {
	ln -f -s ${WORKDIR}/dummy.its ${B}/dummy.its
	ln -f -s ${DEPLOY_DIR_IMAGE}/mblkey.key ${B}/mblkey.key
	ln -f -s ${DEPLOY_DIR_IMAGE}/mblkey.crt ${B}/mblkey.crt
	uboot-mkimage -f dummy.its -k ${B} -K ${B}/dts/dt.dtb -r ${B}/dummy.itb
	# override u-boot.bin with dtb that containing the pub key
	cat ${B}/u-boot-nodtb.bin > ${B}/u-boot.bin
	cat ${B}/dts/dt.dtb >> ${B}/u-boot.bin
}

do_deploy_append_rpi() {
	install -d ${DEPLOYDIR}/fip
	install -m 0644 ${B}/u-boot.bin ${DEPLOYDIR}/u-boot.bin
	install -m 0644 ${B}/dts/dt.dtb ${DEPLOYDIR}/dt.dtb
	install	-m 0644 ${B}/u-boot-nodtb.bin ${DEPLOYDIR}/u-boot-nodtb.bin
}
