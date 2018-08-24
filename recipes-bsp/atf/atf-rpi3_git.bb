DESCRIPTION = "ARM Trusted Firmware for RaspberryPi3"
LICENSE = "BSD-3-Clause & Apache-2.0"
LIC_FILES_CHKSUM = "file://license.rst;md5=e927e02bca647e14efd87e9e914b2443 \
                    file://mbedtls/apache-2.0.txt;md5=3b83ef96387f14655fc854ddc3c6bd57"

# This recipe builds the ARM Trusted Firmware for RaspberryPi3. 
# - TF-A and OPTEE as 64-bit (aarch64) are built with the aarch64 toolchain
#   because the boot loader of VideoCore4 will boot to 64-bit ARM bootloaders.
#   The TF-A secure monitor changes to 32-bit mode before running U-Boot.
# - The recipe imports mbedtls into the ATF build directory to build libmbedtls.a 
#   and incorporated into the firmware.
DEPENDS += " coreutils-native u-boot openssl-native linaro-aarch64-toolchain-native "
SRC_URI = "git://github.com/ARM-software/arm-trusted-firmware.git;protocol=https;branch=master"
SRCREV = "3ba929571517347a12e027c629703ced0db0b255"
SRC_URI += " git://github.com/ARMmbed/mbedtls.git;protocol=https;branch=development;name=mbedtls;destsuffix=git/mbedtls "
SRCREV_mbedtls = "1ab9b5714852c6810c0a0bfd8c3b5c60a9a15482"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"
PARALLEL_MAKE=""
PLATFORM = "rpi3"

# LDFLAGS is configured in bitbake.conf as linker flags to be passed to CC. 
# It sets it to include "-Wl,-O1". The ATF build system inherits LDFLAGS 
# from the environment and passes it directly to LD when building BL1, 
# in conflict with the bitbake view. This then causes an error message
# in the ATF trace (aarch64-linux-gnu-ld.bfd: unrecognized option '-Wl,-O1').  
# This problem is avoided by clearing LDFLAGS.
LDFLAGS[unexport] = "1"

do_compile() {
    export PATH=${STAGING_DIR_NATIVE}/usr/bin/aarch64-linux-gnu/bin:$PATH

    # ATF requires BL32 (Trusted OS Firware) which will be optee-os.
    # However, optee-os has not been ported for RPI3 yet, so use
    # the u-boot.bin as a dummy binary to standing in for 
    # tee-header_v2.bin, tee-pager_v2.bin, tee-pageable_v2.bin in 
    # the FIP image. The real binaries will be used when available.
    cp ${DEPLOY_DIR_IMAGE}/u-boot.bin ${DEPLOY_DIR_IMAGE}/tee-header_v2.bin 
    cp ${DEPLOY_DIR_IMAGE}/u-boot.bin ${DEPLOY_DIR_IMAGE}/tee-pager_v2.bin 
    cp ${DEPLOY_DIR_IMAGE}/u-boot.bin ${DEPLOY_DIR_IMAGE}/tee-pageable_v2.bin 

    oe_runmake -C ${S} BUILD_BASE=${B} \
    CROSS_COMPILE=aarch64-linux-gnu- \
        BUILD_PLAT=${B}/${PLATFORM}/ \
        PLAT=${PLATFORM} \
        RPI3_BL33_IN_AARCH32=1 \
        BL33=${DEPLOY_DIR_IMAGE}/u-boot.bin \
        NEED_BL32=yes \
        BL32=${DEPLOY_DIR_IMAGE}/tee-header_v2.bin \
        BL32_EXTRA1=${DEPLOY_DIR_IMAGE}/tee-pager_v2.bin \
        BL32_EXTRA2=${DEPLOY_DIR_IMAGE}/tee-pageable_v2.bin \
        LOG_LEVEL=40 \
        CRASH_REPORTING=1 \
        SPD=opteed \
        GENERATE_COT=1 \
        TRUSTED_BOARD_BOOT=1 \
        USE_TBBR_DEFS=1 \
        MBEDTLS_DIR=mbedtls \
        all \
        fip

    # remove the dummy binaries
    rm ${DEPLOY_DIR_IMAGE}/tee-header_v2.bin 
    rm ${DEPLOY_DIR_IMAGE}/tee-pager_v2.bin 
    rm ${DEPLOY_DIR_IMAGE}/tee-pageable_v2.bin 
}


inherit deploy

do_deploy() {
    install -d ${DEPLOYDIR}
    install -D -p -m 0644 ${B}/${PLATFORM}/armstub8.bin ${DEPLOYDIR}/bcm2835-bootfiles/armstub8.bin
    install -D -p -m 0644 ${B}/${PLATFORM}/rot_key.pem ${DEPLOYDIR}/bcm2835-bootfiles/rot_key.pem
}

addtask do_deploy after do_compile before do_build
