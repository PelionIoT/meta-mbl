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

    def __init__(
        self, bootloader_slot_name, deploy_dir, tinfoil, image_format_version
    ):
        """
        Create a _WksBootloaderSlotImageBase object.

        Args:
        * bootloader_slot_name str: name of the bootloader slot/partition.
        * deploy_dir Path: path to the directory containing build artifacts.
        * tinfoil Tinfoil: BitBake Tinfoil object.

        """
        self._bootloader_slot_name = bootloader_slot_name
        filename_var_name = "MBL_{}_FILENAME".format(bootloader_slot_name)
        filename = tutil.get_bitbake_conf_var(filename_var_name, tinfoil)
        self._path = deploy_dir / filename
        self._image_format_version = image_format_version

    def generate_testinfo(self):
        """Implement method from PayloadImage ABC."""
        return [
            testinfo.partition_sha256(self._bootloader_slot_name, self._path)
        ]

    @property
    def image_type(self):
        """Implement method from PayloadImage ABC."""
        return "{}v{}".format(
            self._bootloader_slot_name, self._image_format_version
        )


class XzWksBootloaderSlotImage(_WksBootloaderSlotImageBase):
    """
    Class for creating xz compressed raw bootloader image files.

    An XzWksBootloaderSlotImage is just a bootloader image compressed with
    xz named after the bootloader slot that it should be written to.
    """

    def __init__(self, bootloader_slot_name, deploy_dir, tinfoil):
        """
        Create an XzWksBootloaderSlotImage object.

        Args:
        * bootloader_slot_name str: name of the bootloader slot/partition.
        * deploy_dir Path: path to the directory containing build artifacts.
        * tinfoil Tinfoil: BitBake Tinfoil object.

        """
        super().__init__(
            bootloader_slot_name, deploy_dir, tinfoil, image_format_version=3
        )

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


class TarXzWksBootloaderSlotImage(_WksBootloaderSlotImageBase):
    """
    Class for creating .tar.xz archives containing raw bootloader image files.

    A TarXzWksBootloaderSlotImage is a bootloader image named after its
    bootloader slot name inside a .tar.xz file, also named after the bootloader
    slot name.
    """

    def __init__(self, bootloader_slot_name, deploy_dir, tinfoil):
        """
        Create a TarXzWksBootloaderSlotImage object.

        Args:
        * bootloader_slot_name str: name of the bootloader slot/partition.
        * deploy_dir Path: path to the directory containing build artifacts.
        * tinfoil Tinfoil: BitBake Tinfoil object.

        """
        super().__init__(
            bootloader_slot_name, deploy_dir, tinfoil, image_format_version=1
        )

    def stage(self, staging_dir):
        """Implement method from PayloadImage ABC."""
        assert len(self.archived_paths) == 1
        upi.stage_multi_file_component(
            staging_dir,
            self.archived_paths[0],
            [uutil.ArchivedFileSpec(self._path, self._bootloader_slot_name)],
        )

    @property
    def archived_paths(self):
        """Implement method from PayloadImage ABC."""
        return [pathlib.Path("{}.tar.xz".format(self._bootloader_slot_name))]
