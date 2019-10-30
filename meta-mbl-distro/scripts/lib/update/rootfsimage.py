# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

import update.payloadimage as upi
import update.testinfo as testinfo
import update.util as util

MBL_ROOTFS_ID = "ROOTFS"


class RootfsImage(upi.PayloadImage):
    def __init__(self, image_name, deploy_dir, tinfoil):
        machine = util.get_bitbake_conf_var("MACHINE", tinfoil)
        rootfs_filename = "{}-{}.tar.xz".format(image_name, machine)
        self._archived_file_spec = util.ArchivedFileSpec(
            deploy_dir / rootfs_filename, "{}.tar.xz".format(MBL_ROOTFS_ID)
        )

    def stage(self, staging_dir):
        upi.stage_single_file(staging_dir, self._archived_file_spec)

    def generate_testinfo(self):
        return [
            testinfo.file_timestamp_compare("/etc/build"),
            testinfo.mounted_bank_compare("/"),
        ]

    @property
    def image_type(self):
        return MBL_ROOTFS_ID

    @property
    def image_format_version(self):
        return 3

    @property
    def archived_path(self):
        return self._archived_file_spec.archived_path
