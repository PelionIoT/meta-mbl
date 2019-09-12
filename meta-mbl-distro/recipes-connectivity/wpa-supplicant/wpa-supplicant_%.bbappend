# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# make sure the local appending config file will be chosen by prepending and extra local path
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

FILES_${PN} += " \
    ${MBL_CONFIG_DIR} \
    ${MBL_CONFIG_DIR}/wpa_supplicant.conf \
"

do_install_append() {
    rootfs_conf_file="${sysconfdir}/wpa_supplicant.conf"
    conffs_conf_file="${MBL_CONFIG_DIR}/wpa_supplicant.conf"

    install -d "${D}${MBL_CONFIG_DIR}"

    mv "${D}${rootfs_conf_file}" "${D}${conffs_conf_file}"
    ln -s "$conffs_conf_file" "${D}${rootfs_conf_file}"
}
