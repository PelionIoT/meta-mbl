#
# Makefile for rebuilding signed i.MX7 MBL image binaries
# SPDX-License-Identifier: Apache-2.0
#


# Common
UBOOT_REPO = u-boot
TEMP = `pwd`/temp
UBOOT_DIR ?= ${TEMP}/${UBOOT_REPO}
UBOOT_SHA ?= 224318f95f9e41f916579a20f3275ff3773f9c94
UBOOT_URL ?= https://git.linaro.org/landing-teams/working/mbl/${UBOOT_REPO}.git
BOARDCONFIG ?= warp7_secure_config
UBOOT_CFG = u-boot.cfg
UBOOT_BOARD_CFG = imximage.cfg.cfgtmp
MAKEDIR=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))
SIGNED_BINARIES ?= `pwd`/signed-binaries
IMAGE_NAME ?= mbl-console-image-imx7s-warp-mbl.wic.gz
IMAGE_NAME_TEST ?= mbl-console-image-test-imx7s-warp-mbl.wic.gz
IMAGE_DIR ?= `pwd`/../../../../../build-mbl/tmp-mbl-glibc/deploy/images/imx7s-warp-mbl
IMAGE_FILENAME ?= ${IMAGE_DIR}/${IMAGE_NAME}


# CST
CST_TOOLS_DIR = ${CST_BOARD_DIR}
CST_BOARD_DIR = `pwd`/../boards
CST_BOARD_ID ?= 000000-0000-000000-0000
CST_PATH ?= ${CST_BOARD_DIR}/${CST_BOARD_ID}
CST_BIN ?= ${CST_PATH}/linux64/cst
CSF_KEYS ?= ${CST_PATH}/keys
CRTS_DATA ?= ${CST_PATH}/crts
SRK_FUSE ?= SRK_1_2_3_4_fuse.bin
SRK_TABLE ?= SRK_1_2_3_4_table.bin
CST_KEY_PASS_FILENAME=key_pass.txt

# Commands
GIT ?= git
MAKE ?= make
SIGN = ${MAKEDIR}./scripts/image_sign.sh
FETCH_UBOOT = ${MAKEDIR}./scripts/fetch_uboot.sh
BUILD_UBOOT_TOOLS = ${MAKEDIR}./scripts/build_uboot_tools.sh
UBOOT_MKIMAGE ?= ${UBOOT_DIR}/tools/mkimage
MKIMAGE_VER_CHECK = ${MAKEDIR}./scripts/mkimage_ver_check.sh
MKDIRS = ${MAKEDIR}./scripts/mkdirs.sh
EXTRACT_UNSIGNED = ${MAKEDIR}./scripts/extract-unsigned-images.sh
ADD_SIGNED = ${MAKEDIR}./scripts/add-signed-images.sh
TAR = tar

# u-boot parameters
UBOOT_BIN = u-boot.bin
UBOOT_IMX = u-boot.imx
UBOOT_RECOVER_IMX = u-boot-recover.imx
UBOOT_CSF = 2048-u-boot_sign.csf
UBOOT_RECOVER_CSF = 2048-u-boot-recover_sign.csf
UBOOT_ADDR = CONFIG_SYS_TEXT_BASE

# u-boot boot script
BOOT_CSF = 2048-boot_scr_sign.csf
BOOT_SCR = boot.scr
BOOT_IMX = boot.scr.imx
BOOT_ADDR = CONFIG_LOADADDR

# Kernel signing data
ZIMAGE_CSF = 2048-zimage_sign.csf
ZIMAGE_BIN = zImage
ZIMAGE_IMX = zImage.imx
ZIMAGE_ADDR = CONFIG_LOADADDR

# FDT signing data
FDT_BIN = imx7s-warp.dtb
FDT_IMX = imx7s-warp.dtb.imx
FDT_CSF = 2048-dtb_sign.csf
FDT_ADDR = CONFIG_SYS_FDT_ADDR

# Optee signing data
OPTEE_BIN = uTee.optee
OPTEE_IMX = uTee.optee.imx
OPTEE_CSF = 2048-optee_sign.csf
OPTEE_ADDR = CONFIG_OPTEE_LOAD_ADDR

# Standard "make all" target
# Run dependencies, extract files, sign files, re-combine into signed image
all: depends extract-image u-boot u-boot-recovery u-boot-scr zImage fdt
	${MAKE} -f ${MAKEDIR}/Makefile optee OPTEE_ROOTFS=rootfs3
	${MAKE} -f ${MAKEDIR}/Makefile optee OPTEE_ROOTFS=rootfs5
	${MAKE} -f ${MAKEDIR}/Makefile combine-image

# Checkout u-boot to make u-boot mkimage @ required version
u-boot-fetch-checkout:
	${FETCH_UBOOT} ${GIT} ${UBOOT_DIR} ${UBOOT_URL} ${UBOOT_SHA}

# Build u-boot @required version
u-boot-build-tools:
	${BUILD_UBOOT_TOOLS} ${UBOOT_DIR} ${BOARDCONFIG}

# Check that one of the rootfs OPTEE rootfs's has been specified
optee_check:
ifeq ($(OPTEE_ROOTFS),)
	$(error OPTEE_ROOTFS "Please specify an optee rootfs i.e. OPTEE_ROOTFS=rootfs3")
endif

# Environment variable check
env_depend:
# Check a path to the CST has been set
ifeq ($(CST_PATH),)
	$(error CST_PATH "Please define a path to the CST utility")
endif

# Check that an IMAGE_NAME has been secified
ifeq ($(IMAGE_NAME),)
	$(error IMAGE_NAME "Please define a path to the unsinged input image")
endif

# Verify u-boot mkimage version
mkimage_depend:
	${MKIMAGE_VER_CHECK} ${UBOOT_MKIMAGE}

# Make directories used as temp or output directories
dirs:
	mkdir -p ${TEMP}
	mkdir -p ${SIGNED_BINARIES}

# Remove directories used as temp or output directories
dirs-clean:
	rm -rf ${TEMP}
	rm -rf ${SIGNED_BINARIES}

csf-deps:
ifeq ("$(wildcard ${MAKEDIR}/csf-templates/${UBOOT_CSF})","")
	echo "No such file ${MAKEDIR}/csf-templates/${UBOOT_CSF}" 1>&2;
	exit 1
endif
ifeq ("$(wildcard ${MAKEDIR}/csf-templates/${UBOOT_RECOVER_CSF})","")
	echo "No such file ${MAKEDIR}/csf-templates/${UBOOT_RECOVER_CSF}" 1>&2;
	exit 1
endif
ifeq ("$(wildcard ${MAKEDIR}/csf-templates/${BOOT_CSF})","")
	echo "No such file ${MAKEDIR}/csf-templates/${BOOT_CSF}" 1>&2;
	exit 1
endif
ifeq ("$(wildcard ${MAKEDIR}/csf-templates/${ZIMAGE_CSF})","")
	echo "No such file ${MAKEDIR}/csf-templates/${ZIMAGE_CSF}" 1>&2;
	exit 1
endif
ifeq ("$(wildcard ${MAKEDIR}/csf-templates/${FDT_CSF})","")
	echo "No such file ${MAKEDIR}/csf-templates/${FDT_CSF}" 1>&2;
	exit 1
endif
ifeq ("$(wildcard ${MAKEDIR}/csf-templates/${OPTEE_CSF})","")
	echo "No such file ${MAKEDIR}/csf-templates/${OPTEE_CSF}" 1>&2;
	exit 1
endif


# Copy CSF templates from csf directory to temp directory
csf_templates: csf-deps
	cp -f ${MAKEDIR}/csf-templates/* ${TEMP}

image_clean:
	rm -f ${IMAGE_NAME}

# Ensure the fuse.bin is in the source directory
${CRTS_DATA}/${SRK_FUSE}:
ifeq ("$(wildcard ${CRTS_DATA}/${SRK_FUSE})","")
	exit 1
endif

# This target copies keying material into the top level of the temp directory.
cst_data: ${CRTS_DATA}/${SRK_FUSE}
	cp ${CSF_KEYS}/* ${TEMP}
	cp ${CRTS_DATA}/* ${TEMP}
	cp ${TEMP}/${SRK_FUSE} ${SIGNED_BINARIES}


# List of dependencies
depends: dirs env_depend cst_data csf_templates u-boot-fetch-checkout u-boot-build-tools mkimage_depend

# Extract the specified image @ ${IMAGE_NAME}
extract-image: env_depend
	sudo ${EXTRACT_UNSIGNED} -i ${IMAGE_NAME}

# Combine signed image collateral into new signed- prefixed image
combine-image: env_depend
	sudo ${ADD_SIGNED} -i ${IMAGE_NAME} -f ${SRK_FUSE}

# Sign u-boot
u-boot: depends
	# Append IVT header to u-boot bin
	${SIGN} image_sign_mbl_generate_ivt ${UBOOT_BIN} ${UBOOT_IMX} ${UBOOT_ADDR} ${UBOOT_CFG} ${UBOOT_BOARD_CFG} ${TEMP} ${UBOOT_MKIMAGE}

	# u-boot appends an IVT header so we can sign the .imx binary directly
	${SIGN} image_sign_mbl_binary ${TEMP} ${UBOOT_CSF} ${UBOOT_IMX} ${CST_BIN} ${SRK_TABLE}

	# Copy to output directory
	cp ${TEMP}/${UBOOT_IMX}-signed ${SIGNED_BINARIES}

# Sign a u-boot recovery image
u-boot-recovery: depends
	cp ${TEMP}/${UBOOT_IMX} ${TEMP}/${UBOOT_RECOVER_IMX}
	cp ${TEMP}/${UBOOT_IMX}.log ${TEMP}/${UBOOT_RECOVER_IMX}.log

	# u-boot appends an IVT header so we can sign the .imx binary directly
	${SIGN} image_sign_mbl_binary ${TEMP} ${UBOOT_RECOVER_CSF} ${UBOOT_RECOVER_IMX} ${CST_BIN} ${SRK_TABLE}

	# Copy to output directory
	cp ${TEMP}/${UBOOT_RECOVER_IMX}-signed ${SIGNED_BINARIES}

# Sign boot.scr
u-boot-scr: depends
	# Append IVT header to boot script
	${SIGN} image_sign_mbl_generate_ivt ${BOOT_SCR} ${BOOT_IMX} ${BOOT_ADDR} ${UBOOT_CFG} ${UBOOT_BOARD_CFG} ${TEMP} ${UBOOT_MKIMAGE}

	# Sign boot script
	${SIGN} image_sign_mbl_binary ${TEMP} ${BOOT_CSF} ${BOOT_IMX} ${CST_BIN} ${SRK_TABLE}

	# Copy to output dir
	cp ${TEMP}/${BOOT_IMX}-signed ${SIGNED_BINARIES}

# Sign a zImage
zImage: depends
	# Append IVT header to boot script
	${SIGN} image_sign_mbl_generate_ivt ${ZIMAGE_BIN} ${ZIMAGE_IMX} ${ZIMAGE_ADDR} ${UBOOT_CFG} ${UBOOT_BOARD_CFG} ${TEMP} ${UBOOT_MKIMAGE}

	# Sign boot script
	${SIGN} image_sign_mbl_binary ${TEMP} ${ZIMAGE_CSF} ${ZIMAGE_IMX} ${CST_BIN} ${SRK_TABLE}

	# Copy to output dir
	cp ${TEMP}/${ZIMAGE_IMX}-signed ${SIGNED_BINARIES}

# Sign FDT
fdt: depends
	# Append IVT header to boot script
	${SIGN} image_sign_mbl_generate_ivt ${FDT_BIN} ${FDT_IMX} ${FDT_ADDR} ${UBOOT_CFG} ${UBOOT_BOARD_CFG} ${TEMP} ${UBOOT_MKIMAGE}

	# Sign boot script
	${SIGN} image_sign_mbl_binary ${TEMP} ${FDT_CSF} ${FDT_IMX} ${CST_BIN} ${SRK_TABLE}

	# Copy to output dir
	cp ${TEMP}/${FDT_IMX}-signed ${SIGNED_BINARIES}

# Sign OPTEE
optee: optee_check depends
	# Append IVT header to boot script
	${SIGN} image_sign_mbl_generate_ivt ${OPTEE_ROOTFS}/${OPTEE_BIN} ${OPTEE_ROOTFS}/${OPTEE_IMX} ${OPTEE_ADDR} ${UBOOT_CFG} ${UBOOT_BOARD_CFG} ${TEMP} ${UBOOT_MKIMAGE}

	# Sign boot script
	${SIGN} image_sign_mbl_binary ${TEMP} ${OPTEE_CSF} ${OPTEE_ROOTFS}/${OPTEE_IMX} ${CST_BIN} ${SRK_TABLE}

	# Copy to output dir
	mkdir -p ${SIGNED_BINARIES}/${OPTEE_ROOTFS}
	cp ${TEMP}/${OPTEE_ROOTFS}/${OPTEE_IMX}-signed ${SIGNED_BINARIES}/${OPTEE_ROOTFS}

# Standard "make clean" target
clean: dirs-clean image_clean
	rm -f ${TEMP}/*
	rm -f ${SIGNED_BINARIES}/*
	rm -f signed-${IMAGE_NAME}
	rm -f signed-${IMAGE_NAME_TEST}
	rm -f ${IMAGE_NAME}
	rm -f ${IMAGE_NAME_TEST}


test:
	echo ${FILE}
	#echo ${MAKEDIR}
