#!/usr/bin/env python3
# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""Paths to the tools used for the mbl-signing-lib."""

import pathlib


class ToolPaths:
    """Data structure containing paths for tools invoked by mbl-signing-lib."""

    # Default assumes fiptool is installed with the package.
    # This can be changed by binding this variable to a different path.
    FIPTOOL_BIN = str(pathlib.Path(__file__).parent.parent / "fiptool")
    MKIMAGE_BIN = "mkimage"