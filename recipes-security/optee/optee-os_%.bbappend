
DEPENDS += "u-boot-mkimage-native u-boot imx7-cst-native warp7-csf-native warp7-keys-native openssl-native"

SRCREV="b207787cd6055f78e15a05eb8c43fbc88910087f"
SRC_URI="git://git@github.com/ARMmbed/mbl-optee_os.git;protocol=ssh;nobranch=1 \
file://0001-allow-setting-sysroot-for-libgcc-lookup.patch \
"
OPTEEMACHINE="imx-mx7swarp7"
OPTEEOUTPUTMACHINE="imx"

inherit warp7_key

# use default key if no WARP7_KEY_NAME defined
WARP7_KEY_NAME_DECRYPTED ?= "${B}/keys/default_ta.pem"

# TODO: add TA_SIGN_KEY=${WARP7_KEY_NAME_DECRYPTED} to EXTRA_OEMAKE once the
# OPTEE people get this resolved https://github.com/OP-TEE/optee_os/issues/2001

EXTRA_OEMAKE = "PLATFORM=${OPTEEMACHINE} \
                CROSS_COMPILE_core=${HOST_PREFIX} \
                CROSS_COMPILE_ta_arm32=${HOST_PREFIX} \
                NOWERROR=1 \
                ta-targets=ta_arm32 \
                LDFLAGS= \
                LIBGCC_LOCATE_CFLAGS=--sysroot=${STAGING_DIR_HOST} \
                CFG_PAGEABLE_ADDR=0 CFG_NS_ENTRY_ADDR=0x80800000 \
                CFG_DT_ADDR=0x83000000 CFG_DDR_SIZE=0x20000000 \
                CFG_DT=y CFG_TEE_CORE_LOG_LEVEL=1 \
        "

OPTEE_ARCH_imx7s-warp = "arm32"

inherit image_sign_mbl
OPTEE="uTee.optee"
OPTEE_IMX="uTee.optee.imx"
OPTEE_CSF="optee_sign.csf"
OPTEE_ADDR="CONFIG_OPTEE_LOAD_ADDR"
BOARDNAME="warp7"
UBOOT_WARP_CFG="board/warp7/imximage.cfg.cfgtmp"

do_compile_prepend() {
	warp7_decrypt_private_key
	# TODO: remove once https://github.com/OP-TEE/optee_os/issues/2001
	# is resolved
	cp ${WARP7_KEY_NAME_DECRYPTED} ${B}/keys/default_ta.pem
}

_generate_signed_optee_image() {
    image_sign_mbl_binary ${D}/lib/firmware ${BOARDNAME} ${OPTEE} ${OPTEE_IMX} ${OPTEE_ADDR} ${OPTEE_CSF} imximage.cfg.cfgtmp
}

do_install_append() {
    uboot-mkimage -A arm -T optee -C none -d ${B}/out/arm-plat-${OPTEEOUTPUTMACHINE}/core/tee.bin ${D}/lib/firmware/uTee.optee
    _generate_signed_optee_image
}
