# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# make sure the local appending config file will be chosen by prepending and extra local path
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

FILES_${PN} += " \
    ${MBL_CONFIG_DIR} \
    ${MBL_CONFIG_DIR}/main.conf \
    ${sysconfdir}/systemd/system/connman.service.d/10-mbl-connman.service.conf \
"

SRC_URI +=  " file://0005-replace-libreadline-with-libedit.patch \
              file://main.conf \
              file://settings \
              file://10-mbl-connman.service.conf \
            "
# Let systemd-resolved run to use it to deal with mDNS requests
SRC_URI_remove = "file://0001-connman.service-stop-systemd-resolved-when-we-use-co.patch"

#replace readline (GPLV3) with libedit (GPLV2)
DEPENDS_remove = "readline"
DEPENDS += " libedit"

# disable wispr support (Wireless Internet Service Provider roaming) to remove some GPLV3 dependencies
EXTRA_OECONF += "\
    --disable-wispr \
"
PACKAGECONFIG_remove = "wispr"
PACKAGECONFIG[wispr] = ""
FILES_${PN}-tools = ""

#pass MBL_CONFIG_DIR to autotools make to minimize maintainance. Some connman paths will be redirected the config path
EXTRA_OEMAKE += "\
    MBL_CONFIG_DIR=${MBL_CONFIG_DIR} \
"

do_install_append() {
    install -d ${D}${MBL_CONFIG_DIR}/connman
    install -m 0644 ${WORKDIR}/main.conf ${D}${MBL_CONFIG_DIR}/connman/main.conf
    install -m 0644 ${WORKDIR}/settings ${D}${MBL_CONFIG_DIR}/connman/settings

    install -d ${D}${sysconfdir}/systemd/system/connman.service.d/
    install -m 0644 ${WORKDIR}/10-mbl-connman.service.conf ${D}${sysconfdir}/systemd/system/connman.service.d/10-mbl-connman-service.conf

    # Fix wrong symlink creation in the main recipe
    rm -rf ${D}${sysconfdir}/resolv-conf.connman
    ln -sf ..${MBL_CONFIG_DIR}/run/connman/resolv.conf ${D}${sysconfdir}/resolv-conf.connman
}
