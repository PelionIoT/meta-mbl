# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SRC_URI = "git://github.com/OP-TEE/optee_test.git"

# Tip of tree @ Version 3.4 for imx7 and rpi
SRCREV="e4f6f76b4cb5763112f4722981f84a26f4ac7e55"

# Version 3.2 for imx8
SRCREV_imx8mmevk-mbl="c0e8678b55d399956da0bdce5b1f25c49839172c"

FILESEXTRAPATHS_prepend := "${THISDIR}/optee-test:"

# Apply backports of OP-TEE xtest fixes to 3.2
SRC_URI_append_imx8mmevk-mbl = " file://0013-xtest-prevent-unexpected-build-warning-with-strncpy.patch \
			file://0014-regression-4011-correct-potential-overflow.patch \
			file://0018-regression-4000-fix-uninitialized-local-variable.patch \
			file://0020-regression-6000-fix-uninitialized-local-variables.patch \
"

# Tell the xtest makefile to link against 32 bit openssl when verifying TAs
EXTRA_OEMAKE_append = " COMPILE_NS_USER=32 "
EXTRA_OEMAKE_remove_imx8mmevk-mbl = " COMPILE_NS_USER=32 "
