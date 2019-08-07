# Copyright (c) 2018-2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

inherit mbl-artifact-names

# ------------------------------------------------------------------------------
# If you change the names or values of these variables then make sure they are
# still compatible with the .wks files in the wic directory and
# recipes-core/base-files/files/fstab.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Variables for default values
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

# Default alignment used for partitions when MBL_<partition>_ALIGN_KiB
# (documented below) isn't set.
MBL_DEFAULT_ALIGN_KiB ?= "${MBL_FLASH_ERASE_BLOCK_SIZE_KiB}"

# Default file system type for file system partitions when
# MBL_<partition>_FSTYPE (documented below) isn't set.
MBL_DEFAULT_FSTYPE ?= "ext4"

# Default mount options for file system partitions when
# MBL_<partition>_MOUNT_OPTS (documented below) isn't set.
MBL_DEFAULT_MOUNT_OPTS ?= "defaults"

# Default fs_freq (the fifth fstab field - see "man 5 fstab") for file system
# partitions when MBL_<partition>_FS_FREQ (documented below) isn't set.
MBL_DEFAULT_FS_FREQ ?= "0"

# Default fs_passno (the sixth fstab field - see "man 5 fstab") for file system
# partitions when MBL_<partition>_FS_PASSNO (documented below) isn't set.
MBL_DEFAULT_FS_PASSNO ?= "0"


# ------------------------------------------------------------------------------
# Per-partition variables
# ------------------------------------------------------------------------------
# We have two different flavours of "partition" in MBL:
# * Normal file system partitions, recorded in the partition table.
# * Raw non-file system "partitions", not recorded in the partition table.
#
# For each of MBL's "partitions" there are the following variables:
# * MBL_<partition>_ALIGN_KiB   - minimum alignment in KiB
# * MBL_<partition>_SIZE_KiB    - size in KiB
# * MBL_<partition>_SIZE_MiB    - size in MiB
# * MBL_<partition>_OFFSET_BANK1_KiB - offset of first bank in KiB
# * MBL_<partition>_SKIP        - skip partition if set to "1"
# * MBL_<partition>_NO_FS       - raw partition (not a file system partition) if set to "1"
# * MBL_<partition>_IS_BANKED   - are there two banks of this partition
#
# For partitions with two banks there is:
# * MBL_<partition>_OFFSET_BANK2_KiB - offset of second bank in KiB
#
# For non-file system partitions there is:
# * MBL_<partition>_FILENAME    - file in image deploy dir
#
# For file system partitions there is:
# * MBL_<partition>_MOUNT_POINT - where this partition is mounted in the Linux file system)
# * MBL_<partition>_LABEL       - label of partition
# * MBL_<partition>_FSTYPE      - type of file system
# * MBL_<partition>_MOUNT_OPTS  - mount options
# * MBL_<partition>_FS_FREQ     - fifth fstab(5) field
# * MBL_<partition>_FS_PASSNO   - sixth fstab(5) field
#
# Notes:
# * Note that a pair of banked partitions share these variables except for
#   having separate OFFSET variables.
#
# * Most variables can be left unset outside of this file, in which case
#   default values will be used. The exception, if WKS_BOOTLOADER1 is not
#   skipped, is MBL_WKS_BOOTLOADER1_OFFSET_BANK1_KiB. There is no default value for
#   MBL_WKS_BOOTLOADER1_OFFSET_BANK1 because this is always board specific.
#
# * If both MBL_<partition>_SIZE_KiB and MBL_<partition>_SIZE_MiB are set then
#   they must not contradict each other. I.e. the following must be true:
#       MBL_<partition>_SIZE_KiB == 1024 * MBL_<partition>_SIZE_MiB.
#
# * For file system partitions, the size must be a multiple of 1MiB.
#
# * When MBL_<partition>_SKIP is set to "1", the variable
#   MBL_<partition>_COMMENT_IF_SKIP will be set to "# SKIP" so that the line(s)
#   for the partition get commented out of the .wks file. If
#   MBL_<partition>_SKIP is not set outside of this file then default values is
#   "0" for all partitions.

# Names of all MBL partitions in their on-disk order. This includes
# non-filesystem partitions and partitions that are skipped. Note that banked
# pairs of partitions are mentioned only once. E.g. This variable should
# contain just "ROOT" for both root partition banks.
MBL_PARTITION_NAMES = ""

#-------------------------------------------------------------------------------
# Boot related partitions
#-------------------------------------------------------------------------------
# For each of the BL2 and BL3 bootloaders we usually write an image file to
# raw flash storage. Some platforms are different though:
# * On Raspberry Pi 3, BL2 must be in the first FAT file system partition.
# * On Platforms that have only been partially ported to use MBL's secure
#   boot scheme, we may have other requirements, e.g. a U-Boot SPL image.
# To allow for this, we have variables for arbitrary bootloaders in the .wks
# file called WKS_BOOTLOADER1 and WKS_BOOTLOADER2.
#
# The names "WKS_BOOTLOADER1" and "WKS_BOOTLOADER2" have been chosen to
# distinguish them from the TF-A concepts of "BL2" and "BL3" - in the normal
# (and default) case, "WKS_BOOTLOADER1" will correspond with an image
# containing TF-A BL2 and "WKS_BOOTLOADER2" will correspond with an image
# containing TF-A BL3, OP-TEE and U-Boot.
 
# ------------------------------------------------------------------------------
# MBR
# ------------------------------------------------------------------------------
# We don't set the size, alignment or offset of the MBR in our .wks file, but
# we have variables for the MBR here to help when validating the offset of the
# first partition.

MBL_MBR_SIZE_KiB = "1"
MBL_MBR_ALIGN_KiB = "1"
MBL_MBR_OFFSET_BANK1_KiB = "0"
MBL_MBR_NO_FS = "1"
MBL_PARTITION_NAMES += "MBR"

# ------------------------------------------------------------------------------
# WKS_BOOTLOADER1 (non-file system; single bank)
# ------------------------------------------------------------------------------
# WKS_BOOTLOADER1, if it exists, has a single a non-file system partition
# containing the first bootloader on the storage. It is typically TF-A BL2,
# packaged however the vendor specific boot ROM requires.
#
MBL_WKS_BOOTLOADER1_FILENAME ?= "${MBL_BL2_FILENAME}"
MBL_WKS_BOOTLOADER1_DEFAULT_SIZE_MiB = "3"
MBL_WKS_BOOTLOADER1_ALIGN_KiB ?= "1"
MBL_WKS_BOOTLOADER1_NO_DEFAULT_OFFSET = "1"
MBL_WKS_BOOTLOADER1_NO_FS = "1"
MBL_PARTITION_NAMES += "WKS_BOOTLOADER1"

# ------------------------------------------------------------------------------
# WKS_BOOTLOADER2 (non-file system; two banks)
# ------------------------------------------------------------------------------
# WKS_BOOTLOADER2, if it exists, has a banked pair of non-file system
# partitions containing the next bootloader on the storage. It is Typically a
# FIP image containing BL3, OP-TEE and U-Boot.
#
MBL_WKS_BOOTLOADER2_FILENAME ?= "${MBL_FIP_BIN_FILENAME}"
MBL_WKS_BOOTLOADER2_DEFAULT_SIZE_MiB = "4"
MBL_WKS_BOOTLOADER2_IS_BANKED = "1"
MBL_WKS_BOOTLOADER2_NO_FS = "1"
MBL_PARTITION_NAMES += "WKS_BOOTLOADER2"

# ------------------------------------------------------------------------------
# BOOT (file system; single bank)
# ------------------------------------------------------------------------------
# BOOT contains a FIT image containing the Linux kernel, initramfs, and DTB
#
MBL_BOOT_MOUNT_POINT = "${MBL_BOOT_DIR}"
MBL_BOOT_LABEL ?= "boot"
MBL_BOOT_DEFAULT_SIZE_MiB ?= "48"
MBL_BOOT_FSTYPE ?= "vfat"
MBL_BOOT_MOUNT_OPTS ?= "ro,defaults"
MBL_PARTITION_NAMES += "BOOT"

# ------------------------------------------------------------------------------
# BOOTFLAGS (file system; single bank)
# ------------------------------------------------------------------------------
MBL_BOOTFLAGS_MOUNT_POINT = "${MBL_BOOTFLAGS_DIR}"
MBL_BOOTFLAGS_LABEL ?= "bootflags"
MBL_BOOTFLAGS_DEFAULT_SIZE_MiB ?= "20"
MBL_PARTITION_NAMES += "BOOTFLAGS"

# ------------------------------------------------------------------------------
# ROOT (file system; two banks)
# ------------------------------------------------------------------------------
MBL_ROOT_MOUNT_POINT = "/"
MBL_ROOT_LABEL ?= "rootfs"
MBL_ROOT_DEFAULT_SIZE_MiB ?= "500"
MBL_ROOT_IS_BANKED = "1"
MBL_PARTITION_NAMES += "ROOT"

# ------------------------------------------------------------------------------
# Factory config partition (file system; single bank)
# ------------------------------------------------------------------------------
MBL_FACTORY_CONFIG_MOUNT_POINT = "${MBL_FACTORY_CONFIG_DIR}"
MBL_FACTORY_CONFIG_LABEL ?= "factory_config"
MBL_FACTORY_CONFIG_DEFAULT_SIZE_MiB ?= "20"
MBL_FACTORY_CONFIG_MOUNT_OPTS = "rw,auto,noexec,nodev,nosuid,nouser,async"
MBL_PARTITION_NAMES += "FACTORY_CONFIG"

# ------------------------------------------------------------------------------
# Non factory config partitions (file system; two banks)
# ------------------------------------------------------------------------------
MBL_NON_FACTORY_CONFIG_MOUNT_POINT = "${MBL_NON_FACTORY_CONFIG_DIR}"
MBL_NON_FACTORY_CONFIG_LABEL ?= "nfactory_config"
MBL_NON_FACTORY_CONFIG_DEFAULT_SIZE_MiB ?= "20"
MBL_NON_FACTORY_CONFIG_IS_BANKED = "1"
MBL_NON_FACTORY_CONFIG_MOUNT_OPTS ?= "rw,auto,noexec,nodev,nosuid,nouser,async"
MBL_PARTITION_NAMES += "NON_FACTORY_CONFIG"

# ------------------------------------------------------------------------------
# Log partition (file system; single bank)
# ------------------------------------------------------------------------------
MBL_LOG_MOUNT_POINT = "${MBL_LOG_DIR}"
MBL_LOG_LABEL ?= "log"
MBL_LOG_DEFAULT_SIZE_MiB ?= "128"
MBL_LOG_MOUNT_OPTS ?= "rw,auto,noexec,nodev,nosuid,nouser,async"
MBL_PARTITION_NAMES += "LOG"

# ------------------------------------------------------------------------------
# Scratch partition (file system; single bank)
# ------------------------------------------------------------------------------
MBL_SCRATCH_MOUNT_POINT = "${MBL_SCRATCH_DIR}"
MBL_SCRATCH_LABEL ?= "scratch"
MBL_SCRATCH_DEFAULT_SIZE_MiB ?= "500"
MBL_PARTITION_NAMES += "SCRATCH"

# ------------------------------------------------------------------------------
# Home partition (file system; single bank)
# ------------------------------------------------------------------------------
MBL_HOME_MOUNT_POINT = "${MBL_HOME_DIR}"
MBL_HOME_LABEL ?= "home"
MBL_HOME_DEFAULT_SIZE_MiB ?= "450"
MBL_PARTITION_NAMES += "HOME"


# ------------------------------------------------------------------------------
# Validate partition variable values and compute missing values
# ------------------------------------------------------------------------------
python __anonymous() {

    def _process_size_vars(d, part_name, is_fs):
        """
        Get size information about a partition, validate it, then put it in
        appropriate BitBake variables if it's not there already.

        Returns a tuple (size_in_KiB, size_in_MiB). If the size is not a
        multiple of 1MiB then size_in_MiB will be None.
        """
        # Check if we have a size in MiB
        size_MiB = None
        size_MiB_var = "MBL_{}_SIZE_MiB".format(part_name)
        have_size_MiB = _is_var_set(d, size_MiB_var)
        if have_size_MiB:
            size_MiB = _get_size_var_or_fatal(d, size_MiB_var)

        # Check if we have a size in KiB
        size_KiB = None
        size_KiB_var = "MBL_{}_SIZE_KiB".format(part_name)
        have_size_KiB = _is_var_set(d, size_KiB_var)
        if have_size_KiB:
            size_KiB = _get_size_var_or_fatal(d, size_KiB_var)
            # Can we set the size in MiB from the size in KiB?
            if not have_size_MiB and size_KiB % 1024 == 0:
                size_MiB = size_KiB // 1024
                d.setVar(size_MiB_var, str(size_MiB))
                have_size_MiB = True
        elif have_size_MiB:
            # Set the size in KiB from the size in MiB
            size_KiB = size_MiB * 1024
            d.setVar(size_KiB_var, str(size_KiB))
            have_size_KiB = True

        # If we didn't find a size, see if we can use a default size
        if not have_size_MiB and not have_size_KiB:
            default_size_MiB_var = "MBL_{}_DEFAULT_SIZE_MiB".format(part_name)
            have_size_MiB = _is_var_set(d, default_size_MiB_var)
            if have_size_MiB:
                size_MiB = _get_size_var_or_fatal(d, default_size_MiB_var)
                d.setVar(size_MiB_var, str(size_MiB))
                size_KiB = size_MiB * 1024
                d.setVar(size_KiB_var, str(size_KiB))
            else:
                bb.fatal("Both {} and {} are unset".format(size_MiB_var, size_KiB_var))

        if have_size_KiB and have_size_MiB and size_KiB != 1024 * size_MiB:
            bb.fatal("{}={} and {}={} is contradictory: {} must be 1024 * {} ".format(
                size_MiB_var, size_MiB,
                size_KiB_var, size_KiB,
                size_KiB_var, size_MiB_var,
            ))

        if is_fs and not have_size_MiB:
            bb.fatal("{} is a file system partition - its size must be a multiple of 1MiB but {}={}".format(
                part_name, size_KiB_var, size_KiB
            ))
        return size_KiB, size_MiB

    def _next_fs_part_number(fs_part_number):
        """
        Given a partition number, return the next non-extended partition
        number.
        """
        if fs_part_number == 3:
            # Wic makes partitions 1, 2 and 3 primary partitions and makes
            # partition 4 an extended partition. This extended partition is
            # just a wrapper for further logical partitions so skip it when
            # working out the numbers of partitions that contain actual file
            # system data.
            return fs_part_number + 2
        return fs_part_number + 1

    def _process_offset_vars(
        d,
        part_name,
        is_banked,
        size,
        align,
        prev_offset,
        prev_size,
        prev_fs_part_number
    ):
        """
        Generate or get offset information for a partition (or banked pair of
        partitions), validate it, and put it in appropriate BitBake variables
        if its not there already.

        Returns an array of offsets in KiB, an element for each bank of the
        partition.
        """
        offset_vars = [ "MBL_{}_OFFSET_BANK1_KiB".format(part_name) ]
        if is_banked:
            offset_vars.append("MBL_{}_OFFSET_BANK2_KiB".format(part_name))

        offsets = []
        for offset_var in offset_vars:
            offset = _process_offset_var(d, part_name, align, offset_var, prev_offset, prev_size, prev_fs_part_number)
            offsets.append(offset)
            prev_offset = offset
            prev_size = size
            prev_fs_part_number = _next_fs_part_number(prev_fs_part_number)
        return offsets

    def _process_offset_var(
        d,
        part_name,
        align,
        offset_var,
        prev_offset,
        prev_size,
        prev_fs_part_number
    ):
        """
        Generate or get offset information for a single bank of a partition,
        validate it, and put it in appropriate BitBake variables if its not
        there already.

        Returns an offsets in KiB.
        """
        offset = None
        have_offset = _is_var_set(d, offset_var)
        no_default = _process_bool_var(d, part_name, "NO_DEFAULT_OFFSET")
        have_prev = prev_offset is not None and prev_size is not None
        if have_offset:
            offset = _get_size_var_or_fatal(d, offset_var)
            if offset % align:
                bb.fatal("{}={}KiB is badly aligned. Expected alignment is {}KiB".format(
                    offset_var, offset, align
                ))
            if have_prev and prev_offset + prev_size > offset:
                bb.fatal("{}={}KiB overlaps previous partition with offset {}KiB and size {}KiB".format(
                    offset_var, offset, prev_offset, prev_size
                ))
        elif no_default:
            bb.fatal("{} is not set".format(offset_var))
        elif have_prev:
            offset = _calculate_next_offset(align, prev_offset, prev_size)
            if prev_fs_part_number > 2:
                # If the previous fs part number is > 2 then the next partition
                # (excluding partition 4, the extended partition) will be a
                # logical partition that must be preceeded by a 512B extended
                # boot record.
                # Adjust the offset here so that we leave space for the EBR
                # ensuring that it doesn't share an alignment chunk with with
                # either the previous or next partition.
                # We're working in KiB, so tell _calculate_next_offset that the
                # EBR is 1KiB instead of 512B.
                offset = _calculate_next_offset(align, offset, 1)
            d.setVar(offset_var, str(offset))
        else:
            bb.fatal("{} is not set".format(offset_var))
        return offset

    def _calculate_next_offset(align, prev_offset, prev_size):
        """
        Return the next aligned offset after the previous partition.
        """
        last_byte_of_prev = prev_offset + prev_size - 1
        return last_byte_of_prev + align - (last_byte_of_prev % align)

    def _process_var_with_default(d, part_name, var_name, str_to_val=str, val_to_str=str):
        """
        Get the value for a BitBake variable for a partition, validate it, and
        ensure the BitBake variable is set if it isn't already.

        str_to_val is used to convert the variable's string value into a more
        natural type if required.
        val_to_str is used to convert the variables natural type into a string.

        Returns the value of the variable, converted into its natural type.
        """
        full_var_name = "MBL_{}_{}".format(part_name, var_name)
        default_var_name = "MBL_DEFAULT_{}".format(var_name)
        var_value = None
        for vn in (full_var_name, default_var_name):
            if _is_var_set(d, vn):
                var_value = str_to_val(d.getVar(vn, True))
                if var_value is None:
                    bb.fatal("{} is invalid".format(vn))
                break
        if var_value is None:
            bb.fatal("{} is not set".format(full_var_name))
        d.setVar(full_var_name, val_to_str(var_value))
        return var_value

    def _str_to_size(str_val):
        """
        Convert a string to an integer representing a size. Used as the
        str_to_val param of _process_var_with_default().
        """
        if not str_val.isdigit():
            return None
        return int(str_val)

    def _process_bool_var(d, part_name, var_name):
        """
        Return True if a BitBake var exists and is non-zero when converted to
        an integer; false otherwise.

        This is for "flag" variables where non-existence or "0" means False and
        "1" means True.
        """
        full_var_name = "MBL_{}_{}".format(part_name, var_name)
        val = d.getVar(full_var_name, True)

        # Convert val to int here so that e.g. " " isn't treated as True
        # Convert the int to bool so that the returned value is True or False
        # rather than 1 or 0
        return val is not None and bool(int(val))

    def _get_size_var_or_fatal(d, var_name):
        """
        Get an integer value representing a size from a BitBake variable,
        raising a fatal error on failure.
        """
        var_str = d.getVar(var_name, True)
        if var_str is None:
            bb.fatal("{} has not been set".format(var_name))
        if not var_str.isdigit():
            bb.fatal("{} (\"{}\") must contain only decimal digits".format(var_name, var_str))
        return int(var_str)

    def _is_var_set(d, var):
        """
        Check if a BitBake variable exists and has a non-empty value.
        """
        return bool(d.getVar(var, True))


    part_names = d.getVar("MBL_PARTITION_NAMES", True).split()
    part_infos = []
    prev_part_info = {}
    prev_fs_part_number = 0
    for part_name in part_names:
        part_info = {}
        part_infos.append(part_info)
        part_info["name"] = part_name
        part_info["skip"] = _process_bool_var(d, part_name, "SKIP")
        if part_info["skip"]:
            d.setVar("MBL_{}_COMMENT_IF_SKIP".format(part_name), "# SKIP ")
            continue
        part_info["is_fs"] = not _process_bool_var(d, part_name, "NO_FS")
        part_info["is_banked"] = _process_bool_var(d, part_name, "IS_BANKED")
        part_info["align_KiB"] = _process_var_with_default(d, part_name, "ALIGN_KiB", str_to_val=_str_to_size)
        part_info["size_KiB"], part_info["size_MiB"] = _process_size_vars(d, part_name, part_info["is_fs"])
        part_info["offsets_KiB"] = _process_offset_vars(
            d,
            part_name,
            is_banked=part_info["is_banked"],
            size=part_info["size_KiB"],
            align=part_info["align_KiB"],
            prev_offset=prev_part_info.get("offsets_KiB", [None])[-1],
            prev_size=prev_part_info.get("size_KiB"),
            prev_fs_part_number=prev_fs_part_number,
        )
        prev_part_info = part_info
        if not part_info["is_fs"]:
            continue
        part_info["label"] = _process_var_with_default(d, part_name, "LABEL")
        part_info["mount_point"] = _process_var_with_default(d, part_name, "MOUNT_POINT")
        part_info["fstype"] = _process_var_with_default(d, part_name, "FSTYPE")
        part_info["mount_opts"] = _process_var_with_default(d, part_name, "MOUNT_OPTS")
        part_info["fs_freq"] = _process_var_with_default(d, part_name, "FS_FREQ")
        part_info["fs_passno"] = _process_var_with_default(d, part_name, "FS_PASSNO")
        part_info["fs_part_numbers"] = []
        for p in part_info["offsets_KiB"]:
            new_fs_part_number = _next_fs_part_number(prev_fs_part_number)
            part_info["fs_part_numbers"].append(new_fs_part_number)
            prev_fs_part_number = new_fs_part_number

    d.setVar("MBL_PARTITION_INFOS", part_infos)
}
