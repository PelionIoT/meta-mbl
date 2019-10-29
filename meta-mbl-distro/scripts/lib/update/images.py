# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

import arpy
import io
import itertools
import logging
import lzma
import pathlib
import shutil
import tarfile

from update.util import ArchivedFileSpec, get_bitbake_conf_var, read_chunks
import update.testinfo as testinfo

MBL_WKS_BOOTLOADER1_ID = "WKS_BOOTLOADER1"
MBL_WKS_BOOTLOADER2_ID = "WKS_BOOTLOADER2"
MBL_BOOT_ID = "BOOT"
MBL_ROOTFS_ID = "ROOTFS"
MBL_APPS_ID = "APPS"


class RootfsImage:
    def __init__(self, image_name, deploy_dir, tinfoil):
        machine = get_bitbake_conf_var("MACHINE", tinfoil)
        rootfs_filename = "{}-{}.tar.xz".format(image_name, machine)
        self._archived_file_spec = ArchivedFileSpec(
            deploy_dir / rootfs_filename, "{}.tar.xz".format(MBL_ROOTFS_ID)
        )

        self.image_type = MBL_ROOTFS_ID
        self.image_format_version = 3
        self.archived_path = self._archived_file_spec.archived_path

    def stage(self, staging_dir):
        _stage_single_file(staging_dir, self._archived_file_spec)

    def generate_testinfo(self):
        return [
            testinfo.file_timestamp_compare("/etc/build"),
            testinfo.mounted_bank_compare("/"),
        ]


class WksBootloaderSlotImage:
    def __init__(self, bootloader_slot_name, deploy_dir, tinfoil):
        filename_var_name = "MBL_{}_FILENAME".format(bootloader_slot_name)
        filename = get_bitbake_conf_var(filename_var_name, tinfoil)
        self._archived_file_spec = ArchivedFileSpec(
            deploy_dir / filename, "{}.xz".format(bootloader_slot_name)
        )

        self.image_type = bootloader_slot_name
        self.image_format_version = 3
        self.archived_path = self._archived_file_spec.archived_path

    def stage(self, staging_dir):
        _stage_single_file(staging_dir, self._archived_file_spec)

    def generate_testinfo(self):
        return [
            testinfo.partition_sha256(
                self.image_type, self._archived_file_spec.path
            )
        ]


class AppsImage:
    def __init__(self, app_paths):
        self._apps = [ArchivedFileSpec(app) for app in app_paths]
        self._validate_app_paths(self._apps)
        self.image_type = MBL_APPS_ID
        self.image_format_version = 3
        self.archived_path = "{}.tar.xz".format(MBL_APPS_ID)

    def stage(self, staging_dir):
        _stage_multi_file_component(
            staging_dir, self.archived_path, self._apps
        )

    def generate_testinfo(self):
        return [
            testinfo.app_bank_compare(self._get_app_name(afs.path))
            for afs in self._apps
        ]

    @staticmethod
    def _validate_app_paths(apps):
        # Check for duplicate app filenames and missing ".ipk" extensions
        arch_path_to_path = dict()
        for spec in apps:
            if not str(spec.archived_path).endswith(".ipk"):
                bb.fatal(
                    'App file "{}" does not have an "ipk" extension'.format(
                        spec.archived_path
                    )
                )
            if spec.archived_path in arch_path_to_path:
                bb.fatal(
                    'Duplicate file name for app paths "{}" and "{}"'.format(
                        spec.path, arch_path_to_path[spec.archived_path]
                    )
                )
            arch_path_to_path[spec.archived_path] = spec.path

    @staticmethod
    def _get_app_name(ipk_path):
        """
        Get the name of an app in an ipk file.

        Args:
        * ipk_path path-like: the path to the ipk.
        """
        with ipk_path.open(mode="rb") as ipk:
            return AppsImage._get_app_name_from_control_file(
                AppsImage._get_control_file_from_control_tgz(
                    AppsImage._get_control_tgz_from_ipk(ipk, ipk_path),
                    ipk_path,
                ),
                ipk_path,
            )

    @staticmethod
    def _get_control_tgz_from_ipk(ipk, ipk_path):
        """
        Get the "control.tar.gz" file from within an ipk.

        Args:
        * ipk file-like: an open ipk file.
        * ipk_path path-like: the path to the ipk (for error messages).
        """
        # ipk files are "ar" archives
        ar = arpy.Archive(fileobj=ipk)
        ar.read_all_headers()
        control_tgz_fname = b"control.tar.gz"
        if control_tgz_fname not in ar.archived_files:
            bb.fatal(
                'Failed  to find "{}" file in app file "{}"'.format(
                    control_tgz_fname, ipk_path
                )
            )
        return ar.archived_files[control_tgz_fname]

    @staticmethod
    def _get_control_file_from_control_tgz(control_tgz, ipk_path):
        """
        Get the "control" file from the "control.tar.gz" from an ipk.

        Args:
        * control_tgz file-like: an open control.tar.gz file.
        * ipk_path: the path to the ipk (for error messages).
        """
        tar = tarfile.open(fileobj=control_tgz, mode="r|gz")
        for tarinfo in tar:
            if not tarinfo.name.endswith("control"):
                continue
            return tar.extractfile(tarinfo)
        bb.fatal(
            'Failed to find "control" file in app file "{}"'.format(ipk_path)
        )

    @staticmethod
    def _get_app_name_from_control_file(control_file, ipk_path):
        """
        Get the app name from the "control" file from an ipk.

        Args:
        * control_file file-like: an open control file.
        * ipk_path: the path to the ipk (for error messages).
        """
        for line in control_file.read().decode("utf-8").splitlines():
            field, value = line.split(sep=":", maxsplit=1)
            if field.strip() == "Package":
                return value.strip()
        bb.fatal(
            'Failed find app name in "control" file from "{}"'.format(ipk_path)
        )


class BootImage:
    def __init__(self, deploy_dir, tinfoil):
        self._boot_files = self._get_archived_file_specs(deploy_dir, tinfoil)
        self.image_type = MBL_BOOT_ID
        self.image_format_version = 3
        self.archived_path = pathlib.Path("{}.tar.xz".format(MBL_BOOT_ID))

    def stage(self, staging_dir):
        _stage_multi_file_component(
            staging_dir, self.archived_path, self._boot_files
        )

    def generate_testinfo(self):
        return [testinfo.file_compare("/proc/version")] + [
            testinfo.file_sha256(
                afs.path, pathlib.Path("/boot", afs.archived_path)
            )
            for afs in self._boot_files
        ]

    @staticmethod
    def _get_archived_file_specs(deploy_dir, tinfoil):
        """
        Get ArchivedFileSpecs for the boot partition (or BLFS).

        :param deploy_dir Path: path to DEPLOY_DIR_IMAGE.
        :param tinfoil Tinfoil: BitBake tinfoil object.
        """
        boot_file_entries = get_bitbake_conf_var(
            "IMAGE_BOOT_FILES", tinfoil
        ).split()
        boot_files = list(
            itertools.chain.from_iterable(
                BootImage._img_boot_files_val_to_archived_file_specs(
                    elem, deploy_dir
                )
                for elem in boot_file_entries
            )
        )
        if not boot_files:
            bb.fatal(
                "Failed to convert IMAGE_BOOT_FILES value into list of files"
            )
        return boot_files

    @staticmethod
    def _img_boot_files_val_to_archived_file_specs(img_bf_val, deploy_dir):
        """
        Convert a value from the IMAGE_BOOT_FILES var to a list ArchivedFileSpecs.

        The values in the IMAGE_BOOT_FILES var can be a string filename,
        a filename with an 'output name' separated by a semi-colon, or a directory
        with a glob expression. This function will convert an IMAGE_BOOT_FILES
        entry into a list of ArchivedFileSpec objects according to the following
        rules:

        * dir with glob, e.g mbl-bootfiles/*: Each ArchivedFileSpec has:
          - path: absolute path for a file in the glob. The glob is intepreted
            relative to deploy_dir.
          - archived_path: basename of the file in the glob.

        * filename: The single ArchivedFileSpec in the returned list has:
          - path: absolute path for file. filename is interpreted relative to
            deploy_dir.
          - archived_path: basename of the file.

        * filename with output name, e.g uImage;kernel: The single ArchivedFileSpec
          in the returned list has:
          - path: absolute path of the file. filename is interpreted relative to
            deploy_dir.
          - archived_path: the "output name" (the part after the semicolon in the
            IMAGE_BOOT_FILES entry)

        :param img_bf_val str: the IMAGE_BOOT_FILES value.
        :param deploy_dir_img Path: path to the image deploy dir.
        """
        installed_name_delim = ";"
        if img_bf_val.endswith(r"/*"):
            matched_files = deploy_dir.glob(img_bf_val)
            return [ArchivedFileSpec(p) for p in matched_files]
        elif installed_name_delim in img_bf_val:
            orig_name, installed_name = img_bf_val.split(installed_name_delim)
            return [ArchivedFileSpec(deploy_dir / orig_name, installed_name)]
        elif img_bf_val:
            return [ArchivedFileSpec(deploy_dir / img_bf_val)]


def _stage_multi_file_component(staging_dir, file_name, archived_file_specs):
    """
    Create a tar.xz file for a multi-file component in the staging dir.
    """
    tar_path = staging_dir / file_name
    with tarfile.open(str(tar_path), mode="w:xz") as tar:
        for file_spec in archived_file_specs:
            logging.info(
                'Adding "{}" to "{}" as "{}"'.format(
                    file_spec.path, file_name, file_spec.archived_path
                )
            )
            tar.add(str(file_spec.path), arcname=str(file_spec.archived_path))
    logging.info('Adding "{}" to payload'.format(file_name))


def _stage_single_file(staging_dir, archived_file_spec):
    """
    Copy a file to the staging dir acording to the given ArchivedFileSpec.

    Compresses the file if required and the path in the archive ends with
    ".xz".
    """
    logging.info(
        'Adding "{}" to payload as "{}"'.format(
            archived_file_spec.path, archived_file_spec.archived_path
        )
    )
    if (
        archived_file_spec.path.suffix != ".xz"
        and archived_file_spec.archived_path.suffix == ".xz"
    ):
        _stage_single_file_with_compression(staging_dir, archived_file_spec)
    else:
        _stage_single_file_without_compression(staging_dir, archived_file_spec)


def _stage_single_file_with_compression(staging_dir, archived_file_spec):
    """
    Stage a single file when compression is required.
    """
    out_path = staging_dir / archived_file_spec.archived_path
    with archived_file_spec.path.open("rb") as in_file:
        with lzma.open(str(out_path), "w") as out_file:
            for chunk in read_chunks(in_file):
                out_file.write(chunk)


def _stage_single_file_without_compression(staging_dir, archived_file_spec):
    """
    Stage a single file when compression is not required.
    """
    try:
        shutil.copy2(
            str(archived_file_spec.path),
            str(staging_dir / archived_file_spec.archived_path),
        )
    except FileNotFoundError:
        bb.fatal(
            'File "{}" was not found. Have you built the update components?'.format(
                str(archived_file_spec)
            )
        )
