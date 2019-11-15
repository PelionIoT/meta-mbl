# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""Provides classes for archiving update component images into payloads."""

import abc
import functools
import io
import pathlib
import subprocess
import tarfile
import tempfile
import time

import mbl.update.swdesc as swdesc
import mbl.update.versionedclassregistry as vcr

MBL_PAYLOAD_ARCHIVER_ID = "ARCHIVER"


def _with_staging_dir(f):
    """Decorate function so that it has access to a temporary staging dir."""
    # Pydocstyle doesn't want a blank line after the docstring here but Black
    # does... Both are happy if I have this comment and a blank line though.

    @functools.wraps(f)
    def decorated(*args, **kwargs):
        with tempfile.TemporaryDirectory() as staging_dir:
            return f(*args, staging_dir=pathlib.Path(staging_dir), **kwargs)

    return decorated


class PayloadArchiver(abc.ABC):
    """ABC for creating containers that contain update payloads."""

    @classmethod
    def register(cls):
        """Register subclass with the versioned class registry."""
        vcr.register_versioned_class(
            MBL_PAYLOAD_ARCHIVER_ID, cls.ARCHIVE_FORMAT_VERSION, cls
        )

    @abc.abstractmethod
    def create_payload_file(self, images, output_path):
        """
        Create an update payload.

        Args:
        * output_path Path: path where we output the payload.
        * images list<PayloadImage>: images in the payload.
        """


class _SwupdateArchiver(PayloadArchiver):
    """
    Class for creating payload containers that swupdate can use.

    Payloads crated using SwupdateArchiver are CPIO archives that contain a
    sw-description file describing the contents.
    """

    def __init__(self, payload_format_version):
        """Create a TarWithVersionFileArchiver object."""
        self._payload_format_version = payload_format_version

    @_with_staging_dir
    def create_payload_file(self, images, output_path, staging_dir):
        """Implement method from PayloadArchiver ABC."""
        swdesc_name = "sw-description"
        swdesc.create_swdesc_file(images, staging_dir / swdesc_name)
        # swupdate requires that the  sw-description file is first in the
        # payload
        self._append_to_cpio(
            staging_dir, swdesc_name, output_path, create=True
        )
        for image in images:
            image.stage(staging_dir)
            # This Archiver doesn't support multiple files per image
            assert len(image.archived_paths) == 1
            self._append_to_cpio(
                staging_dir, image.archived_paths[0], output_path
            )

    @staticmethod
    def _append_to_cpio(staging_dir, archived_path, output_path, create=False):
        cpio_args = [
            "cpio",
            "--format",
            "crc",
            "--quiet",
            "-o",
            "-F",
            str(output_path),
        ]
        if not create:
            cpio_args.append("--append")

        subprocess.check_output(
            cpio_args,
            input=bytes(str(archived_path), "utf-8"),
            cwd=str(staging_dir),
        )


class PayloadArchiverV3(_SwupdateArchiver):
    """PayloadArchiver for archiver format 3."""

    ARCHIVE_FORMAT_VERSION = 3


PayloadArchiverV3.register()


class _TarWithVersionFileArchiver(PayloadArchiver):
    """
    Class for creating tar payload containers.

    Payloads crated using TarWithVersionFileArchiver are tar archives that
    contain a payload_format_version that specifies the payload format version.
    """

    ARCHIVE_FORMAT_VERSION = 1

    def __init__(self, payload_format_version):
        """Create a TarWithVersionFileArchiver object."""
        self._payload_format_version = payload_format_version

    @_with_staging_dir
    def create_payload_file(self, images, output_path, staging_dir):
        """Implement method from PayloadArchiver ABC."""
        with tarfile.open(str(output_path), mode="w") as tar:
            self._add_payload_format_version_to_tar_archive(
                tar, self._payload_format_version
            )
            for image in images:
                image.stage(staging_dir)
                for archived_path in image.archived_paths:
                    tar.add(
                        str(staging_dir / archived_path),
                        arcname=archived_path.name,
                    )

    @staticmethod
    def _add_payload_format_version_to_tar_archive(
        tar, payload_format_version
    ):
        buf = io.BytesIO(str(payload_format_version).encode())
        tar_info = tarfile.TarInfo(name="payload_format_version")
        tar_info.size = len(buf.getvalue())
        tar_info.mode = 0o444
        tar_info.uid = 0
        tar_info.gid = 0
        tar_info.uname = "root"
        tar_info.gname = "root"
        tar_info.mtime = time.time()
        tar.addfile(tar_info, buf)


class PayloadArchiverV1(_TarWithVersionFileArchiver):
    """PayloadArchiver for archiver format 1."""

    ARCHIVE_FORMAT_VERSION = 1


PayloadArchiverV1.register()
