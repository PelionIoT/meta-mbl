# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "Systemd network related files"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGES += "${PN}-usb-gether ${PN}-eth"

SRC_URI = "file://10-usb-gether.network \
	   file://10-eth.network \
           file://mbl-hostname.sh \
           file://mbl-hostname.service \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "mbl-hostname.service"

do_install() {
        install -d ${D}${systemd_unitdir}/network/
        install -m 0644 ${WORKDIR}/10-usb-gether.network ${D}${systemd_unitdir}/network/
	install -m 0644 ${WORKDIR}/10-eth.network ${D}${systemd_unitdir}/network/

        install -d ${D}${systemd_unitdir}/system/
        install -m 0644 ${WORKDIR}/mbl-hostname.service ${D}${systemd_unitdir}/system/

        install -d ${D}/opt/arm/
        install -m 0744 ${WORKDIR}/mbl-hostname.sh ${D}/opt/arm/mbl-hostname.sh
}

FILES_${PN} = " \
        /opt/arm/mbl-hostname.sh \
"

FILES_${PN}-usb-gether = " \
        ${systemd_unitdir}/network/10-usb-gether.network \
"

FILES_${PN}-eth = " \
        ${systemd_unitdir}/network/10-eth.network \
"
