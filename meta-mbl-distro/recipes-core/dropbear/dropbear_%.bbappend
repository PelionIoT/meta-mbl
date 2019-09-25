# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG[eth-dbg-only] = ""

SRC_URI += " file://10-mbl-dropbear.service.conf \
             ${@bb.utils.contains('PACKAGECONFIG','eth-dbg-only','file://dropbear-eth-dbg.socket','',d)} \
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
      if grep -q DROPBEAR_EXTRA_ARGS ${D}${sysconfdir}/default/dropbear 2>/dev/null ; then
            # For now we enable root login.
            sed -i '/^DROPBEAR_EXTRA_ARGS=/ s/-w//' ${D}${sysconfdir}/default/dropbear
        fi
    fi
}

MBL_VAR_PLACEHOLDER_FILES = "${@bb.utils.contains('PACKAGECONFIG', 'eth-dbg-only', '${D}${systemd_unitdir}/system/dropbear.socket', '', d)}"
inherit mbl-var-placeholders
