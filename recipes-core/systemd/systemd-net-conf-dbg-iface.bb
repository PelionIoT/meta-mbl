# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "Systemd network debug interface related service"
DESCRIPTION = "This recipe provides a package to set the MAC addresses of the \
usb gadget ethernet interface when the usbgadget COMBINED_FEATURE is present."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://mbl-usb-gether-mac-addr.service \
           file://mbl-usb-gether-mac-addr.sh \
          "

inherit systemd

SYSTEMD_SERVICE_${PN} = "mbl-usb-gether-mac-addr.service"

do_configure() {
    if [ ${@bb.utils.contains('COMBINED_FEATURES', 'usbgadget', 'true', 'false', d)} = 'false' ]; then
        bberror "${PN} requires the usbgadget COMBINED_FEATURE."
        exit 1
    fi
}

do_install() {
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/mbl-usb-gether-mac-addr.service ${D}${systemd_unitdir}/system/

    install -d ${D}/opt/arm/
    install -m 0744 ${WORKDIR}/mbl-usb-gether-mac-addr.sh ${D}/opt/arm/mbl-usb-gether-mac-addr.sh
}

FILES_${PN} = "/opt/arm/mbl-usb-gether-mac-addr.sh"

MBL_VAR_PLACEHOLDER_FILES = "${D}/opt/arm/mbl-usb-gether-mac-addr.sh"
inherit mbl-var-placeholders
