# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

# The area between 0x10000000 and 0x11000000 has to be kept for secure
# world so that the kernel doesn't use it.
setenv bootargs "${bootargs} memmap=16M$256M"

# Set serial console parameters
setenv bootargs "${bootargs} 8250.nr_uarts=1 console=ttyS0,115200 rootwait rw"

# Let USB driver don't use the FIQs. Using FIQs in USB driver causes the
# TF-A to be crashed.
setenv bootargs "${bootargs} dwc_otg.fiq_enable=0 dwc_otg.fiq_fsm_enable=0 dwc_otg.nak_holdoff=0"

# Load Linux Kernel image from the boot partition (Linux Kernel image contains the initramfs image)
echo "Load fit blob with Linux Kernel image and initramfs image"
fatload mmc 0 0x02100000 boot.scr

imxtract 0x02100000#conf@bcm2710-rpi-3-b-plus.dtb fdt@bcm2710-rpi-3-b-plus.dtb 0x03000000
imxtract 0x02100000 fdt@rpi3-optee-dtb-overlay.dtbo 0x18000000

# Apply OP-TEE overlay
fdt addr 0x03000000
fdt resize 0x1000
fdt apply 0x18000000

# Boot Linux
bootm 0x02100000#conf@bcm2710-rpi-3-b-plus.dtb 0x02100000:ramdisk@1 0x03000000
