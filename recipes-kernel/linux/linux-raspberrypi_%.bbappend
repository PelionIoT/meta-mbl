FILESEXTRAPATHS_prepend := "${THISDIR}/linux-raspberrypi:"
SRC_URI += " file://0001-rpi3-optee-update-DTS.patch"

do_configure_prepend() {
    kernel_configure_variable IKCONFIG y
    kernel_configure_variable TEE y
    kernel_configure_variable OPTEE y
}
