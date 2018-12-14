# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

###############################################################################
# mbl-fitimage.bbclass
#  This bitbake class derives from the parent kernel-fitimage classes to
#  implement modified behavior. This includes:
#    - Adding a bootscr section to the FIT image ITS specification file.
#    - Modifying fitimage_assemble to include a step to create the u-boot 
#      boot script.
###############################################################################

###############################################################################
# Default symbol values are specified here at file scope
#
# UBOOT_SIGN_KEYDIR
#   The directory containing the keys for signing.
#
# UBOOT_SIGN_KEYNAME
#   The the name of the key to use for signing.
###############################################################################
UBOOT_ARCH = "arm"
UBOOT_SIGN_KEYDIR = "${MBL_KEYSTORE_DIR}"
UBOOT_SIGN_KEYNAME = "${MBL_FIT_ROT_KEY_FILENAME}"

inherit kernel-fitimage mbl-artifact-names

# Recipes that use this class are required to have the mbl-boot-scr
# recipe make the ${DEPLOY_DIR_IMAGE}/${MBL_UBOOT_CMD_FILENAME} available for use.
# ${MBL_UBOOT_CMD_FILENAME} is referenced in the ITS file and used to build
# the FIT image.
DEPENDS += " mbl-boot-scr"
do_compile[depends] += "mbl-boot-scr:do_deploy"

#
# Emit the fitImage ITS U-boot boot script section
#
# $1 ... .its filename to specifiy what to pack in fit image
# $2 ... Path to u-boot boot script file
fitimage_emit_section_boot_script() {

	bootscr_csum="sha1"
	boot_its_file="${1}"
	boot_scr="${2}"

	cat << EOF >> ${boot_its_file}
                bootscr {
                        description = "U-boot boot script";
                        data = /incbin/("${boot_scr}");
                        type = "script";
                        arch = "${UBOOT_ARCH}";
                        compression = "none";
                        hash@1 {
                                algo = "${bootscr_csum}";
                        };
                };
EOF
}

#
# Emit the fitImage ITS configuration section
#
# $1 ... .its filename
# $2 ... Linux kernel ID
# $3 ... DTB image name
# $4 ... ramdisk ID
# $5 ... config ID
# $6 ... default flag
fitimage_emit_section_config() {

	conf_csum="sha1"
	if [ -n "${UBOOT_SIGN_ENABLE}" ] ; then
		conf_sign_keyname="${UBOOT_SIGN_KEYNAME}"
	fi

	# Test if we have any DTBs at all
	sep=""
	conf_desc=""
	kernel_line=""
	fdt_line=""
	ramdisk_line=""
	loadables_line=""
	setup_line=""
	default_line=""

	if [ -n "${2}" ]; then
		conf_desc="Linux kernel"
		sep=", "
		kernel_line="kernel = \"kernel@${2}\";"
	fi

	if [ -n "${3}" ]; then
		conf_desc="${conf_desc}${sep}FDT blob"
		sep=", "
		fdt_line="fdt = \"fdt@${3}\";"
	fi

	if [ -n "${4}" ]; then
		conf_desc="${conf_desc}${sep}ramdisk"
		sep=", "
		ramdisk_line="ramdisk = \"ramdisk@${4}\";"
	fi

	if [ -n "${5}" ]; then
		conf_desc="${conf_desc}${sep}setup"
		setup_line="setup = \"setup@${5}\";"
	fi

	if [ "${6}" = "1" ]; then
		default_line="default = \"conf@${3}\";"
	fi

	loadables_line="loadables = \"bootscr\";"

	cat << EOF >> ${1}
                ${default_line}
                conf@${3} {
			description = "${6} ${conf_desc}";
			${kernel_line}
			${fdt_line}
			${ramdisk_line}
			${setup_line}
			${loadables_line}
                        hash@1 {
                                algo = "${conf_csum}";
                        };
EOF

	if [ ! -z "${conf_sign_keyname}" ] ; then

		sign_line="sign-images = "
		sep=""

		if [ -n "${2}" ]; then
			sign_line="${sign_line}${sep}\"kernel\""
			sep=", "
		fi

		if [ -n "${3}" ]; then
			sign_line="${sign_line}${sep}\"fdt\""
			sep=", "
		fi

		if [ -n "${4}" ]; then
			sign_line="${sign_line}${sep}\"ramdisk\""
			sep=", "
		fi

		if [ -n "${5}" ]; then
			sign_line="${sign_line}${sep}\"setup\""
		fi

		sign_line="${sign_line}${sep}\"loadables\""
		sign_line="${sign_line};"

		cat << EOF >> ${1}
                        signature@1 {
                                algo = "${conf_csum},rsa2048";
                                key-name-hint = "${conf_sign_keyname}";
				${sign_line}
                        };
EOF
	fi

	cat << EOF >> ${1}
                };
EOF
}

#
# Assemble fitImage
#
# $1 ... .its filename
# $2 ... fitImage name
# $3 ... include ramdisk
fitimage_assemble() {
	kernelcount=1
	dtbcount=""
	DTBS=""
	ramdiskcount=${3}
	setupcount=""
	rm -f ${1} arch/${ARCH}/boot/${2}

	fitimage_emit_fit_header ${1}

	#
	# Step 1: Prepare a kernel image section.
	#
	fitimage_emit_section_maint ${1} imagestart

	uboot_prep_kimage
	fitimage_emit_section_kernel ${1} "${kernelcount}" linux.bin "${linux_comp}"

	#
	# Step 2: Prepare a DTB image section
	#
	if [ -n "${KERNEL_DEVICETREE}" ]; then
		dtbcount=1
		for DTB in ${KERNEL_DEVICETREE}; do
			if echo ${DTB} | grep -q '/dts/'; then
				bbwarn "${DTB} contains the full path to the the dts file, but only the dtb name should be used."
				DTB=`basename ${DTB} | sed 's,\.dts$,.dtb,g'`
			fi
			DTB_PATH="arch/${ARCH}/boot/dts/${DTB}"
			if [ ! -e "${DTB_PATH}" ]; then
				DTB_PATH="arch/${ARCH}/boot/${DTB}"
			fi

			DTB=$(echo "${DTB}" | tr '/' '_')
			DTBS="${DTBS} ${DTB}"
			fitimage_emit_section_dtb ${1} ${DTB} ${DTB_PATH}
		done
	fi

	#
	# Step 3: Prepare a setup section. (For x86)
	#
	if [ -e arch/${ARCH}/boot/setup.bin ]; then
		setupcount=1
		fitimage_emit_section_setup ${1} "${setupcount}" arch/${ARCH}/boot/setup.bin
	fi

	#
	# Step 4: Prepare a ramdisk section.
	#
	if [ "x${ramdiskcount}" = "x1" ] ; then
		# Find and use the first initramfs image archive type we find
		for img in cpio.lz4 cpio.lzo cpio.lzma cpio.xz cpio.gz ext2.gz cpio; do
			initramfs_path="${DEPLOY_DIR_IMAGE}/${INITRAMFS_IMAGE_NAME}.${img}"
			echo "Using $initramfs_path"
			if [ -e "${initramfs_path}" ]; then
				fitimage_emit_section_ramdisk ${1} "${ramdiskcount}" "${initramfs_path}"
				break
			fi
		done
	fi

	#
	# Step 5: Prepare a boot script for u-boot.
	#
	if [ -n "${MBL_UBOOT_CMD_FILENAME}" ]; then
		ln -snf "${DEPLOY_DIR_IMAGE}/${MBL_UBOOT_CMD_FILENAME}" ${MBL_UBOOT_CMD_FILENAME}
		fitimage_emit_section_boot_script ${1} "${MBL_UBOOT_CMD_FILENAME}"
	else
		bberror 'Cannot find u-boot command file: ${MBL_UBOOT_CMD_FILENAME}.'
	fi

	fitimage_emit_section_maint ${1} sectend

	# Force the first Kernel and DTB in the default config
	kernelcount=1
	if [ -n "${dtbcount}" ]; then
		dtbcount=1
	fi

	#
	# Step 6: Prepare a configurations section
	#
	fitimage_emit_section_maint ${1} confstart

	if [ -n "${DTBS}" ]; then
		i=1
		for DTB in ${DTBS}; do
			dtb_ext=${DTB##*.}
			if [ "${dtb_ext}" = "dtbo" ]; then
				fitimage_emit_section_config ${1} "" "${DTB}" "" "" "`expr ${i} = ${dtbcount}`"
			else
				fitimage_emit_section_config ${1} "${kernelcount}" "${DTB}" "${ramdiskcount}" "${setupcount}" "`expr ${i} = ${dtbcount}`"
			fi
			i=`expr ${i} + 1`
		done
	fi

	fitimage_emit_section_maint ${1} sectend

	fitimage_emit_section_maint ${1} fitend

	#
	# Step 7: Assemble the image
	#
	uboot-mkimage \
		${@'-D "${UBOOT_MKIMAGE_DTCOPTS}"' if len('${UBOOT_MKIMAGE_DTCOPTS}') else ''} \
		-f ${1} \
		arch/${ARCH}/boot/${2}

	#
	# Step 8: Sign the image and add public key to U-Boot dtb
	#
	if [ "x${UBOOT_SIGN_ENABLE}" = "x1" ] ; then
		add_key_to_u_boot=""
		if [ -n "${UBOOT_DTB_BINARY}" ]; then
			# The u-boot.dtb is a symlink to UBOOT_DTB_IMAGE, so we need copy
			# both of them, and don't dereference the symlink.
			cp -P ${STAGING_DATADIR}/u-boot*.dtb ${B}
			add_key_to_u_boot="-K ${B}/${UBOOT_DTB_BINARY}"
		fi
		uboot-mkimage \
			${@'-D "${UBOOT_MKIMAGE_DTCOPTS}"' if len('${UBOOT_MKIMAGE_DTCOPTS}') else ''} \
			-F -k "${UBOOT_SIGN_KEYDIR}" \
			$add_key_to_u_boot \
			-r arch/${ARCH}/boot/${2}
	fi
}


kernel_do_deploy[vardepsexclude] = "DATETIME"
kernel_do_deploy_append() {
	install -d ${DEPLOYDIR}/mbl-bootfiles
	if echo ${KERNEL_IMAGETYPES} | grep -wq "fitImage"; then
		if [ -n "${INITRAMFS_IMAGE}" ]; then
			install -m 0644 ${B}/arch/${ARCH}/boot/fitImage-${INITRAMFS_IMAGE} ${DEPLOYDIR}/mbl-bootfiles/${MBL_FIT_BIN_FILENAME}
		fi
	fi
}
