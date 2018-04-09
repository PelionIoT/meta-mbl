DEPENDS += "u-boot-mkimage-native dtc-native u-boot "

S = "${WORKDIR}/linux-${PV}"

FILESEXTRAPATHS_append := "${THISDIR}/linux-mainline:"

SRC_URI = " \
	   git://git.linaro.org/landing-teams/working/mbl/linux.git;protocol=https;branch=jun-bpi-staging \
	   file://kernel.its \
          "
PV = "4.14.2+git${SRCPV}"
SRCREV = "9b5bf7cef83e7d9621b9bc12d7a0dbfd68218cf1"

KBUILD_DEFCONFIG_bananapi-zero ?= "bananapi-zero_defconfig"

KERNEL_EXTRA_ARGS += "LOADADDR=${UBOOT_ENTRYPOINT}"

do_preconfigure() {
	mkdir -p ${B}
	echo "" > ${B}/.config
	CONF_SED_SCRIPT=""

	kernel_conf_variable LOCALVERSION "\"${LOCALVERSION}\""
	kernel_conf_variable LOCALVERSION_AUTO y

	sed -e "${CONF_SED_SCRIPT}" < '${S}/arch/arm/configs/${KBUILD_DEFCONFIG_bananapi-zero}' >> '${B}/.config'

	if [ "${SCMVERSION}" = "y" ]; then
		# Add GIT revision to the local version
		head=`git --git-dir=${S}/.git rev-parse --verify --short HEAD 2> /dev/null`
		printf "%s%s" +g $head > ${S}/.scmversion
	fi
}

# Kernel signing data
KERNEL_BPI="kernel.itb"
KERNEL_DTB="sun8i-h2-plus-bananapi-m2-zero.dtb"

#TODO: find a path to hold all kernel stuff and optee
_generate_signed_kernel_image() {
	echo "Generating kernel FIT image.."
	if [ ! -e kernel.its ]
	then
		ln -s ${WORKDIR}/kernel.its kernel.its
	fi
	if [ ! -e zImage ]
	then
		ln -s ${B}/arch/$ARCH/boot/zImage zImage
	fi
	if [ ! -e ${KERNEL_DTB} ]
	then
		ln -s ${B}/arch/$ARCH/boot/dts/${KERNEL_DTB} ${KERNEL_DTB}
	fi
	uboot-mkimage -f kernel.its -K ${KERNEL_DTB} -r kernel.itb;
}

do_install_append() {
        install -d ${D}/boot

	_generate_signed_kernel_image

	install -m 0644 ${B}/${KERNEL_BPI} ${D}/boot
	install -m 0644 ${B}/${KERNEL_BPI} ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${B}/zImage ${D}/boot
	install -m 0644 ${B}/zImage ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${B}/${KERNEL_DTB} ${D}/boot
	install -m 0644 ${B}/${KERNEL_DTB} ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${WORKDIR}/kernel.its ${D}/boot
	install -m 0644 ${WORKDIR}/kernel.its ${DEPLOY_DIR_IMAGE}
}

ALLOW_EMPTY_kernel-devicetree = "1"
