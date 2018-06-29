# This section is responsbile for loading a signed Linux kernel
setenv image_signed zImage.imx-signed
if test ${hab_enabled} -eq 1; then
	setexpr hab_ivt_addr ${loadaddr} - ${ivt_offset}
	load mmc ${mmcdev}:${mmcpart} ${hab_ivt_addr} ${image_signed}
	run warp7_auth_or_fail
else
	run loadimage;
fi

# Boot from rootfs1 by default
setenv mmcpart 3

# But if the rootfs2 file exists in partition 2, boot from rootfs2
ext4size mmc 0:2 rootfs2 && setenv mmcpart 5

# Set UUID mmcpart will be used to pass root id to kernel
setenv rootpart ${mmcpart}
run finduuid;
run mmcargs;

# Now boot
echo Booting secure Linux from mmc ...;
bootm ${loadaddr} - ${fdt_addr};

# Failsafe if something goes wrong
hab_failsafe
