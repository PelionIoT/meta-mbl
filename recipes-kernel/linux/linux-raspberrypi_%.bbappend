do_configure_prepend() {
    kernel_configure_variable IKCONFIG y
    kernel_configure_variable TEE y
    kernel_configure_variable OPTEE y
}
