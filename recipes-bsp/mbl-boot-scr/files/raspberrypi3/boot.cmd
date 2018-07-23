# Specify a kernel image containing mbl-console-image-initramfs (do not use the default uImage)
setenv image uImage-initramfs-raspberrypi3-mbl.bin

# Load device tree and get kernel args from it
fdt addr ${fdt_addr} && fdt get value bootargs /chosen bootargs

# mmcblk0p3 is rootfs1 - use this by default
setenv rootfs /dev/mmcblk0p3

# mmcblk0p5 is rootfs2 - use this if there's a "rootfs2" flag in the flags partition
ext4size mmc 0:2 rootfs2 && setenv rootfs /dev/mmcblk0p5

echo "using root=${rootfs}"
setenv bootargs "${bootargs} root=${rootfs}"

# Load Linux Kernel image from the boot partition (Linux Kernel image contains the initramfs image)
echo "Load Linux Kernel image containing initramfs image: ${image}"
fatload mmc 0:1 ${kernel_addr_r} ${image}

# Boot Linux with the device tree
bootm ${kernel_addr_r} - ${fdt_addr}
