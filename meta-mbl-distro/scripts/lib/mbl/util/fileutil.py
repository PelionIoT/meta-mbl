# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""Utility functions for handling files."""

import inspect
import pathlib


def strict_path_resolve(path):
    """
    Resolve a path.

    Acts like
        pathlib.Path(path).resolve(strict=True)
    from Python >= 3.6.
    """
    if "strict" in inspect.getfullargspec(path.resolve).args:
        # In python >= 3.6, pathlib.Path.resolve() has a "strict"
        # parameter, and we must set it to True to avoid the default
        # value of False.
        return pathlib.Path(path).resolve(strict=True)
    # In python < 3.6, pathlib.Path.resolve() doesn't have a "strict"
    # parameter, but it always does strict resolution.
    return pathlib.Path(path).resolve()


def read_chunks(f, chunk_size=4096):
    """
    Read chunks from a file-like object.

    This function is a generator for reading a file in chunks.

    Args:
    * f file-like: object from which to read chunks.
    * chunk_size int: size of chunks to read in bytes. The default chunk_size
      is 4096.

    """
    # Default chunk size 4096 was chosen to because:
    # * It's small enough that we won't use up too much memory.
    # * It's a very popular file system block size.
    while True:
        chunk = f.read(chunk_size)
        if chunk:
            yield chunk
        else:
            return
