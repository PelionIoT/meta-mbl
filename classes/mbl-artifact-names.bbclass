# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

###############################################################################
# mbl-artifact-names.bbclass
#  This class defines default values for artifact names used in MBL recipes,
#  so names are defined in one place and can be used multiple times in 
#  multiple recipes. The purpose is to facilitate future recipe maintenance
#  as a name change is localised to a change in this file.
###############################################################################

# This is the FIT file name that is added to IMAGE_BOOT_FILES used by
# WIC to create the device boot partition.
# - A number of BSPs often use boot.scr as the name of the u-boot boot
#   script (a text file). However in MBL, the boot script is combined with
#   the kernel, initramfs, and DTB(s) (for example) to create a FIT image file.
#   Therefore MBL uses boot.scr as the FIT image name.
# - FIT image artifacts are generated with standardised filenames by
#   kernel-fitimage.bbclass and mbl-fitimage.bbclass. For example, "fitImage-"
#   is prepended to the artifact names. These images are stored in the
#   DEPLOY_DIR_IMAGE directory. The FIT image naming conventions
#   are bootloader agnostic and hence don't use boot.scr.
MBL_FIT_BIN_FILENAME = "boot.scr"

# The name of the u-boot boot command file name.
MBL_UBOOT_CMD_FILENAME = "boot.cmd"


