FILESEXTRAPATHS_append := "${THISDIR}/files:"

SRC_URI_append = " file://fstab "

fixup_fstab() {
fstab_file="$1"

    sed -i -e "s|__REPLACE_ME_WITH_MBL_CONFIG_DIR__|${MBL_CONFIG_DIR}|g" "$fstab_file"
}

do_install_append() {
    # Ensure that mountpoints specified in fstab exist on the root filesystem
    install -d ${D}/boot
    install -d ${D}/mnt/flags
    install -d ${D}${MBL_CONFIG_DIR}
    install -d ${D}/mnt/cache

    fixup_fstab "${D}${sysconfdir}/fstab"
}
