FILES_${PN} += " \
    ${MBL_NON_FACTORY_CONFIG_DIR} \
    ${MBL_NON_FACTORY_CONFIG_DIR}/wpa_supplicant.conf \
"

do_install_append() {
    rootfs_conf_file="${sysconfdir}/wpa_supplicant.conf"
    conffs_conf_file="${MBL_NON_FACTORY_CONFIG_DIR}/wpa_supplicant.conf"

    install -d "${D}${MBL_NON_FACTORY_CONFIG_DIR}"

    mv "${D}${rootfs_conf_file}" "${D}${conffs_conf_file}"
    ln -s "$conffs_conf_file" "${D}${rootfs_conf_file}"
}
