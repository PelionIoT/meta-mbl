# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

HOMEPAGE = "https://github.com/ARM-software/psa-arch-tests"

DESCRIPTION = "\
The Arm Platform Security Architecture Test Suite provides tests \
for implementations of PSA specifications. \
"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=2a944942e1496af1886903d274dedb13"

FULL_VERSION = "19.06_API0.9"
SOURCE_DIR_NAME = "${PN}-${FULL_VERSION}"
SRC_URI = " \
    https://github.com/ARM-software/psa-arch-tests/archive/v${FULL_VERSION}.tar.gz \
    file://0001-Support-absolute-directories-for-build-option.patch \
    file://0002-Don-t-require-linker-script-when-TEST_COMBINE_ARCHIV.patch \
    file://0003-Add-support-for-specifying-toolchain-using-environme.patch \
    file://0004-Add-support-for-targets-that-implement-the-C-standar.patch \
    file://0005-Don-t-define-32-bit-specific-code-if-we-don-t-need-t.patch \
    file://main.c;subdir=${SOURCE_DIR_NAME} \
"

SRC_URI[md5sum] = "4bcb1d70615f433b4a949a58354bb896"
SRC_URI[sha256sum] = "e69a05e77462ccf78ff91e012df378e4673eb06b94969209adf415a0d2b8238d"

S = "${WORKDIR}/${SOURCE_DIR_NAME}"
B = "${WORKDIR}/build"

# PACKAGECONFIG for this recipe is a list libraries that implement PSA APIs
# that can be tested.
PACKAGECONFIG ??= "mbedcrypto"
PACKAGECONFIG[mbedcrypto] = ",,mbed-crypto,mbed-crypto"

DEPENDS += "dos2unix-native bash-native"

PARALLEL_MAKE = ""

# The psa-arch-tests adds a layer of abstraction above platform specific code
# called the Platfor Abstraction Layer (PAL). TARGET is used to choose a
# platform specific implementation of the PAL. Here we choose the "stdc"
# implementation which just uses standard library functions like "printf"
# rather than having UART drivers and things like that.
TARGET = "tgt_dev_apis_stdc"

# Parse PACKAGECONFIG
python __anonymous() {
    configs = d.getVar('PACKAGECONFIG').strip().split()

    # For each config entry (library implementing a PSA API) we need to know:
    # 1. How to link the tests against the library. To specify this, add an
    #    option that should be passed to the linker to the PSA_LIB_OPTIONS
    #    variable.
    # 2. Which test suites can be run against the library. Add the suite
    #    name(s) to the SUITES variable.
    for config in configs:
        if config == "mbedcrypto":
            d.appendVar("PSA_LIB_OPTIONS", " -lmbedcrypto")
            d.appendVar("SUITES", " crypto")
}

do_configure() {
    # psa-arch-tests usually finds out which PSA APIs are implemented by
    # reading variables in the makefile for the platform.
    # The Linux psa-arch-tests platform makefile doesn't know which PSA libs
    # will be installed on the target, though, so we'll have to set those
    # variables as required before we build.

    platform_makefile=${S}/api-tests/platform/targets/${TARGET}/Makefile

    for suite in ${SUITES}; do
        config_var_name=$(echo "PSA_${suite}_IMPLEMENTED" | tr "[a-z]" "[A-Z]")
        sed -i -e "s/^${config_var_name}:=0/${config_var_name}:=1/" ${platform_makefile}
    done
}

do_compile() {
    # The psa-arch-tests build doesn't provide a main() function so we have to
    # build one ourselves and link it into each test suite we build
    compile_main_obj
    for suite in ${SUITES}; do
        compile_suite_libs ${suite}
        link_test_binary ${suite}
    done
}

# Compile libraries:
# * test_combine.a (contains code for a suite of tests)
# * pal_nspe.a (contains platform (Linux) specific code)
# * val_nspe.a (contains test runner code and code to glue the tests and the
#   platform specific code together)
#
# Args:
# $1: Name of test suite for which to build libraries
compile_suite_libs() {
    suite=${1:?}
    # Yes, the script that builds the libraries is called "setup.sh"
    ${S}/api-tests/tools/scripts/setup.sh \
        --source "${S}/api-tests" \
        --build "${B}" \
        --target ${TARGET} \
        --archive_tests \
        --suite "${suite}" \
        --toolchain ENV \
        --include "${STAGING_INCDIR}"
}

# Compile an object that provides a main() function
compile_main_obj() {
    ${CC} ${CFLAGS} -Wall -Werror -c -o main.o ${S}/main.c
}

# Link our main function and test libraries together to create an executable
#
# Args:
# $1: Name of test suite to link together
link_test_binary() {
    suite=${1:?}
    test_lib=${B}/BUILD/dev_apis/${suite}/test_combine.a
    val_lib=${B}/BUILD/val/val_nspe.a
    pal_lib=${B}/BUILD/platform/pal_nspe.a
    # Mention ${test_lib} twice due to circular dependencies
    ${CC} ${LDFLAGS} -o psa-arch-${suite}-tests main.o ${test_lib} ${val_lib} ${test_lib} ${pal_lib} ${PSA_LIB_OPTIONS}
}

do_install() {
    install -d ${D}${bindir}
    for suite in ${SUITES}; do
        install -m 755 ${B}/psa-arch-${suite}-tests ${D}${bindir}/
    done
}
