# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_prepend := "${THISDIR}/optee-client:"
SRC_URI += "file://init.d.optee"

# Version 3.7.0
SRCREV = "bc0ec8ce1e4dc5ae23f4737ef659338b7cd408fe"

inherit update-rc.d

do_install_prepend() {
	oe_runmake install
	install -d ${S}/out/export/bin
	cp -f ${S}/out/export/usr/sbin/* ${S}/out/export/bin
	install -d ${S}/out/export/lib
	cp -f ${S}/out/export/usr/lib/* ${S}/out/export/lib
	install -d ${S}/out/export/include
	cp -f ${S}/out/export/usr/include/* ${S}/out/export/include
}

do_install_append() {
        install -d ${D}${sysconfdir}/init.d
        install -m 0755 ${WORKDIR}/init.d.optee ${D}${sysconfdir}/init.d/init.d.optee
}

INITSCRIPT_NAME = "init.d.optee"
INITSCRIPT_PARAMS = "defaults"
