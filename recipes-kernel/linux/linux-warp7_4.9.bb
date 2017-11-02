# Copyright (C) 2016 NXP Semiconductors
# Released under the MIT license (see COPYING.MIT for the terms)

include recipes-kernel/linux/linux-fslc.inc

DESCRIPTION = "Linux kernel based on lsk \
with additional patches to cover devices specific on WaRP7 board."

DEPENDS += "lzop-native bc-native"

SRCBRANCH = "linaro"
SRCREV = "cb0a3fda3ca591f60b40ac68e21217af44d7f19a"
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

do_install_append() {
        install -d ${D}/boot
        make -C ${S} O=${B} ARCH=$ARCH dtbs || true
        install -m 0644 ${B}/arch/$ARCH/boot/dts/*.dtb ${D}/boot || true
}

ALLOW_EMPTY_kernel-devicetree = "1"
FILES_kernel-devicetree += "/boot/*.dtb"
RDEPENDS_kernel-image_append = " kernel-devicetree"