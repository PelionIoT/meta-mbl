# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "Configure systemd watchdog management"
DESCRIPTION = "Configure systemd to manage the hardware watchdog at runtime."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://10-watchdog-mbl.conf"

FILES_${PN} += "${sysconfdir}/systemd/system.conf.d/10-watchdog-mbl.conf"



do_install() {
    install -d ${D}${sysconfdir}/systemd/system.conf.d/
    install -m 0644 ${WORKDIR}/10-watchdog-mbl.conf ${D}${sysconfdir}/systemd/system.conf.d/10-watchdog-mbl.conf
}

MBL_VAR_PLACEHOLDER_FILES = "${D}${sysconfdir}/systemd/system.conf.d/10-watchdog-mbl.conf"

inherit mbl-var-placeholders
