# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""PayloadImage subclass for rootfs partition images."""

import pathlib

import mbl.update.payloadimage as upi
import mbl.update.testinfo as testinfo
import mbl.update.util as uutil
import mbl.util.tinfoilutil as tutil

MBL_ROOTFS_ID = "ROOTFS"


class _RootfsImageBase(upi.PayloadImage):
    """Base class for creating rootfs images."""

    def generate_testinfo(self):
        """Implement method from PayloadImage ABC."""
        return [
            testinfo.file_timestamp_compare("/etc/build"),
            testinfo.mounted_bank_compare("/"),
        ]


class _TarXzRootfsImage(_RootfsImageBase):
    """Class for creating .tar.xz image files for rootfs partitions."""

    def __init__(self, archived_path, image_name, deploy_dir, tinfoil):
        """
        Create a _TarXzRootfsImage object.

        Args:
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

    def stage(self, staging_dir):
        """Implement method from PayloadImage ABC."""
        upi.stage_single_file(staging_dir, self._archived_file_spec)

    @property
    def archived_paths(self):
        """Implement method from PayloadImage ABC."""
        return [self._archived_file_spec.archived_path]


class _Ext4XzRootfsImage(_RootfsImageBase):
    """Class for creating .ext4.xz image files for rootfs partitions."""

    def __init__(self, image_name, deploy_dir, tinfoil):
        """
        Create a _Ext4XzRootfsImage object.

        Args:
        * image_name str: name of the BitBake image recipe that was used to
          create the rootfs image.
        * deploy_dir Path: path to the directory containing build artifacts.
        * tinfoil Tinfoil: BitBake Tinfoil object.

        """
        machine = tutil.get_bitbake_conf_var("MACHINE", tinfoil)
        rootfs_filename = "{}-{}.ext4".format(image_name, machine)
        self._path = deploy_dir / rootfs_filename

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
        return [pathlib.Path("{}.ext4.xz".format(self.image_type))]


class RootfsImageV4(_Ext4XzRootfsImage):
    """Class for creating rootfs images with format version 4."""

    IMAGE_FORMAT_VERSION = 4
    IMAGE_BASE_TYPE = MBL_ROOTFS_ID


RootfsImageV4.register()


class RootfsImageV3(_TarXzRootfsImage):
    """Class for creating rootfs images with format version 3."""

    IMAGE_FORMAT_VERSION = 3
    IMAGE_BASE_TYPE = MBL_ROOTFS_ID

    def __init__(self, image_name, deploy_dir, tinfoil):
        """Create a RootfsImageV3 object."""
        super().__init__(
            pathlib.Path("{}.tar.xz".format(self.image_type)),
            image_name,
            deploy_dir,
            tinfoil,
        )


RootfsImageV3.register()


class RootfsImageV1(_TarXzRootfsImage):
    """Class for creating rootfs images with format version 1."""

    IMAGE_FORMAT_VERSION = 1
    IMAGE_BASE_TYPE = MBL_ROOTFS_ID

    def __init__(self, image_name, deploy_dir, tinfoil):
        """Create a RootfsImageV1 object."""
        super().__init__(
            pathlib.Path("rootfs.tar.xz"), image_name, deploy_dir, tinfoil
        )


RootfsImageV1.register()
