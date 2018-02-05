FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"
SRC_URI += " file://interfaces"

FILES_${PN} += " \
    ${MBL_CONFIG_DIR} \
    ${MBL_CONFIG_DIR}/network \
    ${MBL_CONFIG_DIR}/network/interfaces \
"

WPA_SUPPLICANT_CONFIG = "${MBL_CONFIG_DIR}/wpa_supplicant.conf"
MBL_WPA_DRIVER ?= "nl80211"

fixup_interfaces_conf() {
interfaces_file="$1"

    sed -i -e "s|__REPLACE_ME_WITH_WPA_SUPPLICANT_CONFIG_PATH__|${WPA_SUPPLICANT_CONFIG}|g" "$interfaces_file"
    sed -i -e "s|__REPLACE_ME_WITH_WPA_DRIVER__|${MBL_WPA_DRIVER}|g" "$interfaces_file"
}

do_install_append() {
    rootfs_conf_file="${sysconfdir}/network/interfaces"
    conffs_conf_dir="${MBL_CONFIG_DIR}/network"
    conffs_conf_file="${conffs_conf_dir}/interfaces"

    install -d "${D}${conffs_conf_dir}"

    mv "${D}${rootfs_conf_file}" "${D}${conffs_conf_file}"
    ln -sf "$conffs_conf_file" "${D}${rootfs_conf_file}"

    fixup_interfaces_conf "${D}${conffs_conf_file}"
}
