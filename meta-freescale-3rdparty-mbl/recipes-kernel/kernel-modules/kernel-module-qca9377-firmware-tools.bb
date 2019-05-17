# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

SRC_URI = "file://populate_rootfs_qca.sh"

FILES_${PN} += "/opt/arm/populate_rootfs_qca.sh"

do_install() {
    install -d "${D}/opt/arm"
    install -m 0744 "${WORKDIR}/populate_rootfs_qca.sh" "${D}/opt/arm/populate_rootfs_qca.sh"
}
