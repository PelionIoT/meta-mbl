fdt addr ${fdt_addr} && fdt get value bootargs /chosen bootargs
setenv rootfs /dev/mmcblk0p5
ext4size mmc 0:2 rootfs2 && setenv rootfs /dev/mmcblk0p6
setenv bootargs "${bootargs} root=${rootfs}"
fatload mmc 0:1 ${kernel_addr_r} uImage
bootm ${kernel_addr_r} - ${fdt_addr}
