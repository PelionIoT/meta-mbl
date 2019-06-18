#!/usr/bin/env python3
# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause


"""Utilities for the fiptool module."""

import functools
import subprocess

import logging

logger = logging.getLogger("mbl-signing.fiptool")


def fiptool_error_logger(func):
    """Handle fiptool output logging and error handling.

    Used to decorate fiptool module functions.
    """
    # Retain original function metadata.
    @functools.wraps(func)
    def wrapper(cmd, *args, **kwargs):
        try:
            output = func(cmd, *args, **kwargs)
            if output.stdout:
                logger.info(output.stdout)
            if output.stderr:
                logger.warning(output.stderr)
            return output
        except subprocess.CalledProcessError as err:
            msg = (
                "fiptool {func} call failed due to an error."
                "\nFiptool output: {out}"
            ).format(func=err.cmd, out=err.stderr if err.stderr else None)
            logger.error(msg)
            raise FiptoolCommandError(
                msg,
                stdout=err.output,
                stderr=err.stderr,
                return_code=err.returncode,
            )

    return wrapper


class FiptoolCommandError(Exception):
    """Fiptool command failed."""

    def __init__(
        self, *args, stdout=None, stderr=None, return_code=None, **kwargs
    ):
        """Initialise with custom attributes."""
        self.stdout = stdout
        self.stderr = stderr
        self.return_code = return_code
        super().__init__(*args, **kwargs)
