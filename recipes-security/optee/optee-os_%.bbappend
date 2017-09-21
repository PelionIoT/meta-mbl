
DEPENDS += " u-boot-mkimage-native "

SRCBRANCH="linaro-warp7"
SRCREV="8e7cfe09dfc6d75f70716250422a5edc973de1ca"
SRC_URI="git://git@github.com/ARMmbed/mbl-optee_os.git;protocol=ssh;branch=${SRCBRANCH} \
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
                CFG_DT=y DEBUG=y CFG_TEE_CORE_LOG_LEVEL=4 \
        "

OPTEE_ARCH_imx7s-warp = "arm32"

do_uboot_image() {
    uboot-mkimage -A arm -T optee -C none -d ${B}/out/arm-plat-${OPTEEOUTPUTMACHINE}/core/tee.bin ${D}/lib/firmware/uTee.optee
}

addtask uboot_image before do_deploy after do_install
