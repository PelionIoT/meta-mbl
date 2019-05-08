# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://populate_rootfs_qca.sh"

FILES_${PN} += "/opt/arm/populate_rootfs_qca.sh"

do_install() {
    install -d "${D}/opt/arm"
    install -m 0744 "${WORKDIR}/populate_rootfs_qca.sh" "${D}/opt/arm/populate_rootfs_qca.sh"
}
