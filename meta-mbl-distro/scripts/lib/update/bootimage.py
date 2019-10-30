# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

import itertools
import pathlib

import update.payloadimage as upi
import update.testinfo as testinfo
import update.util as util

MBL_BOOT_ID = "BOOT"


class BootImage(upi.PayloadImage):
    def __init__(self, deploy_dir, tinfoil):
        self._boot_files = _get_archived_file_specs(deploy_dir, tinfoil)

    def stage(self, staging_dir):
        upi.stage_multi_file_component(
            staging_dir, self.archived_path, self._boot_files
        )

    def generate_testinfo(self):
        return [testinfo.file_compare("/proc/version")] + [
            testinfo.file_sha256(
                afs.path, pathlib.Path("/boot", afs.archived_path)
            )
            for afs in self._boot_files
        ]

    @property
    def image_type(self):
        return MBL_BOOT_ID

    @property
    def image_format_version(self):
        return 3

    @property
    def archived_path(self):
        return pathlib.Path("{}.tar.xz".format(MBL_BOOT_ID))


def _get_archived_file_specs(deploy_dir, tinfoil):
    """
    Get ArchivedFileSpecs for the boot partition (or BLFS).

    :param deploy_dir Path: path to DEPLOY_DIR_IMAGE.
    :param tinfoil Tinfoil: BitBake tinfoil object.
    """
    boot_file_entries = util.get_bitbake_conf_var(
        "IMAGE_BOOT_FILES", tinfoil
    ).split()
    boot_files = list(
        itertools.chain.from_iterable(
            _img_boot_files_val_to_archived_file_specs(elem, deploy_dir)
            for elem in boot_file_entries
        )
    )
    if not boot_files:
        bb.fatal("Failed to convert IMAGE_BOOT_FILES value into list of files")
    return boot_files


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
        return [util.ArchivedFileSpec(p) for p in matched_files]
    elif installed_name_delim in img_bf_val:
        orig_name, installed_name = img_bf_val.split(installed_name_delim)
        return [util.ArchivedFileSpec(deploy_dir / orig_name, installed_name)]
    elif img_bf_val:
        return [util.ArchivedFileSpec(deploy_dir / img_bf_val)]
