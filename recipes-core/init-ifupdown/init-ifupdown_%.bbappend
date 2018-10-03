FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"
SRC_URI += " file://interfaces"

FILES_${PN} += " \
    ${MBL_NON_FACTORY_CONFIG_DIR} \
    ${MBL_NON_FACTORY_CONFIG_DIR}/network \
    ${MBL_NON_FACTORY_CONFIG_DIR}/network/interfaces \
"


do_install_append() {
    rootfs_conf_file="${sysconfdir}/network/interfaces"
    conffs_conf_dir="${MBL_NON_FACTORY_CONFIG_DIR}/network"
    conffs_conf_file="${conffs_conf_dir}/interfaces"

    install -d "${D}${MBL_NON_FACTORY_CONFIG_DIR}"
    install -d "${D}${conffs_conf_dir}"

    mv "${D}${rootfs_conf_file}" "${D}${conffs_conf_file}"
    ln -sf "$conffs_conf_file" "${D}${rootfs_conf_file}"
}

# Replace placeholder strings in interfaces file with values of BitBake
# variables
MBL_WPA_SUPPLICANT_CONFIG_PATH = "${MBL_NON_FACTORY_CONFIG_DIR}/wpa_supplicant.conf"
MBL_WPA_DRIVER ?= "nl80211"
MBL_VAR_PLACEHOLDER_FILES = "${D}${MBL_NON_FACTORY_CONFIG_DIR}/network/interfaces"
inherit mbl-var-placeholders
