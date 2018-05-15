echo "Testing uboot cmd.."
load mmc 0 0x45000000 /kernel.itb
setenv bootargs "debug earlyprintk console=ttyS0,115200 root=/dev/mmcblk0p3 rootwait rw"
setenv bootm_boot_mode "sec"
bootm 0x45000000
