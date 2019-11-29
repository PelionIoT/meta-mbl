# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Version 3.7.0
SRCREV="227d6f4c40eaa6f84fe049b9e48c7b27ad7fab08"

# Tell the xtest makefile to link against 32 bit openssl when verifying TAs
EXTRA_OEMAKE_append = " COMPILE_NS_USER=32 "
EXTRA_OEMAKE_remove_imx8mmevk-mbl = " COMPILE_NS_USER=32 "
