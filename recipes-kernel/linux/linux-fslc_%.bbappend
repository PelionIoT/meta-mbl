# SPDX-License-Identifier: MIT
#
# Copyright (C) 2016 NXP Semiconductors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

SRCREV = "8f2c1f84d9292abf8c865db64aff952d0c7494f5"

KBUILD_DEFCONFIG_imx7s-warp-mbl ?= "warp7_mbl_defconfig"

FILESEXTRAPATHS_prepend:="${THISDIR}/files:"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/linux.git;protocol=https;nobranch=1 \
           file://*-mbl.cfg \
           file://kernel.its \
          "

DEPENDS += " u-boot-mkimage-native dtc-native mbl-console-image-initramfs "

do_deploy[depends] += "mbl-console-image-initramfs:do_image"

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
