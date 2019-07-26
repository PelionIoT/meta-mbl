# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT


SRC_URI += "\
    file://ecryptfs.service \
    file://ecryptfs-init.sh \
    "

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

do_install_append() {
 
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -D -m 0755 ${WORKDIR}/ecryptfs-init.sh ${D}${bindir}/ecryptfs-init.sh
    fi
}
