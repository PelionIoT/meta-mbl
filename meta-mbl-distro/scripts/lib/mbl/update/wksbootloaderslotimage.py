# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""PayloadImage subclass for bootloader raw partition images."""

import pathlib

import mbl.update.payloadimage as upi
import mbl.update.testinfo as testinfo
import mbl.update.util as uutil
import mbl.util.tinfoilutil as tutil

MBL_WKS_BOOTLOADER1_ID = "WKS_BOOTLOADER1"
MBL_WKS_BOOTLOADER2_ID = "WKS_BOOTLOADER2"


class _WksBootloaderSlotImageBase(upi.PayloadImage):
    """Base class for creating image files for bootloader raw partitions."""

    def __init__(self, deploy_dir, tinfoil):
        """
        Create a _WksBootloaderSlotImageBase object.

        Args:
        * deploy_dir Path: path to the directory containing build artifacts.
        * tinfoil Tinfoil: BitBake Tinfoil object.

        """
        filename_var_name = "MBL_{}_FILENAME".format(self.image_base_type)
        filename = tutil.get_bitbake_conf_var(filename_var_name, tinfoil)
        self._path = deploy_dir / filename

    def generate_testinfo(self):
        """Implement method from PayloadImage ABC."""
        return [testinfo.partition_sha256(self.image_base_type, self._path)]


class _XzWksBootloaderSlotImage(_WksBootloaderSlotImageBase):
    """
    Class for creating xz compressed raw bootloader image files.

    An _XzWksBootloaderSlotImage is just a bootloader image compressed with
    xz named after the bootloader slot that it should be written to.
    """

    def stage(self, staging_dir):
        """Implement method from PayloadImage ABC."""
        assert len(self.archived_paths) == 1
        upi.stage_single_file_with_compression(
            staging_dir,
            uutil.ArchivedFileSpec(self._path, self.archived_paths[0]),
        )

    @property
    def archived_paths(self):
        """Implement method from PayloadImage ABC."""
        return [pathlib.Path("{}.xz".format(self.image_type))]


class WksBootloader1ImageV3(_XzWksBootloaderSlotImage):
    """Class for creating WKS_BOOTLOADER1 images with format version 3."""

    IMAGE_FORMAT_VERSION = 3
    IMAGE_BASE_TYPE = MBL_WKS_BOOTLOADER1_ID


class WksBootloader2ImageV3(_XzWksBootloaderSlotImage):
    """Class for creating WKS_BOOTLOADER2 images with format version 3."""

    IMAGE_FORMAT_VERSION = 3
    IMAGE_BASE_TYPE = MBL_WKS_BOOTLOADER2_ID


class _TarXzWksBootloaderSlotImage(_WksBootloaderSlotImageBase):
    """
    Class for creating .tar.xz archives containing raw bootloader image files.

    A _TarXzWksBootloaderSlotImage is a bootloader image named after its
    bootloader slot name inside a .tar.xz file, also named after the bootloader
    slot name.
    """

    def stage(self, staging_dir):
        """Implement method from PayloadImage ABC."""
        assert len(self.archived_paths) == 1
        upi.stage_multi_file_component(
            staging_dir,
            self.archived_paths[0],
            [uutil.ArchivedFileSpec(self._path, self.image_base_type)],
        )

    @property
    def archived_paths(self):
        """Implement method from PayloadImage ABC."""
        return [pathlib.Path("{}.tar.xz".format(self.image_base_type))]


class WksBootloader1ImageV1(_TarXzWksBootloaderSlotImage):
    """Class for creating WKS_BOOTLOADER1 images with format version 1."""

    IMAGE_FORMAT_VERSION = 1
    IMAGE_BASE_TYPE = MBL_WKS_BOOTLOADER1_ID


class WksBootloader2ImageV1(_TarXzWksBootloaderSlotImage):
    """Class for creating WKS_BOOTLOADER2 images with format version 1."""

    IMAGE_FORMAT_VERSION = 1
    IMAGE_BASE_TYPE = MBL_WKS_BOOTLOADER2_ID
