# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

HOMEPAGE = "https://github.com/ARMmbed/mbed-crypto"
DESCRIPTION = "Mbed Crypto is a reference implementation of the Arm PSA Crypto API "

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://${WORKDIR}/git/LICENSE;md5=302d50a6369f5f22efdb674db908167a \
    file://${WORKDIR}/git/apache-2.0.txt;md5=3b83ef96387f14655fc854ddc3c6bd57 \
"

SECTION = "libs"

# Use mbed-crypto fork with mbl-crypto-storage-example-app
# This is a temporary measure.
SRC_URI = "git://git@github.com/simonqhughes/mbed-crypto.git;protocol=ssh;nobranch=1"
SRCREV = "1c18f737d088574e86d86ec98b2fb9f2adab17d7"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

# We add a '-test' package here, but ideally we'd be using the ptest framework.
# MBL has an issue where enabling the ptest DISTRO_FEATURE results in
# dependency cycles (meta-mbl GitHub issue #577), so leave ptest for later.
PACKAGES =+ "${PN}-programs ${PN}-test"

# python3 is used to do code gen when building mbed-crypto
# perl is used to generate tests
#
# Normally BitBake would just let recipes use the host's python and perl
# binaries, but the cmake class blocks CMake from finding these so we need to
# make sure there are python and perl binaries in the recipe's native
# sysroot...
DEPENDS += "python3-native perl-native"

# ...we also need to add the paths to the python and perl binaries to CMake's
# search path. inheriting these classes does that.
inherit python3native
inherit perlnative

RDEPENDS_${PN}-programs += "${PN}"
RDEPENDS_${PN}-test += "${PN}"

inherit cmake

# Build both static and shared libraries. The static libs will end up in the
# ${PN}-staticdev package.
EXTRA_OECMAKE += "\
 -DLIB_INSTALL_DIR:STRING=${libdir} \
 -DUSE_SHARED_MBEDTLS_LIBRARY=ON \
 -DUSE_STATIC_MBEDTLS_LIBRARY=ON \
"

FILES_${PN}-programs = "${bindir}/"

# Similar to where ptest files end up
TEST_INSTALL_DIR = "${libdir}/${BPN}/test"
FILES_${PN}-test = "${TEST_INSTALL_DIR}/"

do_install_append() {
    install -d ${D}${TEST_INSTALL_DIR}

    # The tests dir in the build dir has a bunch of stuff we don't want, but
    # each test comes with a ".datax" data file and we can use the names of
    # those data files to enumerate the tests in the test dir.
    for test_data in ${B}/tests/*.datax; do
        test_binary=${B}/tests/$(basename "$test_data" .datax)

        install -m755 -t ${D}${TEST_INSTALL_DIR} ${test_binary}
        install -m644 -t ${D}${TEST_INSTALL_DIR} ${test_data}

        # The test binaries in the build dir will have an RPATH pointing back into
        # the library directory of the build dir. That doesn't make sense once
        # we install them so get rid of it. We don't need an RPATH at all
        # because the mbed-crypto library will be in a standard place on the
        # target.
        chrpath -d ${D}${TEST_INSTALL_DIR}/$(basename ${test_binary})
    done

    # There's more test data required in the data_files directory
    for data_file in $(cd ${B}/tests; find -L data_files -type f); do
        install -m644 -D ${B}/tests/${data_file} ${D}${TEST_INSTALL_DIR}/${data_file}
    done
}
