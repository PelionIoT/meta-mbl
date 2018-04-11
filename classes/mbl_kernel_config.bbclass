set_mbl_kernel_config_value() {
config_file="$1"
config_name="$2"
config_value="$3"

    if ! grep -q "^CONFIG_${config_name}[ =]" "$config_file"; then
        echo "CONFIG_${config_name}=${config_value}" >> "$config_file"
        return 0
    fi
    sed -i -e "s/^CONFIG_${config_name}[ =].*\$/CONFIG_${config_name}=${config_value}/" "$config_file"
}

do_configure_prepend() {
    config_file="${B}/.config"

    # Required for handling a USB Ethernet device
    set_mbl_kernel_config_value "$config_file" USB_ETH y
    set_mbl_kernel_config_value "$config_file" USB_NCM y
}
