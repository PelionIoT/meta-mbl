inherit image_types_fsl
inherit image_sign_mbl

IMAGE_INSTALL_append_imx7s-warp += "warp7-u-boot-scr"

_generate_boot_image() {
	local boot_part=$1
	# Create boot partition image
	BOOT_BLOCKS=$(LC_ALL=C parted -s ${SDCARD} unit b print \
		| awk "/ $boot_part / { print substr(\$4, 1, length(\$4 -1)) / 1024 }")
	# mkdosfs will sometimes use FAT16 when it is not appropriate,
	# resulting in a boot failure from SYSLINUX. Use FAT32 for
	# images larger than 512MB, otherwise let mkdosfs decide.
	if [ $(expr $BOOT_BLOCKS / 1024) -gt 512 ]; then
	        FATSIZE="-F 32"
	fi
	rm -f ${WORKDIR}/boot.img
	# Create the image by BOOT_BLOCKS
	mkfs.vfat -n "${BOOTDD_VOLUME_ID}" -S 512 ${FATSIZE} -C ${WORKDIR}/boot.img $BOOT_BLOCKS
	# make it as ext3
	mkfs.ext3 ${WORKDIR}/boot.img -d ${WORKDIR}/rootfs/boot/bootscr
}

generate_imx_sdcard () {
	# Create partition table
	parted -s ${SDCARD} mklabel msdos
	parted -s ${SDCARD} unit KiB mkpart primary ${IMAGE_ROOTFS_ALIGNMENT} $(expr ${IMAGE_ROOTFS_ALIGNMENT} \+ ${BOOT_SPACE_ALIGNED})
	parted -s ${SDCARD} unit KiB mkpart primary $(expr  ${IMAGE_ROOTFS_ALIGNMENT} \+ ${BOOT_SPACE_ALIGNED}) $(expr ${IMAGE_ROOTFS_ALIGNMENT} \+ ${BOOT_SPACE_ALIGNED} \+ $ROOTFS_SIZE)
	parted -s ${SDCARD} unit KiB mkpart primary $(expr  ${IMAGE_ROOTFS_ALIGNMENT} \+ ${BOOT_SPACE_ALIGNED} \+ $ROOTFS_SIZE) $(expr ${IMAGE_ROOTFS_ALIGNMENT} \+ ${BOOT_SPACE_ALIGNED} \+ $ROOTFS_SIZE \+ $ROOTFS_SIZE)
	parted -s ${SDCARD} unit KiB mkpart primary $(expr  ${IMAGE_ROOTFS_ALIGNMENT} \+ ${BOOT_SPACE_ALIGNED} \+ $ROOTFS_SIZE \+ $ROOTFS_SIZE) $(expr ${IMAGE_ROOTFS_ALIGNMENT} \+ ${BOOT_SPACE_ALIGNED} \+ $ROOTFS_SIZE \+ $ROOTFS_SIZE \+ $ROOTFS_SIZE)
	parted ${SDCARD} print

	# Burn bootloader
	case "${IMAGE_BOOTLOADER}" in
		imx-bootlets)
		bberror "The imx-bootlets is not supported for i.MX based machines"
		exit 1
		;;
		u-boot)
		if [ -n "${SPL_BINARY}" ]; then
			dd if=${DEPLOY_DIR_IMAGE}/${SPL_BINARY} of=${SDCARD} conv=notrunc seek=2 bs=512
			dd if=${DEPLOY_DIR_IMAGE}/u-boot-${MACHINE}.${UBOOT_SUFFIX_SDCARD} of=${SDCARD} conv=notrunc seek=69 bs=1K
		else
			if [ -e ${DEPLOY_DIR_IMAGE}/${UBOOT_IMX}-signed ]; then
				dd if=${DEPLOY_DIR_IMAGE}/${UBOOT_IMX}-signed of=${SDCARD} conv=notrunc seek=2 bs=512
			else
				dd if=${DEPLOY_DIR_IMAGE}/u-boot-${MACHINE}.${UBOOT_SUFFIX_SDCARD} of=${SDCARD} conv=notrunc seek=2 bs=512
			fi
		fi
		;;
		barebox)
		dd if=${DEPLOY_DIR_IMAGE}/barebox-${MACHINE}.bin of=${SDCARD} conv=notrunc seek=1 skip=1 bs=512
		dd if=${DEPLOY_DIR_IMAGE}/bareboxenv-${MACHINE}.bin of=${SDCARD} conv=notrunc seek=1 bs=512k
		;;
		"")
		;;
		*)
		bberror "Unknown IMAGE_BOOTLOADER value"
		exit 1
		;;
	esac

	_generate_boot_image 1

	# Burn Partition
	dd if=${WORKDIR}/boot.img of=${SDCARD} conv=notrunc,fsync seek=1 bs=$(expr ${IMAGE_ROOTFS_ALIGNMENT} \* 1024)
	dd if=${SDCARD_ROOTFS} of=${SDCARD} conv=notrunc,fsync seek=1 bs=$(expr ${BOOT_SPACE_ALIGNED} \* 1024 + ${IMAGE_ROOTFS_ALIGNMENT} \* 1024)
}

IMAGE_CMD_sdcard () {
	if [ -z "${SDCARD_ROOTFS}" ]; then
		bberror "SDCARD_ROOTFS is undefined. To use sdcard image from Freescale's BSP it needs to be defined."
		exit 1
	fi

	# Align boot partition and calculate total SD card image size
	BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE} + ${IMAGE_ROOTFS_ALIGNMENT} - 1)
	BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE_ALIGNED} - ${BOOT_SPACE_ALIGNED} % ${IMAGE_ROOTFS_ALIGNMENT})
	SDCARD_SIZE=$(expr ${IMAGE_ROOTFS_ALIGNMENT} + ${BOOT_SPACE_ALIGNED} + $ROOTFS_SIZE + $ROOTFS_SIZE + $ROOTFS_SIZE + ${IMAGE_ROOTFS_ALIGNMENT})

	# Initialize a sparse file
	dd if=/dev/zero of=${SDCARD} bs=1 count=0 seek=$(expr 1024 \* ${SDCARD_SIZE})

	${SDCARD_GENERATION_COMMAND}
}
