# Copyright (C) 2016 NXP Semiconductors
# Released under the MIT license (see COPYING.MIT for the terms)

include recipes-kernel/linux/linux-fslc.inc

DESCRIPTION = "Linux kernel based on lsk \
with additional patches to cover devices specific on WaRP7 board."

DEPENDS += "lzop-native bc-native"
DEPENDS += "u-boot-mkimage-native u-boot imx7-cst-native warp7-csf-native warp7-keys-native "

SRCBRANCH = "linaro"
SRCREV = "5b6271b196834b7868784c3d0dcabd313847337f"
LOCALVERSION = "-${SRCBRANCH}-warp7"

KBUILD_DEFCONFIG_imx7s-warp ?= "warp7_mbl_defconfig"

SRC_URI = "git://git@github.com/ARMmbed/mbl-linux.git;protocol=ssh;branch=${SRCBRANCH} \
           file://defconfig"

COMPATIBLE_MACHINE = "(imx7s-warp)"

do_preconfigure() {
	mkdir -p ${B}
	echo "" > ${B}/.config
	CONF_SED_SCRIPT=""

	kernel_conf_variable LOCALVERSION "\"${LOCALVERSION}\""
	kernel_conf_variable LOCALVERSION_AUTO y

	sed -e "${CONF_SED_SCRIPT}" < '${S}/arch/arm/configs/${KBUILD_DEFCONFIG_imx7s-warp}' >> '${B}/.config'

	if [ "${SCMVERSION}" = "y" ]; then
		# Add GIT revision to the local version
		head=`git --git-dir=${S}/.git rev-parse --verify --short HEAD 2> /dev/null`
		printf "%s%s" +g $head > ${S}/.scmversion
	fi
}

inherit image_sign_mbl

# Kernel signing data
KERNEL="zImage"
KERNEL_IMX="zImage.imx"
KERNEL_CSF="kernel_sign.csf"
KERNEL_ADDR="CONFIG_LOADADDR"

# DTB signing data
DTB="imx7s-warp.dtb"
DTB_IMX="imx7s-warp.dtb.imx"
DTB_CSF="dtb_sign.csf"
DTB_ADDR="CONFIG_SYS_FDT_ADDR"

# Common
BOARDNAME="warp7"
UBOOT_WARP_CFG="board/warp7/imximage.cfg.cfgtmp"

_generate_signed_kernel_image() {
	image_sign_mbl_binary ${B}/arch/$ARCH/boot ${BOARDNAME} ${KERNEL} ${KERNEL_IMX} ${KERNEL_ADDR} ${KERNEL_CSF} imximage.cfg.cfgtmp;
}

_generate_signed_dtb_image() {
	image_sign_mbl_binary ${B}/arch/$ARCH/boot/dts ${BOARDNAME} ${DTB} ${DTB_IMX} ${DTB_ADDR} ${DTB_CSF} imximage.cfg.cfgtmp;
}


do_install_append() {
        install -d ${D}/boot
        make -C ${S} O=${B} ARCH=$ARCH dtbs || true
        install -m 0644 ${B}/arch/$ARCH/boot/dts/*.dtb ${D}/boot || true

	_generate_signed_kernel_image
	_generate_signed_dtb_image

	install -m 0644 ${B}/arch/$ARCH/boot/${KERNEL_IMX}-signed ${D}/boot
	install -m 0644 ${B}/arch/$ARCH/boot/${KERNEL_IMX}-signed ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${B}/arch/$ARCH/boot/dts/${DTB_IMX}-signed ${D}/boot
	install -m 0644 ${B}/arch/$ARCH/boot/dts/${DTB_IMX}-signed ${DEPLOY_DIR_IMAGE}
}

ALLOW_EMPTY_kernel-devicetree = "1"
FILES_kernel-devicetree += "/boot/*.dtb"
FILES_kernel-devicetree += "/boot/*.dtb.imx-signed"
FILES_kernel-image += "/boot/zImage*"
RDEPENDS_kernel-image_append = " kernel-devicetree"
