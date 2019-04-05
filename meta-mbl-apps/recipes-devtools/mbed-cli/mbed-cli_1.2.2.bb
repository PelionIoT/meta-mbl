# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

LICENSE="Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4336ad26bb93846e47581adc44c4514d"


FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " file://mbed-wrapper "

SRC_URI[md5sum] = "2f708ca555151133afb8bf7267be6df6"

PYPI_PACKAGE = "mbed-cli"
PYPI_PACKAGE_EXT = "zip"

inherit setuptools pypi

NONWRAPPED_MBED_PATH = "${bindir}/mbed"
WRAPPED_MBED_PATH = "${bindir}/wrapped_mbed"

# Replace the mbed script with our wrapper script that can deal with the mbed
# script having a shebang line longer than the kernel can cope with
do_install_append() {
    mv "${D}${NONWRAPPED_MBED_PATH}" "${D}${WRAPPED_MBED_PATH}"
    install "${WORKDIR}/mbed-wrapper" "${D}${NONWRAPPED_MBED_PATH}"
}

# Tell the wrapper script what the path to the wrapped script is by replacing
# some placeholder text in the wrapper script.  Note that ${WRAPPED_MBED_PATH}
# is being used here without a preceding ${D}. This is because the build system
# itself will insert a placeholder "FIXMESTAGINGDIRHOST" into
# ${WRAPPED_MBED_PATH} that will be substituted later to make the script's
# final resting place.
MBL_VAR_PLACEHOLDER_FILES = "${D}${NONWRAPPED_MBED_PATH}"
inherit mbl-var-placeholders

BBCLASSEXTEND = "native"
