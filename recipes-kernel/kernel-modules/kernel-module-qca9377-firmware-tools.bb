# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${WORKDIR}/LICENSE.BSD-3-Clause;md5=1a8858961a0fa364bc79169ca26815db"

SRC_URI = "file://populate_rootfs_qca.sh \
	   file://LICENSE.BSD-3-Clause"

FILES_${PN} += "populate_rootfs_qca.sh"

do_install() {
    install -d "${D}${sysconfdir}/mbl-firmware.d"
    install -m 0744 "${WORKDIR}/populate_rootfs_qca.sh" "${D}/${sysconfdir}/mbl-firmware.d/populate_rootfs_qca.sh"
}
