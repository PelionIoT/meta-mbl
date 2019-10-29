# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

import inspect
import pathlib


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
            self.path = self._strict_path_resolve(self.path)
        except FileNotFoundError:
            bb.fatal(
                'The file "{}" was not found.'
                " Have you built all of the required components?".format(
                    self.path
                )
            )

    @staticmethod
    def _strict_path_resolve(path):
        """
        Acts like "pathlib.Path(path).resolve(strict=True)" from Python >= 3.6.
        """
        if "strict" in inspect.getfullargspec(path.resolve).args:
            # In python >= 3.6, pathlib.Path.resolve() has a "strict"
            # parameter, and we must set it to True to avoid the default
            # value of False.
            return pathlib.Path(path).resolve(strict=True)
        # In python < 3.6, pathlib.Path.resolve() doesn't have a "strict"
        # parameter, but it always does strict resolution.
        return pathlib.Path(path).resolve()


def get_bitbake_conf_var(var_name, tinfoil, missing_ok=False):
    """
    Get the value of a BitBake variable.

    If missing_ok is False then an error is raised if the variable does not
    exist.
    If missing_ok is True then None is returned if the variable does not exist.
    """
    val = tinfoil.config_data.getVar(var_name)
    if val is not None:
        return val.strip()
    if missing_ok:
        return None
    bb.fatal(
        'The "{}" BitBake variable is not set. '
        "Please check that you have set up a valid BitBake environment.".format(
            var_name
        )
    )


def read_chunks(f):
    """Generator to read a file in 4KiB chunks."""
    while True:
        chunk = f.read(4096)
        if chunk:
            yield chunk
        else:
            return
