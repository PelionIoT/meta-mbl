# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# make sure the local appending config file will be chosen by prepending and extra local path
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

FILES_libopkg += " \
    ${MBL_SCRATCH_DIR}/opkg/src_ipk \
    ${MBL_APP_DIR} \
"

do_install_append() {
    install -d ${D}${sysconfdir}/opkg
    install -m 0644 ${WORKDIR}/opkg.conf "${D}${sysconfdir}/opkg/opkg.conf"

    install -d ${D}/${MBL_SCRATCH_DIR}/opkg/src_ipk/
    install -d ${D}/${MBL_APP_DIR}
}

# Replace placeholder strings in opkg.conf with values of BitBake variables
MBL_VAR_PLACEHOLDER_FILES = "${D}${sysconfdir}/opkg/opkg.conf"
inherit mbl-var-placeholders
