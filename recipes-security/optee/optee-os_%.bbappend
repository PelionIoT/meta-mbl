
DEPENDS += " u-boot-mkimage-native "

SRCREV_imx7s-warp-mbl="0ab9388c0d553a6bb5ae04e41b38ba40cf0474bf"
SRCREV_bananapi-zero="f6fe6bb55ae9ad1b56f03051c1b1db23c64d3177"
SRCREV_raspberrypi3="79418b516aa1bedc042f633a9fec9ec9b9bd4f03"
SRC_URI="git://git.linaro.org/landing-teams/working/mbl/optee_os.git;protocol=https;nobranch=1 \
file://0001-allow-setting-sysroot-for-libgcc-lookup.patch \
"

SRC_URI_append_raspberrypi3 = " http://releases.linaro.org/components/toolchain/binaries/7.2-2017.11/aarch64-linux-gnu/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu.tar.xz;name=tc64 http://releases.linaro.org/components/toolchain/binaries/7.2-2017.11/arm-linux-gnueabihf/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf.tar.xz;name=tc32 "
SRC_URI[tc64.md5sum] = "74451220ef91369da0b6e2b7534b0767"
SRC_URI[tc64.sha256sum] = "20181f828e1075f1a493947ff91e82dd578ce9f8638fbdfc39e24b62857d8f8d"
SRC_URI[tc32.md5sum] = "b8429fe715458a88632f9d936ff52c6a"
SRC_URI[tc32.sha256sum] = "cee0087b1f1205b73996651b99acd3a926d136e71047048f1758ffcec69b1ca2"

BB_STRICT_CHECKSUM = "0"

OPTEEMACHINE_imx7s-warp-mbl="imx-mx7swarp7"
OPTEEOUTPUTMACHINE_imx7s-warp-mbl="imx"
OPTEEMACHINE_bananapi-zero="sunxi-sun8i_h2_plus_bananapi_m2_zero"
OPTEEOUTPUTMACHINE_bananapi-zero="sunxi"
OPTEEMACHINE_raspberrypi3="rpi3"
OPTEEOUTPUTMACHINE_raspberrypi3="rpi3"

EXTRA_OEMAKE_imx7s-warp-mbl = "PLATFORM=${OPTEEMACHINE} \
                CROSS_COMPILE_core=${HOST_PREFIX} \
                CROSS_COMPILE_ta_arm32=${HOST_PREFIX} \
                NOWERROR=1 \
                ta-targets=ta_arm32 \
                LDFLAGS= \
                LIBGCC_LOCATE_CFLAGS=--sysroot=${STAGING_DIR_HOST} \
                CFG_PAGEABLE_ADDR=0 CFG_NS_ENTRY_ADDR=0x87800000 \
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

EXTRA_OEMAKE_raspberrypi3 = "PLATFORM=${OPTEEMACHINE} \
		CROSS_PREFIX=aarch64-linux-gnu- \
                CROSS_COMPILE_ta_arm32=${HOST_PREFIX} \
		ARCH=arm \
                NOWERROR=1 \
                LDFLAGS= \
                LIBGCC_LOCATE_CFLAGS=--sysroot=${STAGING_DIR_HOST} \
                CFG_DT=y CFG_DT_ADDR=0x03000000 \
		CFG_TEE_CORE_LOG_LEVEL=1 CFG_ARM64_core=y \
        "

OPTEE_ARCH_imx7s-warp-mbl = "arm32"
OPTEE_ARCH_bananapi-zero = "arm32"
OPTEE_ARCH_raspberrypi3 = "arm32"

do_compile_prepend() {
   export PATH=${WORKDIR}/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/bin:${WORKDIR}/gcc-linaro-6.4.1-2017.08-x86_64_arm-linux-gnueabihf/bin:$PATH
}
