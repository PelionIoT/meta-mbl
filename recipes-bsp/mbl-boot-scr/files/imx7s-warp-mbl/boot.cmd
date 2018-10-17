# In order to load OP-TEE Boot from rootfs1 by default
setenv mmcpart 3

# But if the rootfs2 file exists in partition 2, boot from rootfs2
ext4size mmc 0:2 rootfs2 && setenv mmcpart 5

# Note: rootfs partition is selected in initramfs-init-script.sh and depends on 
# the existence of rootfs file in the bootflags partition.
# The "rootfs=" part of the kernel command line still exists but it is ignored
# as the initramfs has an init script.

# Set UUID mmcpart will be used to pass root id to kernel
setenv rootpart ${mmcpart}
run finduuid;
run mmcargs;

# Now boot
echo Booting secure Linux from FIT ...;
bootm ${bootscriptaddr}#conf@1 - ${fdt_addr};

# Failsafe if something goes wrong
hab_failsafe
