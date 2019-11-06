# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""Utility functions to help with creating firmware update payloads."""

import pathlib

import mbl.util.fileutil as futil


class ArchivedFileSpec:
    """
    A specification of a file to be added to an archive.

    The class holds two pieces of information: the path to the file to be
    added, and the path/filename that the file should have within the archive.
    """

    def __init__(self, path, archived_path=None):
        """
        Create a new ArchivedFileSpec.

        :param path str|Path: path to the file to be archived. The path is
            resolved so that if it points to a symlink, the underlying file
            will be used rather than the symlink itself. The file must already
            exist.
        :param archived_path str|Path: path to the file within the archive. If
            set to None (the default value) then the file will be added to the
            archive with the same name as outside the archive (before symlink
            resolution).
        """
        self.path = pathlib.Path(path)
        if archived_path is None:
            self.archived_path = path.name
        else:
            self.archived_path = pathlib.Path(archived_path)

        try:
            # We don't want symlinks in our payloads
            self.path = futil.strict_path_resolve(self.path)
        except FileNotFoundError:
            bb.fatal(
                'The file "{}" was not found.'
                " Have you built all of the required components?".format(
                    self.path
                )
            )
