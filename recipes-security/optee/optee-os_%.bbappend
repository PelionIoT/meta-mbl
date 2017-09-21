
DEPENDS += " u-boot-mkimage-native "

SRCBRANCH="linaro-warp7"
SRCREV="${SRCBRANCH}"
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
        "
	
OPTEE_ARCH_imx7s-warp = "arm32"

do_uboot_image() {
    uboot-mkimage -A arm -T optee -C none -d ${B}/out/arm-plat-${OPTEEOUTPUTMACHINE}/core/tee.bin ${D}/lib/firmware/uTee.optee
}

addtask uboot_image before do_deploy after do_install
