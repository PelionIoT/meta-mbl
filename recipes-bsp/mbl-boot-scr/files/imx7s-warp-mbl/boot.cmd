# This section is responsbile for loading a signed Linux kernel
setenv image_signed zImage.imx-signed
if test ${hab_enabled} -eq 1; then
	setexpr hab_ivt_addr ${loadaddr} - ${ivt_offset}
	${loadcmd} mmc ${mmcdev}:${mmcpart} ${hab_ivt_addr} ${image_signed}
	run warp7_auth_or_fail
else
	run loadimage;
fi

# This section is responsbile for loading a signed FDT image
setenv fdt_file_signed imx7s-warp.dtb.imx-signed
if test ${hab_enabled} -eq 1; then
	setexpr hab_ivt_addr ${fdt_addr} - ${ivt_offset}
	${loadcmd} mmc ${mmcdev}:${mmcpart} ${hab_ivt_addr} ${fdt_file_signed}
	run warp7_auth_or_fail
else
	run loadfdt;
fi

# Set the filesystem type and partition target
setenv loadcmd ext4load

# Boot from rootfs1 by default
setenv mmcpart 3

# But if the rootfs2 file exists in partition 2, boot from rootfs2
ext4size mmc 0:2 rootfs2 && setenv mmcpart 5

# This section is responsbile for loading a signed OPTEE image
setenv optee_file /lib/firmware/uTee.optee
setenv optee_file_signed /lib/firmware/uTee.optee.imx-signed
setenv loadoptee "${loadcmd} mmc ${mmcdev}:${mmcpart} ${optee_addr} ${optee_file}"
if test ${hab_enabled} -eq 1; then
	setexpr hab_ivt_addr ${optee_addr} - ${ivt_offset}
	${loadcmd} mmc ${mmcdev}:${mmcpart} ${hab_ivt_addr} ${optee_file_signed}
	run warp7_auth_or_fail
else
	run loadoptee;
fi

# Set UUID mmcpart will be used to pass root id to kernel
run finduuid;
run mmcargs;

# Now boot
echo Booting secure Linux/OPTEE OS from mmc ...;
bootm ${optee_addr} - ${fdt_addr};

# Failsafe if something goes wrong
hab_failsafe
