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
           file://ssh.dnssd \
           file://mdns.conf \
           ${@bb.utils.contains('PACKAGECONFIG','all-allow','file://10-mbl.network','',d)} \
           ${@bb.utils.contains('PACKAGECONFIG','eth-dbg-only','file://99-mbl.network','',d)} \
           ${@bb.utils.contains('PACKAGECONFIG','eth-dbg-only','file://10-mbl-eth-dbg.network','',d)} \
           ${@bb.utils.contains('PACKAGECONFIG','eth-dbg-only','file://llmnr.conf','',d)} \
"

PACKAGECONFIG ??= "all-allow"

PACKAGECONFIG[all-allow] = ""
PACKAGECONFIG[eth-dbg-only] = ""

inherit systemd

SYSTEMD_SERVICE_${PN} = "mbl-hostname.service"

do_install() {
    install -d ${D}/opt/arm/
    install -m 0744 ${WORKDIR}/mbl-hostname.sh ${D}/opt/arm/mbl-hostname.sh

    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/mbl-hostname.service ${D}${systemd_unitdir}/system/

    install -d ${D}${systemd_unitdir}/network/
    if [ ${@bb.utils.contains('PACKAGECONFIG', 'all-allow', 'true', 'false', d)} = 'true' ]; then
      install -m 0644 ${WORKDIR}/10-mbl.network ${D}${systemd_unitdir}/network/
    elif [ ${@bb.utils.contains('PACKAGECONFIG', 'eth-dbg-only', 'true', 'false', d)} = 'true' ]; then
      install -m 0644 ${WORKDIR}/99-mbl.network ${D}${systemd_unitdir}/network/
      install -m 0644 ${WORKDIR}/10-mbl-eth-dbg.network ${D}${systemd_unitdir}/network/
    fi

    install -d ${D}${sysconfdir}/systemd/resolved.conf.d/
    install -m 0644 ${WORKDIR}/mdns.conf ${D}${sysconfdir}/systemd/resolved.conf.d/

    if [ ${@bb.utils.contains('PACKAGECONFIG', 'eth-dbg-only', 'true', 'false', d)} = 'true' ]; then
      install -m 0644 ${WORKDIR}/llmnr.conf ${D}${sysconfdir}/systemd/resolved.conf.d/
    fi

    install -d ${D}${sysconfdir}/systemd/dnssd/
    install -m 0644 ${WORKDIR}/ssh.dnssd ${D}${sysconfdir}/systemd/dnssd/
}

FILES_${PN} += "/opt ${sysconfdir} ${systemd_unitdir}"

MBL_VAR_PLACEHOLDER_FILES = "${D}/opt/arm/mbl-hostname.sh"
MBL_VAR_PLACEHOLDER_FILES += "${@bb.utils.contains('PACKAGECONFIG', 'eth-dbg-only', '${D}${systemd_unitdir}/network/10-mbl-eth-dbg.network', '', d)}"
inherit mbl-var-placeholders


python __anonymous() {
    if bb.utils.contains('PACKAGECONFIG','all-allow', True, False, d) and bb.utils.contains('PACKAGECONFIG','eth-dbg-only', True, False, d):
        raise bb.parse.SkipRecipe("The systemd-net-conf PACKAGECONFIG options 'all-allow' and 'eth-dbg-only' are mutually exclusive")
}
