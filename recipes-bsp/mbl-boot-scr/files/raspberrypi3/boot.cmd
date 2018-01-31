# Load device tree and get kernel args from it
fdt addr ${fdt_addr} && fdt get value bootargs /chosen bootargs

# mmcblk0p3 is rootfs1 - use this by default
setenv rootfs /dev/mmcblk0p3

# mmcblk0p5 is rootfs2 - use this if there's a "rootfs2" flag in the flags partition
ext4size mmc 0:2 rootfs2 && setenv rootfs /dev/mmcblk0p5

echo "using root=${rootfs}"
setenv bootargs "${bootargs} root=${rootfs}"

# Load Linux from the boot partition
fatload mmc 0:1 ${kernel_addr_r} uImage

# Boot Linux with the device tree
bootm ${kernel_addr_r} - ${fdt_addr}
