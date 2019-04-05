# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"
SRC_URI_append = " file://logrotate.conf "

do_install_append(){
  install -m 0644 ${WORKDIR}/logrotate.conf ${D}${sysconfdir}
}

FILES_${PN} += " \
    /etc/logrotate.conf \
"
