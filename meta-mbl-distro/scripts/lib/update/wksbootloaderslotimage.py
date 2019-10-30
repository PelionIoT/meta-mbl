# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

import update.payloadimage as upi
import update.testinfo as testinfo
import update.util as util

MBL_WKS_BOOTLOADER1_ID = "WKS_BOOTLOADER1"
MBL_WKS_BOOTLOADER2_ID = "WKS_BOOTLOADER2"


class WksBootloaderSlotImage(upi.PayloadImage):
    def __init__(self, bootloader_slot_name, deploy_dir, tinfoil):
        filename_var_name = "MBL_{}_FILENAME".format(bootloader_slot_name)
        filename = util.get_bitbake_conf_var(filename_var_name, tinfoil)
        self._archived_file_spec = util.ArchivedFileSpec(
            deploy_dir / filename, "{}.xz".format(bootloader_slot_name)
        )
        self._bootloader_slot_name = bootloader_slot_name

    def stage(self, staging_dir):
        upi.stage_single_file_with_compression(
            staging_dir, self._archived_file_spec
        )

    def generate_testinfo(self):
        return [
            testinfo.partition_sha256(
                self.image_type, self._archived_file_spec.path
            )
        ]

    @property
    def image_type(self):
        return self._bootloader_slot_name

    @property
    def image_format_version(self):
        return 3

    @property
    def archived_path(self):
        return self._archived_file_spec.archived_path
