# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""PayloadImage subclass for bootloader raw partition images."""

import mbl.update.payloadimage as upi
import mbl.update.testinfo as testinfo
import mbl.update.util as uutil
import mbl.util.tinfoilutil as tutil

MBL_WKS_BOOTLOADER1_ID = "WKS_BOOTLOADER1"
MBL_WKS_BOOTLOADER2_ID = "WKS_BOOTLOADER2"


class WksBootloaderSlotImageV3(upi.PayloadImage):
    """Class for creating image files for bootloader raw partitions."""

    def __init__(self, bootloader_slot_name, deploy_dir, tinfoil):
        """
        Create a WksBootloaderSlotImage object.

        Args:
        * bootloader_slot_name str: name of the bootloader slot/partition.
        * deploy_dir Path: path to the directory containing build artifacts.
        * tinfoil Tinfoil: BitBake Tinfoil object.

        """
        self._bootloader_slot_name = bootloader_slot_name
        filename_var_name = "MBL_{}_FILENAME".format(bootloader_slot_name)
        filename = tutil.get_bitbake_conf_var(filename_var_name, tinfoil)
        self._archived_file_spec = uutil.ArchivedFileSpec(
            deploy_dir / filename, "{}.xz".format(self.image_type)
        )

    def stage(self, staging_dir):
        """Implement method from PayloadImage ABC."""
        upi.stage_single_file_with_compression(
            staging_dir, self._archived_file_spec
        )

    def generate_testinfo(self):
        """Implement method from PayloadImage ABC."""
        return [
            testinfo.partition_sha256(
                self._bootloader_slot_name, self._archived_file_spec.path
            )
        ]

    @property
    def image_type(self):
        """Implement method from PayloadImage ABC."""
        return "{}v3".format(self._bootloader_slot_name)

    @property
    def archived_path(self):
        """Implement method from PayloadImage ABC."""
        return self._archived_file_spec.archived_path
