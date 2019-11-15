# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""PayloadImage subclass for apps images."""

import arpy
import pathlib
import tarfile

import mbl.update.payloadimage as upi
import mbl.update.testinfo as testinfo
import mbl.update.util as uutil

MBL_APPS_ID = "APPS"


class _AppsImageBase(upi.PayloadImage):
    """Base class for Image classes for sets of apps."""

    def __init__(self, app_paths):
        """
        Create an AppsImageBase object.

        Args:
        * app_paths list<str>: list of paths to the ipk files to add to the
          payload.

        """
        self._apps = [uutil.ArchivedFileSpec(app) for app in app_paths]
        _validate_app_paths(self._apps)

    def generate_testinfo(self):
        """Implement method from PayloadImage ABC."""
        return [
            testinfo.app_bank_compare(_get_app_name(afs.path))
            for afs in self._apps
        ]


class _TarXzAppsImage(_AppsImageBase):
    """
    Class for creating .tar.xz image files containing apps (ipk files).

    With this image format, all ipks are bundled together in a .tar.xz
    archive before being added to the payload archive.
    """

    def stage(self, staging_dir):
        """Implement method from PayloadImage ABC."""
        assert len(self.archived_paths) == 1
        upi.stage_multi_file_component(
            staging_dir, self.archived_paths[0], self._apps
        )

    @property
    def archived_paths(self):
        """Implement method from PayloadImage ABC."""
        return [pathlib.Path("{}.tar.xz".format(self.image_type))]


class _IndividualIpksAppsImage(_AppsImageBase):
    """
    Class for creating separate image files for each app.

    With this image format, each ipk is added to the payload archive
    separately.
    """

    def stage(self, staging_dir):
        """Implement method from PayloadImage ABC."""
        for app in self._apps:
            upi.stage_single_file(staging_dir, app)

    @property
    def archived_paths(self):
        """Implement method from PayloadImage ABC."""
        return [app.archived_path for app in self._apps]


class AppsImageV3(_TarXzAppsImage):
    """Class for creating apps images with format version 3."""

    IMAGE_FORMAT_VERSION = 3
    IMAGE_BASE_TYPE = MBL_APPS_ID


AppsImageV3.register()


class AppsImageV1(_IndividualIpksAppsImage):
    """Class for creating apps images with format version 1."""

    IMAGE_FORMAT_VERSION = 1
    IMAGE_BASE_TYPE = MBL_APPS_ID


AppsImageV1.register()


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


def _get_app_name(ipk_path):
    """
    Get the name of an app in an ipk file.

    Args:
    * ipk_path path-like: the path to the ipk.

    """
    with ipk_path.open(mode="rb") as ipk:
        return _get_app_name_from_control_file(
            _get_control_file_from_control_tgz(
                _get_control_tgz_from_ipk(ipk, ipk_path), ipk_path
            ),
            ipk_path,
        )


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
    bb.fatal('Failed to find "control" file in app file "{}"'.format(ipk_path))


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
