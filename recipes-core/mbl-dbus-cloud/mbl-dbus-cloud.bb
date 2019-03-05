# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "MBL D-Bus Cloud Infrastructure"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"


SRC_URI = "file://mbl-dbus-cloud.socket \
           file://mbl-dbus-cloud.service \
           file://mbl-dbus-cloud.conf \
"

RDEPENDS_${PN} = "dbus"

inherit useradd systemd

SYSTEMD_SERVICE_${PN} = "mbl-dbus-cloud.service"

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM_${PN} = "-r netdev"
USERADD_PARAM_${PN} = "--system --home ${localstatedir}/lib/dbus \
                                --no-create-home --shell /bin/false \
                                --user-group ${DBUS_DAEMONUSER}"

FILES_${PN} += "${systemd_unitdir}/system/mbl-dbus-cloud.socket \
                ${datadir}/dbus-1/mbl-dbus-cloud.d \
                ${datadir}/dbus-1/mbl-dbus-cloud.conf \
"

do_install() {
    install -d "${D}${datadir}/dbus-1/mbl-dbus-cloud.d"
    install -m 0644 "${WORKDIR}/mbl-dbus-cloud.conf" "${D}${datadir}/dbus-1/"

    install -d "${D}${systemd_unitdir}/system/"
    install -m 0644 "${WORKDIR}/mbl-dbus-cloud.socket" "${D}${systemd_unitdir}/system/"
    install -m 0644 "${WORKDIR}/mbl-dbus-cloud.service" "${D}${systemd_unitdir}/system/"
}

# The next parameters must match in both mbl-dbus-cloud.service file and mbl-dbus-cloud.conf.
# Use bbclass mbl-var-placeholders to replace all occurences in both files.
DBUS_DAEMONUSER="messagebus"
DBUS_MBL_CLOUD_BUS_ADDRESS="unix:path=/var/run/dbus/mbl_cloud_bus_socket"
MBL_VAR_PLACEHOLDER_FILES = "${D}${datadir}/dbus-1/mbl-dbus-cloud.conf ${D}${systemd_unitdir}/system/mbl-dbus-cloud.service"
inherit mbl-var-placeholders
