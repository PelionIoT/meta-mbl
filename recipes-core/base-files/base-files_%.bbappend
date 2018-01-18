FILESEXTRAPATHS_append := "${THISDIR}/files:"

SRC_URI_append = " file://fstab "

do_install_append() {
    # Ensure that mountpoints specified in fstab exist on the root filesystem
    install -d ${D}/boot
    install -d ${D}/mnt/flags
    install -d ${D}/mnt/config
    install -d ${D}/mnt/cache
}
