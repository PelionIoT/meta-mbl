# Based on: meta-initramfs/recipes-bsp/initrdscripts/initramfs-debug_1.0.bb
# In open-source project: http://git.openembedded.org/meta-openembedded
#
# Original file: No copyright notice was included
# Modifications: Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "mbl initramfs image init script"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
SRC_URI = "file://initramfs-init-script.sh"

S = "${WORKDIR}"

do_install() {
        install -m 0755 ${WORKDIR}/initramfs-init-script.sh ${D}/init

        # Fetch verity rootfs root hash public key
        install -m 0644 ${VERITY_KEYS_DIR}/${VERITY_ROOTFS_ROOT_HASH_PUBLIC_KEY_NAME} ${D}/${VERITY_ROOTFS_ROOT_HASH_PUBLIC_KEY_NAME}
}

inherit allarch

FILES_${PN} += " /init /${VERITY_ROOTFS_ROOT_HASH_PUBLIC_KEY_NAME} "

