# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Symbol Defintions
#
# MBL_FIT_BIN_FILENAME
#   The FIP file name.
#
# MBL_UBOOT_CMD_FILENAME
#   The name of the u-boot boot command file name.
#
# MBL_KEYSTORE_DIR
#   The directory containing the rot_key.pem file, for example.
#
# MBL_FIT_ROT_KEY_FILENAME
#   The FIT Root of Trust signing key file name.

MBL_UBOOT_CMD_FILENAME ?= "boot.cmd"
MBL_FIT_BIN_FILENAME ?= "boot.scr"
MBL_KEYSTORE_DIR ?= "${DEPLOY_DIR_IMAGE}"
MBL_FIT_ROT_KEY_FILENAME ?= "mbl-fit-rot-key"
