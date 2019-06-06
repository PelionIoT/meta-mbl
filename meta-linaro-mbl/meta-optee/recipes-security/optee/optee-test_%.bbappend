# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SRC_URI = "git://github.com/OP-TEE/optee_test.git \
           file://0001-Turn-off-GCC-format-overflow-checking-for-xtest.patch \
           "

# Tip of tree @ Version 3.4 for imx7 and rpi
SRCREV="e4f6f76b4cb5763112f4722981f84a26f4ac7e55"

FILESEXTRAPATHS_prepend := "${THISDIR}/optee-test:"

# Tell the xtest makefile to link against 32 bit openssl when verifying TAs
EXTRA_OEMAKE_append = " COMPILE_NS_USER=32 "
EXTRA_OEMAKE_remove_imx8mmevk-mbl = " COMPILE_NS_USER=32 "
