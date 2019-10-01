# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG[eth-dbg-only] = ""
PACKAGECONFIG[dis-passwd-login] = ""

SRC_URI += " file://10-mbl-dropbear.service.conf \
             ${@bb.utils.contains('PACKAGECONFIG','eth-dbg-only','file://dropbear-eth-dbg.socket','',d)} \
             ${@bb.utils.contains('PACKAGECONFIG','dis-passwd-login','file://dropbear-dis-passwd-login.default','',d)} \
           "

FILES_${PN} += " \
    ${sysconfdir}/systemd/system/dropbear@.service.d/10-mbl-dropbear.service.conf \
"


do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/dropbear@.service.d/
    install -m 0644 ${WORKDIR}/10-mbl-dropbear.service.conf ${D}${sysconfdir}/systemd/system/dropbear@.service.d/10-mbl-dropbear-service.conf

    # When 'eth-dbg-only' PACKAGECONFIG is selected we install a dropbear.socket to allow ssh connections
    # only in the MBL_DBG_IFNAME interface.
    if [ ${@bb.utils.contains('PACKAGECONFIG', 'eth-dbg-only', 'true', 'false', d)} = 'true' ]; then
      install -m 0644 ${WORKDIR}/dropbear-eth-dbg.socket ${D}${systemd_unitdir}/system/dropbear.socket
    fi

    if [ ${@bb.utils.contains('PACKAGECONFIG', 'dis-passwd-login', 'true', 'false', d)} = 'true' ]; then
      install -m 0644 ${WORKDIR}/dropbear-dis-passwd-login.default ${D}${sysconfdir}/default/dropbear
    fi
}

MBL_VAR_PLACEHOLDER_FILES = "${@bb.utils.contains('PACKAGECONFIG', 'eth-dbg-only', '${D}${systemd_unitdir}/system/dropbear.socket', '', d)}"
inherit mbl-var-placeholders
