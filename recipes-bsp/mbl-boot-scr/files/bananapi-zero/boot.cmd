echo "Testing uboot cmd.."
load mmc 0 0x45000000 /kernel.itb
setenv bootargs "debug earlyprintk console=ttyS0,115200 root=/dev/mmcblk0p2 rootwait rw"
bootm 0x45000000
