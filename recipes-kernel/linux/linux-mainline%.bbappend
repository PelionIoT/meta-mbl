DEPENDS += "u-boot-mkimage-native dtc-native u-boot optee-os "

S = "${WORKDIR}/linux-${PV}"

FILESEXTRAPATHS_append := "${THISDIR}/linux-mainline:"

SRC_URI = " \
	   git://git.linaro.org/landing-teams/working/mbl/linux.git;protocol=https;branch=linaro-bpi \
	   file://kernel.its \
          "
PV = "4.14.2+git${SRCPV}"
SRCREV = "f3453808638ca98671831cb40457bcf7585a8ee0"

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

#TODO: find a path to hold all kernel stuff and optee
_generate_signed_kernel_image() {
	echo "Generating kernel FIT image.."
	ln -sf ${WORKDIR}/kernel.its kernel.its
	ln -sf ${B}/arch/$ARCH/boot/zImage zImage
	ln -sf ${B}/arch/$ARCH/boot/dts/${KERNEL_DEVICETREE} ${KERNEL_DEVICETREE}
	ln -sf ${DEPLOY_DIR_IMAGE}/optee/tee.bin tee.bin
	uboot-mkimage -f kernel.its -K ${KERNEL_DEVICETREE} -r kernel.itb;
}

do_install_append() {
        install -d ${D}/boot

	_generate_signed_kernel_image

	install -m 0644 ${B}/kernel.itb ${DEPLOY_DIR_IMAGE}
	install -m 0644 ${WORKDIR}/kernel.its ${DEPLOY_DIR_IMAGE}
}

ALLOW_EMPTY_kernel-devicetree = "1"
