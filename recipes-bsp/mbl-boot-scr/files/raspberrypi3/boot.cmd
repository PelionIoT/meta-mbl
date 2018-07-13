# Load device tree and get kernel args from it
setenv fdt_addr 0x03000000

# fdt addr ${fdt_addr} && fdt get value bootargs /chosen bootargs

# mmcblk0p3 is rootfs1 - use this by default
setenv rootfs /dev/mmcblk0p3

# mmcblk0p5 is rootfs2 - use this if there's a "rootfs2" flag in the flags partition
ext4size mmc 0:2 rootfs2 && setenv rootfs /dev/mmcblk0p5

echo "using root=${rootfs}"
setenv bootargs "${bootargs} 8250.nr_uarts=1 bcm2708_fb.fbwidth=656 bcm2708_fb.fbheight=416 bcm2708_fb.fbswap=1 vc_mem.mem_base=0x3ec00000 vc_mem.mem_size=0x40000000 dwc_otg.lpm_enable=0 rootfstype=ext4 console=ttyS0,115200 rootwait root=${rootfs} memmap=16M$256M dwc_otg.fiq_enable=0 dwc_otg.fiq_fsm_enable=0 dwc_otg.nak_holdoff=0"

# Load Linux from the boot partition
#fatload mmc 0:1 ${kernel_addr_r} uImage

# Boot Linux with the device tree
#bootm ${kernel_addr_r} - ${fdt_addr}
load mmc 0 0x02100000 kernel.itb
bootm 0x02100000
