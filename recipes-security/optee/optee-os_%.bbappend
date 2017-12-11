
DEPENDS += " u-boot-mkimage-native "

SRCREV="b207787cd6055f78e15a05eb8c43fbc88910087f"
SRC_URI="git://git@github.com/ARMmbed/mbl-optee_os.git;protocol=ssh;nobranch=1 \
file://0001-allow-setting-sysroot-for-libgcc-lookup.patch \
"
OPTEEMACHINE="imx-mx7swarp7"
OPTEEOUTPUTMACHINE="imx"

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

OPTEE_ARCH_imx7s-warp-mbl = "arm32"

do_install_append() {
    uboot-mkimage -A arm -T optee -C none -d ${B}/out/arm-plat-${OPTEEOUTPUTMACHINE}/core/tee.bin ${D}/lib/firmware/uTee.optee
}
