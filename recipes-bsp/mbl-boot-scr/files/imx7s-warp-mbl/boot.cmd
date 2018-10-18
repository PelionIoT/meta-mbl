# The rootfs selection is done in the initramfs other kernel params are set in mmcargs
run mmcargs

# Now boot
echo Booting secure Linux from FIT ...;
bootm ${bootscriptaddr}#conf@1 ${bootscriptaddr}:ramdisk@1 ${fdt_addr}

# Failsafe if something goes wrong
hab_failsafe
