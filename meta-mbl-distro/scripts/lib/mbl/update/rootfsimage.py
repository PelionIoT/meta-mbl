# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""PayloadImage subclass for rootfs partition images."""

import mbl.update.payloadimage as upi
import mbl.update.testinfo as testinfo
import mbl.update.util as uutil
import mbl.util.tinfoilutil as tutil

MBL_ROOTFS_ID = "ROOTFS"


class TarXzRootfsImage(upi.PayloadImage):
    """Class for creating .tar.xz image files for rootfs partitions."""

    def __init__(
        self,
        image_format_version,
        archived_path,
        image_name,
        deploy_dir,
        tinfoil,
    ):
        """
        Create a TarXzRootfsImage object.

        Args:
        * image_format_version int: version of rootfs image format.
        * archived_path Path: name of rootfs image in the payload archive.
        * image_name str: name of the BitBake image recipe that was used to
          create the rootfs image.
        * deploy_dir Path: path to the directory containing build artifacts.
        * tinfoil Tinfoil: BitBake Tinfoil object.

        """
        machine = tutil.get_bitbake_conf_var("MACHINE", tinfoil)
        rootfs_filename = "{}-{}.tar.xz".format(image_name, machine)
        self._archived_file_spec = uutil.ArchivedFileSpec(
            deploy_dir / rootfs_filename, archived_path
        )
        if image_format_version not in (1, 3):
            bb.fatal(
                'Unrecognized image format version "{}" '
                "for .tar.xz based rootfs image".format(image_format_version)
            )

        self._image_format_version = image_format_version

    def stage(self, staging_dir):
        """Implement method from PayloadImage ABC."""
        upi.stage_single_file(staging_dir, self._archived_file_spec)

    def generate_testinfo(self):
        """Implement method from PayloadImage ABC."""
        return [
            testinfo.file_timestamp_compare("/etc/build"),
            testinfo.mounted_bank_compare("/"),
        ]

    @property
    def image_type(self):
        """Implement method from PayloadImage ABC."""
        return "{}v{}".format(MBL_ROOTFS_ID, self._image_format_version)

    @property
    def archived_paths(self):
        """Implement method from PayloadImage ABC."""
        return [self._archived_file_spec.archived_path]
