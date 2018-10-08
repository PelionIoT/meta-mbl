
DEPENDS += " u-boot-mkimage-native "
DEPENDS_append_raspberrypi3-mbl = " linaro-aarch64-toolchain-native "

SRCREV="62b4cdb5e8895a6b0c477ea9f1cecdb5514e2f87"
SRC_URI="git://github.com/OP-TEE/optee_os.git;protocol=https;nobranch=1 \
file://0001-allow-setting-sysroot-for-libgcc-lookup.patch \
"
OPTEEMACHINE_imx7s-warp-mbl="imx-mx7swarp7"
OPTEEOUTPUTMACHINE_imx7s-warp-mbl="imx"
OPTEEMACHINE_raspberrypi3-mbl="rpi3"
OPTEEOUTPUTMACHINE_raspberrypi3-mbl="rpi3"

# PLATFORM: choose the platform. The platform normally be "soc-board" type.
# CROSS_COMPILE_ta_arm32: Set the cross-compiler for 32-bit TA.
EXTRA_OEMAKE = "PLATFORM=${OPTEEMACHINE} \
                CROSS_COMPILE_ta_arm32=${HOST_PREFIX} \
                NOWERROR=1 \
                LDFLAGS= \
                LIBGCC_LOCATE_CFLAGS=--sysroot=${STAGING_DIR_HOST} \
         "

# CROSS_COMPILE_core: Set the cross-compiler for OPTEE core.
# ta-targets: Set the ta-targets. On WaRP7 it should be ta_arm32 for 32-bit TA.
# CFG_PAGEABLE_ADDR: Set pageable address. Note that pageable is currently not
#                    using on WaRP7. So we set it to 0.
# CFG_NS_ENTRY_ADDR: Set the Non-secure entry address. Should be the address of
#                    the kernel.
# CFG_DT: Enable device tree support.
# CFG_DT_ADDR: The address of the device tree.
# CFG_DDR_SIZE: Set the size of the DDR.
# CFG_TEE_CORE_LOG_LEVEL: Set the log level to 1 (only show ERROR). 4 is
#                         most verbose but will let xtest output too many
#                         things.
EXTRA_OEMAKE_append_imx7s-warp-mbl = " \
                CROSS_COMPILE_core=${HOST_PREFIX} \
                ta-targets=ta_arm32 \
                CFG_PAGEABLE_ADDR=0 CFG_NS_ENTRY_ADDR=0x87800000 \
                CFG_DT_ADDR=0x83000000 CFG_DDR_SIZE=0x20000000 \
                CFG_DT=y CFG_TEE_CORE_LOG_LEVEL=1 \
                CFG_TEE_CORE_NB_CORE=1 \
        "

# CROSS_COMPILE_core: Set the cross-compiler for OPTEE core. On RPi3 it should
#                     be 64-bit because RPi3 boots with 64-bit. But for TA
#                     it supports 32-bit TA. Thus CROSS_COMPILE_ta_arm32
#                     still sets to ${HOST_PREFIX}
# CFG_ARM64_core: set OPTEE core to be in ARM64 rather than ARM32.
# CFG_DT: Enable device tree support.
# CFG_DT_ADDR: The address of the device tree.
# CFG_TEE_CORE_LOG_LEVEL: Set the log level to 1 (only show ERROR). 4 is
#                         most verbose but will let xtest output too many
#                         things.
EXTRA_OEMAKE_append_raspberrypi3-mbl = " \
                CROSS_COMPILE_core=aarch64-linux-gnu- \
                CFG_DT=y CFG_DT_ADDR=0x03000000 \
                CFG_TEE_CORE_LOG_LEVEL=1 \
                CFG_ARM64_core=y \
        "

OPTEE_ARCH = "arm32"

do_compile_prepend_raspberrypi3-mbl() {
   export PATH=${STAGING_DIR_NATIVE}/${bindir}/aarch64-linux-gnu/bin:$PATH
}

do_install_append() {
    uboot-mkimage -A arm -T kernel -O tee -C none -d ${B}/out/arm-plat-${OPTEEOUTPUTMACHINE}/core/tee.bin ${D}/lib/firmware/uTee.optee
}
