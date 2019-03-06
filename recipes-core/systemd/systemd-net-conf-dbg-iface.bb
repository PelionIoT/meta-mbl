# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY = "Systemd network related files"
DESCRIPTION = "This recipe provides a package to be used in development images \
when the MBL_DEBUG_INTERFACE variable is set in the machine conf file, otherwise \
it will raise a bitbake build error. In this case systemd will be managing this \
debug interface but the main internet connections will be managed by connman \
(e.g. wifi, main ethernet and cellular)."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://10-debug-interface.network \
          "

do_configure() {
    if [ "${@d.getVar('MBL_DEBUG_INTERFACE')}" = "None" ]; then
        bberror "MBL_DEBUG_INTERFACE is empty. To build this package you must set it."
        exit 1
    fi
}

do_install() {
    install -d ${D}${systemd_unitdir}/network/
    install -m 0644 ${WORKDIR}/10-debug-interface.network ${D}${systemd_unitdir}/network/
}

FILES_${PN} = " \
        ${systemd_unitdir}/network/10-debug-interface.network \
       "

# Interim solution for re-running the do install task when the
# MBL_DEBUG_INTERFACE set in the machine conf file changes and
# force do_expand_mbl_var_placeholders to replace the strings again
do_install[vardeps] = "MBL_DEBUG_INTERFACE"

MBL_VAR_PLACEHOLDER_FILES = "${D}${systemd_unitdir}/network/10-debug-interface.network"
inherit mbl-var-placeholders
