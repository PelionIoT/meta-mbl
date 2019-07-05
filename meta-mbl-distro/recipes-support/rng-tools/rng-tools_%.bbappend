# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# make sure the local appending config file will be chosen by prepending and extra local path
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI +=  " file://10-mbl-rngd.service.conf \
            "

FILES_${PN} += " \
    ${sysconfdir}/systemd/system/rngd.service.d/10-mbl-rngd.service.conf \
"
do_install_append() {
    install -d ${D}${sysconfdir}/systemd/system/rngd.service.d/
    install -m 0644 ${WORKDIR}/10-mbl-rngd.service.conf ${D}${sysconfdir}/systemd/system/rngd.service.d/10-mbl-rngd-service.conf
}

# NIST Randomness Beacon support requires curl which rdepends on (L)GPLv3
# packages. Add an option to configure out the support to remove these
# dependencies.
DEPENDS_remove = "curl"
PACKAGECONFIG[nistbeacon] = ",--without-nistbeacon,curl,curl"

MBL_VAR_PLACEHOLDER_FILES = "${D}${sysconfdir}/systemd/system/rngd.service.d/10-mbl-rngd-service.conf"
inherit mbl-var-placeholders
