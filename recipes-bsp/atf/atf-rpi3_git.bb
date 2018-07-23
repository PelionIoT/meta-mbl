DESCRIPTION = "ARM Trusted Firmware Rpi3"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://license.rst;md5=e927e02bca647e14efd87e9e914b2443"

DEPENDS += " coreutils-native optee-os u-boot openssl-native "

PARALLEL_MAKE=""

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/arm-trusted-firmware.git;protocol=https;branch=linaro-rpi3"
SRCREV = "598207c1c5b3d4061f4f39a2648a4555671bd611"
SRC_URI += " http://releases.linaro.org/components/toolchain/binaries/7.2-2017.11/aarch64-linux-gnu/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu.tar.xz;name=tc64 "
SRC_URI[tc64.md5sum] = "74451220ef91369da0b6e2b7534b0767"
SRC_URI[tc64.sha256sum] = "20181f828e1075f1a493947ff91e82dd578ce9f8638fbdfc39e24b62857d8f8d"
SRC_URI += " git://github.com/ARMmbed/mbedtls.git;protocol=https;branch=development;name=mbedtls;destsuffix=git/mbedtls "
SRCREV_mbedtls = "1ab9b5714852c6810c0a0bfd8c3b5c60a9a15482"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"
COMPATIBLE_MACHINE = "(raspberrypi3)"

PLATFORM_raspberrypi3 = "rpi3"

LDFLAGS[unexport] = "1"

do_compile() {
   export PATH=${WORKDIR}/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/bin:$PATH
   oe_runmake -C ${S} BUILD_BASE=${B} \
      CROSS_COMPILE=aarch64-linux-gnu- \
      BUILD_PLAT=${B}/${PLATFORM}/ \
      PLAT=${PLATFORM} \
      RPI3_BL33_IN_AARCH32=1 \
      BL33=${DEPLOY_DIR_IMAGE}/u-boot.bin \
      NEED_BL32=yes \
      BL32=${DEPLOY_DIR_IMAGE}/optee/tee-header_v2.bin \
      BL32_EXTRA1=${DEPLOY_DIR_IMAGE}/optee/tee-pager_v2.bin \
      BL32_EXTRA2=${DEPLOY_DIR_IMAGE}/optee/tee-pageable_v2.bin \
      LOG_LEVEL=40 \
      CRASH_REPORTING=1 \
      SPD=opteed \
      GENERATE_COT=1 \
      TRUSTED_BOARD_BOOT=1 \
      USE_TBBR_DEFS=1 \
      MBEDTLS_DIR=mbedtls \
      all \
      fip
      cp -f ${B}/${PLATFORM}/bl1.bin \
        ${B}/${PLATFORM}/bl1.pad.bin
      truncate --size=131072 ${B}/${PLATFORM}/bl1.pad.bin
      cat ${B}/${PLATFORM}/bl1.pad.bin ${B}/${PLATFORM}/fip.bin > ${B}/${PLATFORM}/armstub8.bin
}

do_install() {
    install -D -p -m 0644 ${B}/${PLATFORM}/armstub8.bin ${D}/usr/lib/atf-rpi3/armstub8.bin
    install -D -p -m 0644 ${B}/${PLATFORM}/armstub8.bin ${DEPLOY_DIR_IMAGE}/armstub8.bin
    install -D -p -m 0644 ${B}/${PLATFORM}/armstub8.bin ${DEPLOY_DIR_IMAGE}/bcm2835-bootfiles/armstub8.bin
    install -D -p -m 0644 ${B}/${PLATFORM}/rot_key.pem ${DEPLOY_DIR_IMAGE}/rot_key.pem
}

FILES_${PN} += " /usr/lib/atf-rpi3/armstub8.bin "
