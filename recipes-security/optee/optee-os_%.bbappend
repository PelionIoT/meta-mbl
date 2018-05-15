
DEPENDS += " u-boot-mkimage-native "

SRCREV_imx7s-warp-mbl="b207787cd6055f78e15a05eb8c43fbc88910087f"
SRCREV_bananapi-zero="f6fe6bb55ae9ad1b56f03051c1b1db23c64d3177"
SRC_URI="git://git.linaro.org/landing-teams/working/mbl/optee_os.git;protocol=https;nobranch=1 \
file://0001-allow-setting-sysroot-for-libgcc-lookup.patch \
"

BB_STRICT_CHECKSUM = "0"

OPTEEMACHINE_imx7s-warp-mbl="imx-mx7swarp7"
OPTEEOUTPUTMACHINE_imx7s-warp-mbl="imx"
OPTEEMACHINE_bananapi-zero="sunxi-sun8i_h2_plus_bananapi_m2_zero"
OPTEEOUTPUTMACHINE_bananapi-zero="sunxi"

EXTRA_OEMAKE_imx7s-warp-mbl = "PLATFORM=${OPTEEMACHINE} \
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

EXTRA_OEMAKE_bananapi-zero = "PLATFORM=${OPTEEMACHINE} \
                CROSS_COMPILE_core=${HOST_PREFIX} \
                CROSS_COMPILE_ta_arm32=${HOST_PREFIX} \
                NOWERROR=1 \
                LDFLAGS= \
                LIBGCC_LOCATE_CFLAGS=--sysroot=${STAGING_DIR_HOST} \
                CFG_DT=y CFG_TEE_CORE_LOG_LEVEL=1 \
        "

OPTEE_ARCH_imx7s-warp-mbl = "arm32"
OPTEE_ARCH_bananapi-zero = "arm32"

do_install_append() {
    uboot-mkimage -A arm -T kernel -O tee -C none -d ${B}/out/arm-plat-${OPTEEOUTPUTMACHINE}/core/tee.bin ${D}/lib/firmware/uTee.optee
}
