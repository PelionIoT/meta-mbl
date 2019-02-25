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

# This is the default name for the ARM Trusted Firmware (ATF) Firmware Image
# Package (FIP)
# binary name. The MBL FIP image typically contains:
# - BL31.
# - BL32 (OPTEE).
# - BL33 (u-boot).
# - Trusted Key Certificate.
# - SoC FW Key Certificate.
# - Trusted OS FW Key Certificate.
# - Non-Trusted FW Key Certificate.
# - Trusted OS FW Content Certificate.
# - Non-Trusted OS FW Content Certificate.
# - U-boot Device Tree Binary (DTB).
# - U-Boot Flattened Image Tree (FIT) verification key.
MBL_FIP_BIN_FILENAME = "fip.bin"

# This is the default name for the ARM Trusted Firmware (ATF) unified
# Firmware Image Package (FIP) binary name. Typically, this is the binary
# run by the SoC vendor bootrom and is the first image that a third party
# developer has control over.
MBL_UNIFIED_BIN = "atf-bl2-fip.bin"

# This is the name of the ARM Trusted Firmware (ATF) Firmware Image Package
# (FIP) manipulation tool use for creating FIP images and adding/removing
# objects.
MBL_FIPTOOL_NAME = "fiptool"

# This is the content certificate for the trusted-world Trusted Boot Firmware
# (i.e. BL2). The content certificate contains the BL2 hash used to
# authenticate the image.
# - This certificate is signed by the ROTPrvK.
# - This certificate is present in the FIP image. fiptool refers to this FIP
# image component using the --tb-fw-cert option.
TRUSTED_BOOT_FW_CERT = "tb_fw.crt"

# This contains the trusted world signing public key trusted_world_pk for
# authenticating certificates chains of trusted world components. The
# associated private key is used to sign the following certificates:
#     - TRUSTED-OS-FW-KEY-CERT.
#     - SOC-FW-KEY-CERT.
# This certificate also contains the non-trusted world public signing key
# non_trusted_world_pk.
# The associated private key is used to sign the following certificates for
# non-trusted world components:
#      - NON-TRUSTED-FW-KEY-CERT.
# - This certificate is present in the FIP image. fiptool refers to this FIP
# image component using the --trusted-key-cert option.
# - This certificate is signed by the ROT private key.
TRUSTED_KEY_CERT = "trusted_key.crt"
