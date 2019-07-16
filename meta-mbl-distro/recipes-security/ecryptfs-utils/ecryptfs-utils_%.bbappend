# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT


SRC_URI += "\
    file://ecryptfs.service \
    file://ecryptfs-init.sh \
    "

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

#SRC_URI[md5sum] = "83513228984f671930752c3518cac6fd"
#SRC_URI[sha256sum] = "112cb3e37e81a1ecd8e39516725dec0ce55c5f3df6284e0f4cc0f118750a987f"


do_install_append() {
 
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -D -m 0755 ${WORKDIR}/ecryptfs-init.sh ${D}${bindir}/ecryptfs-init.sh
    fi
}

RDEPENDS_${PN} += "bash"
