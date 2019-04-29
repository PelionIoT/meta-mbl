# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "Systemd network related files"
DESCRIPTION = "This recipe provides a package to setup the hostname and the configura all \
network interfaces with link local addressing."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://mbl-hostname.sh \
           file://mbl-hostname.service \
           file://10-mbl.network \
           file://ssh.dnssd \
           file://mdns.conf \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "mbl-hostname.service"

do_install() {
    install -d ${D}/opt/arm/
    install -m 0744 ${WORKDIR}/mbl-hostname.sh ${D}/opt/arm/mbl-hostname.sh

    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/mbl-hostname.service ${D}${systemd_unitdir}/system/

    install -d ${D}${systemd_unitdir}/network/
    install -m 0644 ${WORKDIR}/10-mbl.network ${D}${systemd_unitdir}/network/

    install -d ${D}${sysconfdir}/systemd/resolved.conf.d/
    install -m 0644 ${WORKDIR}/mdns.conf ${D}${sysconfdir}/systemd/resolved.conf.d/

    install -d ${D}${sysconfdir}/systemd/dnssd/
    install -m 0644 ${WORKDIR}/ssh.dnssd ${D}${sysconfdir}/systemd/dnssd/
}

FILES_${PN} = " \
        /opt/arm/mbl-hostname.sh \
        ${systemd_unitdir}/network/10-mbl.network \
        ${sysconfdir}/systemd/resolved.conf.d/mdns.conf \
        ${sysconfdir}/systemd/dnssd/ssh.dnssd \
"

MBL_VAR_PLACEHOLDER_FILES = "${D}/opt/arm/mbl-hostname.sh"
inherit mbl-var-placeholders
