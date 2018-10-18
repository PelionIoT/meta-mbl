DESCRIPTION = "ARM Trusted Firmware for RaspberryPi3"

# Licensing: 
# - ARM Trusted Firmware is licensed under BSD-3-Clause.
# - mbedtls is licensed under Apache-2.0.
LICENSE = "BSD-3-Clause & Apache-2.0"
LIC_FILES_CHKSUM = "file://license.rst;md5=e927e02bca647e14efd87e9e914b2443 \
                    file://mbedtls/apache-2.0.txt;md5=3b83ef96387f14655fc854ddc3c6bd57"

# This recipe builds the ARM Trusted Firmware for RaspberryPi3. 
# - TF-A and OPTEE as 64-bit (aarch64) are built with the aarch64 toolchain
#   because the boot loader of VideoCore4 will boot to 64-bit ARM bootloaders.
#   The TF-A secure monitor changes to 32-bit mode before running U-Boot.
# - The recipe imports mbedtls into the ATF build directory to build libmbedtls.a 
#   and incorporated into the firmware.
DEPENDS += " coreutils-native u-boot openssl-native linaro-aarch64-toolchain-native optee-os "
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
    export PATH=${STAGING_DIR_NATIVE}${bindir}/aarch64-linux-gnu/bin:$PATH
    # Due to LDFLAGS is unexported to solve the build fail, we need to
    # manually add the libdir back. As well as changing the LDLIBS to
    # link to the libraries we want.
    export LD_LIBRARY_PATH=${STAGING_DIR_NATIVE}${libdir}:$LD_LIBRARY_PATH

    oe_runmake -C ${S}/tools/fiptool \
        LDLIBS="-lcrypto -L${STAGING_DIR_NATIVE}${libdir}" \
        INCLUDE_PATHS="-I../../include/tools_share -I${STAGING_DIR_NATIVE}${includedir}"

    # We build cert_create here prior because we need to change the OPENSSL_DIR for using
    # the lib from openssl-native. And disable build of the cert_create later when building ATF.
    oe_runmake -C ${S}/tools/cert_create \
        PLAT=${PLATFORM} \
        OPENSSL_DIR="${STAGING_DIR_NATIVE}/usr"

    # CRTTOOLPATH set to fiptool is a workaround to stop rebuild cert_create tool.
    # It is because the Makefile of cert_create tool "all" target always runs clean, but
    # fiptool's Makefile doesn't do it.
    # And since we change the CRTTOOLPATH, in order to find cert_create we have to also
    # modify CRTTOOL variable.
    # Both fiptool and cert_create is a .PHONY target so build it in other native recipe
    # doesn't stop us to use these workarounds.
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
        MBEDTLS_DIR=mbedtls \
        LOG_LEVEL=40 \
        CRASH_REPORTING=1 \
        SPD=opteed \
        GENERATE_COT=1 \
        TRUSTED_BOARD_BOOT=1 \
        USE_TBBR_DEFS=1 \
        CRTTOOLPATH=${S}/tools/fiptool \
        CRTTOOL=${S}/tools/cert_create/cert_create \
        all fip
}

inherit deploy

do_deploy() {
    install -D -p -m 0644 ${B}/${PLATFORM}/armstub8.bin ${DEPLOY_DIR_IMAGE}/bcm2835-bootfiles/armstub8.bin
    install -D -p -m 0644 ${B}/${PLATFORM}/rot_key.pem ${DEPLOY_DIR_IMAGE}/rot_key.pem
}

addtask deploy before do_build after do_install
