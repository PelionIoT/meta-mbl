# Copyright (c) 2018-2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

inherit mbl-artifact-names

# ------------------------------------------------------------------------------
# If you change the names or values of these variables then make sure they are
# still compatible with the .wks files in the wic directory and
# recipes-core/base-files/files/fstab.
# ------------------------------------------------------------------------------

# Offsets of paritions should generally be flash erase block boundaries so that
# writing to one partition is less likely to affect another partition, so we
# have a variable for the flash erase block size from which to derive partition
# offsets. The default value, 16MiB (16384KiB), is a fairly conservative erase
# block size estimate. A more typical size for eMMC and SD Cards is 4MiB.
#
# Override this in a MACHINE's config when you have more accurate information
# for that MACHINE.
#
# Override this in local.conf if your MACHINE uses removable storage media
# (e.g. SD Cards) and you know the erase block sizes of the removal media that
# will be used in your case.
MBL_FLASH_ERASE_BLOCK_SIZE_KiB ?= "16384"


# We have two different flavours of "partition" in MBL:
# * Normal file system partitions, recorded in the partition table.
# * Raw non-file system "partitions", not recorded in the partition table.

# ------------------------------------------------------------------------------
# Normal file system partitions, recorded in the partition table
# ------------------------------------------------------------------------------
MBL_PARTITIONS = "\
    ROOT \
    BOOT \
    BOOTFLAGS \
    FACTORY_CONFIG \
    NON_FACTORY_CONFIG \
    LOG \
    SCRATCH \
    HOME \
"

# For each <partition> in MBL_PARTITIONS, we define the following variables:
# * MBL_<partition>_MOUNT_POINT # Mountpoint for partition
# * MBL_<partition>_LABEL # Default label of partition (without any suffix for the bank)
# * MBL_<partition>_SIZE_MiB # Default size of partition in Mebibytes
# * MBL_<partition>_ALIGN_KiB # Default alignment of partition in Kibibytes
#
# ------------------------------------------------------------------------------
# Root partition (two banks)
# ------------------------------------------------------------------------------
MBL_ROOT_MOUNT_POINT = "/"
MBL_ROOT_PARTITION_LABEL ?= "rootfs"
MBL_ROOT_PARTITION_SIZE_MiB ?= "500"
MBL_ROOT_PARTITION_ALIGN_KiB ?= "${MBL_FLASH_ERASE_BLOCK_SIZE_KiB}"

# ------------------------------------------------------------------------------
# Boot partition
# ------------------------------------------------------------------------------
MBL_BOOT_MOUNT_POINT = "${MBL_BOOT_DIR}"
MBL_BOOT_PARTITION_LABEL ?= "boot"
MBL_BOOT_PARTITION_SIZE_MiB ?= "32"
MBL_BOOT_PARTITION_ALIGN_KiB ?= "${MBL_FLASH_ERASE_BLOCK_SIZE_KiB}"

# ------------------------------------------------------------------------------
# Bootflags partition
# ------------------------------------------------------------------------------
MBL_BOOTFLAGS_MOUNT_POINT = "${MBL_BOOTFLAGS_DIR}"
MBL_BOOTFLAGS_PARTITION_LABEL ?= "bootflags"
MBL_BOOTFLAGS_PARTITION_SIZE_MiB ?= "20"
MBL_BOOTFLAGS_PARTITION_ALIGN_KiB ?= "${MBL_FLASH_ERASE_BLOCK_SIZE_KiB}"

# ------------------------------------------------------------------------------
# Factory config partition
# ------------------------------------------------------------------------------
MBL_FACTORY_CONFIG_MOUNT_POINT = "${MBL_FACTORY_CONFIG_DIR}"
MBL_FACTORY_CONFIG_PARTITION_LABEL ?= "factory_config"
MBL_FACTORY_CONFIG_PARTITION_SIZE_MiB ?= "20"
MBL_FACTORY_CONFIG_PARTITION_ALIGN_KiB ?= "${MBL_FLASH_ERASE_BLOCK_SIZE_KiB}"

# ------------------------------------------------------------------------------
# Non factory config partitions (two banks)
# ------------------------------------------------------------------------------
MBL_NON_FACTORY_CONFIG_MOUNT_POINT = "${MBL_NON_FACTORY_CONFIG_DIR}"
MBL_NON_FACTORY_CONFIG_PARTITION_LABEL ?= "nfactory_config"
MBL_NON_FACTORY_CONFIG_PARTITION_SIZE_MiB ?= "20"
MBL_NON_FACTORY_CONFIG_PARTITION_ALIGN_KiB ?= "${MBL_FLASH_ERASE_BLOCK_SIZE_KiB}"

# ------------------------------------------------------------------------------
# Log partition
# ------------------------------------------------------------------------------
MBL_LOG_MOUNT_POINT = "${MBL_LOG_DIR}"
MBL_LOG_PARTITION_LABEL ?= "log"
MBL_LOG_PARTITION_SIZE_MiB ?= "20"
MBL_LOG_PARTITION_ALIGN_KiB ?= "${MBL_FLASH_ERASE_BLOCK_SIZE_KiB}"

# ------------------------------------------------------------------------------
# Scratch partition
# ------------------------------------------------------------------------------
MBL_SCRATCH_MOUNT_POINT = "${MBL_SCRATCH_DIR}"
MBL_SCRATCH_PARTITION_LABEL ?= "scratch"
MBL_SCRATCH_PARTITION_SIZE_MiB ?= "500"
MBL_SCRATCH_PARTITION_ALIGN_KiB ?= "${MBL_FLASH_ERASE_BLOCK_SIZE_KiB}"

# ------------------------------------------------------------------------------
# Home partition
# ------------------------------------------------------------------------------
MBL_HOME_MOUNT_POINT = "${MBL_HOME_DIR}"
MBL_HOME_PARTITION_LABEL ?= "home"
MBL_HOME_PARTITION_SIZE_MiB ?= "450"
MBL_HOME_PARTITION_ALIGN_KiB ?= "${MBL_FLASH_ERASE_BLOCK_SIZE_KiB}"


# ------------------------------------------------------------------------------
# Raw non-file system "partitions" not recorded in the partition table
# ------------------------------------------------------------------------------
# For each of the BL2 and BL3 bootloaders we usually write an image file to raw
# flash storage. Some platforms are different though:
# * On Raspberry Pi 3, BL2 must be in the first FAT file system partition.
# * On Platforms that have only been partially ported to use MBL's secure boot
#   scheme, we may have other requirements, e.g. a U-Boot SPL image.
#
# To allow for this, we have variables to specify two bootloader images in the
# .wks file:
# * MBL_WKS_BOOTLOADER1_FILENAME
# * MBL_WKS_BOOTLOADER2_FILENAME
#
# The names "WKS_BOOTLOADER1" and "WKS_BOOTLOADER2" have been chosen to
# distinguish them from the TF-A concepts of "BL2" and "BL3" - in the normal
# (and default) case, "WKS_BOOTLOADER1" will correspond with an image
# containing TF-A BL2 and "WKS_BOOTLOADER2" will correspond with an image
# containing TF-A BL3, OP-TEE and U-Boot, but this need not be the case.
#
# Each of these partitions can be removed from the .wks file by setting the
# MBL_WKS_SKIP_BOOTLOADERx variable to "1" which causes an
# MBL_WKS_COMMENT_IF_SKIP_BOOTLOADERx to be set to be the WKS comment leader
# "#" so that the line for that partition gets commented out of the .wks file.
#
# Each of these partitions also has an "MBL_WKS_BOOTLOADERx_ALIGN_KiB" variable
# to specify where it should live in flash.

MBL_WKS_BOOTLOADER1_FILENAME ?= "${MBL_BL2_FILENAME}"
MBL_WKS_COMMENT_IF_SKIP_BOOTLOADER1 = "${@ "# " if d.getVar("MBL_WKS_SKIP_BOOTLOADER1") else "" }"

# Don't set a default value for MBL_WKS_BOOTLOADER1_ALIGN_KiB - there's no
# sensible default - the position of the first bootloader is generally fixed by
# the board manufacturer.

MBL_WKS_BOOTLOADER2_FILENAME ?= "${MBL_FIP_BIN_FILENAME}"
MBL_WKS_BOOTLOADER2_ALIGN_KiB ?= "${MBL_FLASH_ERASE_BLOCK_SIZE_KiB}"
MBL_WKS_COMMENT_IF_SKIP_BOOTLOADER2 = "${@ "# " if d.getVar("MBL_WKS_SKIP_BOOTLOADER2") else "" }"

python __anonymous() {
    skip_wks_bootloader1 = d.getVar("MBL_WKS_SKIP_BOOTLOADER1", True)
    wks_bootloader1_align_KiB = d.getVar("MBL_WKS_BOOTLOADER1_ALIGN_KiB", True)
    if not skip_wks_bootloader1 and not wks_bootloader1_align_KiB:
            bb.fatal("MBL_WKS_BOOTLOADER1_ALIGN_KiB has not been set")
}
