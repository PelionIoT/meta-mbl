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
    FIPTOOL_BIN = str(pathlib.Path("/home/robwal02/mbl/build/machine-imx8mmevk-mbl/mbl-manifest/build-mbl-development/tmp/work/imx7d_pico_mbl-oe-linux-gnueabi/atf-imx7d-pico-mbl/2.1+gitAUTOINC+89a4d26914-r0/git/tools/fiptool/fiptool").absolute())
    MKIMAGE_BIN = "mkimage"
