# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " file://10-mbl-dropbear.service.conf \
           "

FILES_${PN} += " \
    ${sysconfdir}/systemd/system/dropbear@.service.d/10-mbl-dropbear.service.conf \
"


do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/dropbear@.service.d/
    install -m 0644 ${WORKDIR}/10-mbl-dropbear.service.conf ${D}${sysconfdir}/systemd/system/dropbear@.service.d/10-mbl-dropbear-service.conf
}
