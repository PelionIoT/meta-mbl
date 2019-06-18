#!/usr/bin/env python3
# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""Create images for use with the U-Boot bootloader.

The MkImage class is used to create images for use with the U-Boot boot loader.
These images can contain the linux kernel, device tree blob, root file system
image, firmware images etc., either separate or combined.

mkimage supports two different formats:

The old legacy image format concatenates the individual parts (for example,
kernel image, device tree blob and ramdisk image) and adds a 64 bytes header
containing information about target architecture, operating system, image type,
compression method, entry points, time stamp, checksums, etc.

The FIT (Flattened Image Tree) format, which has the following improvements
over the legacy format:
    * Allows for more flexibility in handling images of various types.
    * Enhances integrity protection of images with stronger checksums.
    * Supports verified boot.
"""

import logging
import pathlib
import subprocess

from typing import List

from signing.conf.toolpaths import ToolPaths


logger = logging.getLogger("mbl-signing.fit")


class MkImageCommandOutput:
    """Data structure representing mkimage tool output."""

    def __init__(self, output):
        """Initialise attributes.

        :param output CompletedProcess: output from subprocess.run
        """
        self.stdout = output.stdout
        self.stderr = output.stderr
        self.returncode = output.returncode


class MkImage:
    """Object wrapping uboot-mkimage tool."""

    def __init__(self):
        """Invoke the mkimage tool to ensure it's available."""
        self._invoke("-V")

    def list_img_header_info(self, input_data_path: pathlib.Path) -> List[str]:
        """List FIT image data.

        :param input_data Path: path to a fit binary or an its file.
        """
        return (
            self._invoke("-l", str(input_data_path)).stdout.strip().split("\n")
        )

    def list_image_types(self):
        """List the supported image types."""
        # mkimage returns a non-zero exit code when listing available devices
        # so don't check the exit code.
        output = self._invoke("-T", check=False)
        img_str = output.stderr.split("Usage:")[0]
        img_str = img_str.split("Supported image types:")[-1]
        return tuple(
            [
                img_line.split(" ")[0].strip()
                for img_line in img_str.split("\n")
                if img_line
            ]
        )

    def create_legacy_image(
        self,
        output_path: pathlib.Path,
        arch: str = "",
        os: str = "",
        img_type: str = "",
        compression: str = "",
        name: str = "",
        entry_point: str = "",
        data_file_path: str = "",
    ) -> MkImageCommandOutput:
        """Make a legacy image.

        :param output_path Path: Output path for the image.
        :param arch str: set the architecture.
        :param os str: set the operating system.
        :param img_type str: set the image type.
        :param compression str: set the compression type.
        :param name str: set the script name.
        :param entry_point str: set the entry point hex address.
        :param data_file_path Path: path to the image data file.
        """
        argslist = []
        if arch:
            argslist.append("-A")
            argslist.append(arch)
        if os:
            argslist.append("-O")
            argslist.append(os)
        if img_type:
            argslist.append("-T")
            argslist.append(img_type)
        if compression:
            argslist.append("-C")
            argslist.append(compression)
        if name:
            argslist.append("-n")
            argslist.append(name)
        if entry_point:
            argslist.append("-e")
            argslist.append(entry_point)
        if data_file_path:
            argslist.append("-d")
            argslist.append(str(data_file_path))
        argslist.append(str(output_path))
        return self._invoke(*argslist)

    def create_fit_img(
        self,
        its_path: pathlib.Path,
        out_path: pathlib.Path,
        dtc_opts: List[str] = None,
    ) -> MkImageCommandOutput:
        """Create a FIT image from an its file.

        :param its Path: path to an its file.
        :param out_path Path: output path for the FIT image.
        :param dtc_opts List[str]: list of device tree compiler options.
        """
        if dtc_opts is not None:
            return self._invoke(
                "-D", *dtc_opts, "-f", str(its_path), str(out_path)
            )
        return self._invoke("-f", str(its_path), str(out_path))

    def modify_fit_img(
        self,
        img_path: pathlib.Path,
        dtc_opts: List[str] = None,
        key_dir: pathlib.Path = None,
        key_required: bool = False,
    ) -> MkImageCommandOutput:
        """Modify an existing FIT image.

        :param img_path Path: path to the existing FIT image to modify.
        :param dtc_opts List[str]: device tree compiler options.
        :param key_dir Path: path to the key used to sign the image.
        :param key_required bool: specifies that the signing keys are required
        for the image to boot.
        """
        arglist = ["-F"]
        if dtc_opts is not None:
            arglist.append(*dtc_opts)
        if key_dir is not None:
            arglist.append("-k")
            arglist.append(str(key_dir))
        if key_required:
            arglist.append("-r")
        arglist.append(str(img_path))
        return self._invoke(*arglist)

    def _invoke(self, *args, check=True) -> MkImageCommandOutput:
        """Invoke the mkimage tool."""
        cmd = [ToolPaths.MKIMAGE_BIN, *args]
        logger.debug("Invoking mkimage with the following cmd:{}".format(cmd))
        output = subprocess.run(
            cmd, check=check, capture_output=True, text=True
        )
        if output.stdout:
            logger.info(output.stdout)
        if output.stderr:
            logger.warning(output.stderr)
        return MkImageCommandOutput(output)
