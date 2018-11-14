# Based on: recipes-kernel/linux/linux-warp7_4.1.bb
# In open-source project: https://github.com/Freescale/meta-freescale-3rdparty
# 
# Original file: Copyright (C) 2016 NXP Semiconductors
# Modifications: Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SRCREV = "7b95bef8f62d015b172c29a287f825de941db9f7"

KBUILD_DEFCONFIG_imx7s-warp-mbl ?= "warp7_mbl_defconfig"

FILESEXTRAPATHS_prepend:="${THISDIR}/files:"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/linux.git;protocol=https;nobranch=1 \
           file://*-mbl.cfg \
           file://kernel.its \
          "

DEPENDS += " u-boot-mkimage-native dtc-native mbl-console-image-initramfs "

LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

do_preconfigure() {
	mkdir -p ${B}
	echo "" > ${B}/.config
	CONF_SED_SCRIPT=""

	kernel_conf_variable LOCALVERSION "\"${LOCALVERSION}\""
	kernel_conf_variable LOCALVERSION_AUTO y

	sed -e "${CONF_SED_SCRIPT}" < '${S}/arch/arm/configs/${KBUILD_DEFCONFIG_imx7s-warp-mbl}' >> '${B}/.config'

	${S}/scripts/kconfig/merge_config.sh -m -O ${B} ${B}/.config ${WORKDIR}/*-mbl.cfg 

	if [ "${SCMVERSION}" = "y" ]; then
		# Add GIT revision to the local version
		head=`git --git-dir=${S}/.git rev-parse --verify --short HEAD 2> /dev/null`
		printf "%s%s" +g $head > ${S}/.scmversion
	fi
}

do_install_append() {
	# In order to support FIP generation by the do_compile() ATF routine
	# we need to populate the.dtb early
	install -d ${DEPLOY_DIR_IMAGE}/fiptemp
	install ${B}/arch/arm/boot/dts/imx7s-warp.dtb ${DEPLOY_DIR_IMAGE}/fiptemp
}

do_clean_append() {
        fiptemp = "%s/%s" % (d.expand("${DEPLOY_DIR_IMAGE}"), "fiptemp")
        oe.path.remove(fiptemp)

}

_generate_signed_kernel_image() {
        echo "Generating kernel FIT image.."
        ln -sf ${WORKDIR}/kernel.its kernel.its
        ln -sf ${B}/arch/arm/boot/zImage zImage
        ln -sf ${DEPLOY_DIR_IMAGE}/${INITRAMFS_IMAGE_NAME}.cpio.gz mbl-console-image-initramfs-imx7s-warp-mbl.cpio.gz
        uboot-mkimage -f kernel.its -r kernel.itb
}

do_deploy_append() {
        _generate_signed_kernel_image
        install -m 0644 ${B}/kernel.itb ${DEPLOYDIR}
}

INITRAMFS_IMAGE = "mbl-console-image-initramfs"
