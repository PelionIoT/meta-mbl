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

RDEPENDS_${PN} = "util-linux-findfs util-linux-mount e2fsprogs-e2fsck e2fsprogs-badblocks busybox mbl-watchdog-init"

S = "${WORKDIR}"

export SYS_DEFAULT_DIRS = " \
    /proc \
    /sys \
    /dev \
"

do_install() {
    # Create system defaults directories
    for dir in ${SYS_DEFAULT_DIRS}; do
        bbnote "Creating ${dir} directory"
        mkdir -p ${D}${dir}
    done

    mknod -m 600 ${D}/dev/console c 5 1

    install -m 0755 ${WORKDIR}/initramfs-init-script.sh ${D}/init
}

inherit allarch

FILES_${PN} = "/init /dev/console ${SYS_DEFAULT_DIRS}"

inherit mbl-var-placeholders
MBL_VAR_PLACEHOLDER_FILES = "${D}/init"
