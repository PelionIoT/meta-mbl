###############################################################################
# Copyright (c) 2018 ARM Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
###############################################################################

INITRAMFS_IMAGE = "mbl-console-image-initramfs"
DEPENDS += " u-boot-mkimage-native dtc-native mbl-console-image-initramfs "

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
        ln -sf ${B}/arch/arm/boot/dts/bcm2710-rpi-3-b-plus.dtb bcm2710-rpi-3-b-plus.dtb
	# link to fixed name that match the name in fit source file.
	ln -sf ${DEPLOY_DIR_IMAGE}/${INITRAMFS_IMAGE_NAME}.cpio.gz mbl-console-image-initramfs-raspberrypi3.cpio.gz
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
        install -m 0644 ${B}/arch/arm/boot/dts/bcm2710-rpi-3-b-plus.dtb \
			${DEPLOYDIR}/fip/
	install -D -p -m 0644 ${B}/kernel.itb \
		${DEPLOY_DIR_IMAGE}/bcm2835-bootfiles/kernel.itb
}
