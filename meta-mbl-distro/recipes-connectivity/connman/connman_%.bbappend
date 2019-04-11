# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Make sure the local appending config file will be chosen by
# prepending and extra local path
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

FILES_${PN} += " \
    ${MBL_NON_FACTORY_CONFIG_DIR} \
    ${MBL_NON_FACTORY_CONFIG_DIR}/main.conf \
"

SRC_URI +=  " file://main.conf \
              file://settings \
            "

# Pass MBL_NON_FACTORY_CONFIG_DIR to autotools make to minimize maintainance.
# Some ConnMan paths will be redirected the non factory config path
EXTRA_OEMAKE += "\
    MBL_NON_FACTORY_CONFIG_DIR=${MBL_NON_FACTORY_CONFIG_DIR} \
"

do_install_append() {
    install -d ${D}${MBL_NON_FACTORY_CONFIG_DIR}/connman
    install -m 0644 ${WORKDIR}/main.conf ${D}${MBL_NON_FACTORY_CONFIG_DIR}/connman/main.conf
    install -m 0644 ${WORKDIR}/settings ${D}${MBL_NON_FACTORY_CONFIG_DIR}/connman/settings
}
