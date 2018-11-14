# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_prepend := "${THISDIR}/optee-client:"
SRC_URI += "file://init.d.optee"
SRC_URI += "file://0001-Fix-for-teec_trace.c-snprintf-Werror-format-truncati.patch"

inherit update-rc.d

do_install_append() {
        install -d ${D}${sysconfdir}/init.d
        install -m 0755 ${WORKDIR}/init.d.optee ${D}${sysconfdir}/init.d/init.d.optee
}

INITSCRIPT_NAME = "init.d.optee"
INITSCRIPT_PARAMS = "defaults"
