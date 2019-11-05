# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SRC_URI = "git://github.com/OP-TEE/optee_test.git;protocol=https"

# Tip of tree @ Version 3.6 for imx7 and rpi
SRCREV="40aacb6dc33bbf6ee329f40274bfe7bb438bbf53"

# Tell the xtest makefile to link against 32 bit openssl when verifying TAs
EXTRA_OEMAKE_append = " COMPILE_NS_USER=32 "
EXTRA_OEMAKE_remove_imx8mmevk-mbl = " COMPILE_NS_USER=32 "
