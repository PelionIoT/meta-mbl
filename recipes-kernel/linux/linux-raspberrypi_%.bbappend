
DEPENDS += " u-boot-mkimage-native dtc-native "

FILESEXTRAPATHS_prepend := "${THISDIR}/linux-raspberrypi:"
SRC_URI += " file://0001-rpi3-optee-update-DTS.patch"
SRC_URI += " file://kernel.its "

do_configure_prepend() {
    kernel_configure_variable IKCONFIG y
    kernel_configure_variable TEE y
    kernel_configure_variable OPTEE y
}

_generate_signed_kernel_image() {
        echo "Generating kernel FIT image.."
        ln -sf ${WORKDIR}/kernel.its kernel.its
        ln -sf ${B}/arch/arm/boot/zImage zImage
        ln -sf ${B}/arch/arm/boot/dts/bcm2710-rpi-3-b.dtb bcm2710-rpi-3-b.dtb
        uboot-mkimage -f kernel.its -r kernel.itb
}

do_deploy_append() {

        install -d ${D}/boot

        _generate_signed_kernel_image

        install -m 0644 ${B}/kernel.itb ${DEPLOYDIR}

        install -d ${DEPLOYDIR}/fip
        install -m 0644 ${WORKDIR}/kernel.its ${DEPLOYDIR}/fip/
        install -m 0644 ${B}/arch/arm/boot/zImage ${DEPLOYDIR}/fip/
        install -m 0644 ${B}/arch/arm/boot/dts/bcm2710-rpi-3-b.dtb \
			${DEPLOYDIR}/fip/
	install -D -p -m 0644 ${B}/kernel.itb \
		${DEPLOY_DIR_IMAGE}/bcm2835-bootfiles/kernel.itb
}
