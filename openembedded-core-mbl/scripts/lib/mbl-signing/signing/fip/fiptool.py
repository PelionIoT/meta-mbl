# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""Generate, inspect and modify FIP image components.

This module is a set of functions that invoke the ATF fiptool.
The functions together encapsulate the fiptool functionality.

For more information on the ATF fiptool see the following link:
github.com/ARM-software/arm-trusted-firmware/tree/master/tools/fiptool

`CommandOpts` and `ImageSpec` objects are also defined in this module.
These dict-like objects represent sets of options passed to the fiptool.

The `ImageSpec` describes the bootchain entities that make up the FIP image.
The CommandOpts object describes optional parameters for a particular fiptool
command.

"""

import inspect
import logging
import pathlib
import subprocess

from abc import abstractmethod
from collections import UserDict

from signing.fip.fiputils import fiptool_error_logger
from signing.conf.toolpaths import ToolPaths

# Per module logging.
logger = logging.getLogger("mbl-signing.fiptool")


__all__ = [
    "create",
    "update",
    "remove",
    "unpack",
    "info",
    "ImageSpec",
    "UnknownOptionError",
    "FiptoolInvocationError",
]


def create(
    img_spec: "ImageSpec",
    output_fip_filename: pathlib.Path,
    align: int = 0,
    blob_uuid: str = "",
    blob_file: str = "",
    plat_toc_flags: int = 0,
) -> int:
    """Create a new FIP with the given images.

    :param ImageSpec img_spec: ImageSpec object.
    :param str output_fip_filename: Name to give the output FIP image.
    :param int align: Each image is aligned to <value>.
    :param str blob_uuid: Add an image with the given UUID.
    :param str blob_file: Add an image pointed to by file.
    :param str plat_toc_flags: 16-bit platform specific flag field
    occupying bits 32-47 in 64-bit ToC header.
    """
    opts = _make_cmd_opts(
        cmd="create",
        func=create,
        align=align,
        blob_uuid=blob_uuid,
        blob_file=blob_file,
        plat_toc_flags=plat_toc_flags,
    )
    return _invoke(
        "create",
        img_spec=img_spec,
        fip_filename=output_fip_filename,
        cmd_opts=opts,
    )


def update(
    img_spec: "ImageSpec",
    output_fip_filename: pathlib.Path,
    align: int = 0,
    blob_uuid: str = "",
    blob_file: str = "",
    plat_toc_flags: int = 0,
) -> int:
    """Update an existing FIP with the given images.

    :param ImageSpec img_spec: ImageSpec object describing image.
    :param str output_fip_filename: Name to give the output FIP image.
    :param int align: Each image is aligned to <value>.
    :param str blob_uuid: Add an image with the given UUID.
    :param str blob_file: Add an image pointed to by file.
    :param str plat_toc_flags: 16-bit platform specific flag field
    occupying bits 32-47 in 64-bit ToC header.
    """
    opts = _make_cmd_opts(
        cmd="update",
        func=update,
        align=align,
        blob_uuid=blob_uuid,
        blob_file=blob_file,
        plat_toc_flags=plat_toc_flags,
    )
    return _invoke(
        "update",
        img_spec=img_spec,
        fip_filename=output_fip_filename,
        cmd_opts=opts,
    )


def remove(
    img_spec: "ImageSpec",
    fip_path: pathlib.Path,
    align: int = 0,
    blob_uuid: str = "",
    force: bool = False,
    out: pathlib.Path = None,
) -> int:
    """Remove images from the FIP.

    :param ImageSpec img_spec: ImageSpec object describing images to remove.
    :param str fip_path: Path to an existing FIP image.
    :param int align: Each image is aligned to <value>.
    :param str blob_uuid: Add an image with the given UUID.
    :param bool force: If the output FIP file already exists, overwrite it.
    :param Path out: Output path for the FIP image.
    """
    opts = _make_cmd_opts(
        cmd="remove",
        func=remove,
        align=align,
        blob_uuid=blob_uuid,
        force=force,
        out=out,
    )
    return _invoke(
        "remove", img_spec=img_spec, fip_filename=fip_path, cmd_opts=opts
    )


def info(fip_path: str) -> "ImageSpec":
    """List images contained in FIP.

    :param str fip_filepath: Path to an existing FIP.
    """
    return ImageSpec.from_info(_invoke("info", fip_filename=fip_path).stdout)


def unpack(
    existing_fip_filepath: pathlib.Path,
    img_spec: "ImageSpec" = None,
    out: pathlib.Path = None,
    blob_uuid: str = "",
    blob_file: str = "",
    force: bool = False,
) -> "ImageSpec":
    """Unpack images from FIP.

    :param str existing_fip_filepath: Path to an existing FIP.
    :param ImageSpec img_spec: ImageSpec describing fip components to unpack.
    :param Path out: Output path for unpacked images.
    :param str blob_uuid: Unpack an image with the given UUID.
    :param str blob_file: Unpack an image pointed to by file.
    :param bool force: If the output FIP file already exists, overwrite it.
    """
    opts = _make_cmd_opts(
        cmd="unpack",
        func=unpack,
        blob_uuid=blob_uuid,
        blob_file=blob_file,
        force=force,
        out=out,
    )
    _invoke(
        "unpack",
        fip_filename=existing_fip_filepath,
        img_spec=img_spec,
        cmd_opts=opts,
    )
    return info(existing_fip_filepath)


def _make_cmd_opts(cmd, func, *args, **kwargs):
    return CommandOpts.from_boundargs(
        cmd, inspect.signature(func).bind_partial(*args, **kwargs).arguments
    )


@fiptool_error_logger
def _invoke(
    cmd,
    *args,
    img_spec: "ImageSpec" = None,
    fip_filename: pathlib.Path = pathlib.Path(),
    cmd_opts: "CommandOpts" = None
):
    """Invoke the ATF fiptool with the specified options."""
    fiptool_cmd = [ToolPaths.FIPTOOL_BIN, cmd, *args]
    if img_spec is not None:
        fiptool_cmd.extend(str(img_spec).split(" "))
    if cmd_opts is not None:
        fiptool_cmd.extend(str(cmd_opts).split(" "))
    fiptool_cmd.append(str(fip_filename))
    logger.debug(
        "Invoking fiptool with the following command: {}".format(fiptool_cmd)
    )
    return subprocess.run(
        fiptool_cmd,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True,
    )


class OptsDict(UserDict):
    """Dict which generates a flattened list of options when str is called.

    This dict-like object is used to invoke the ATF fiptool with the
    correct options.

    When this object's str method is called it produces an option string
    intended to be passed to the fiptool CLI.

    __setitem__ has been overridden to check for 'valid opts' i.e valid keys.

    This object is intended to be subclassed, the valid_opts attribute should
    be overridden with the option whitelist.
    """

    valid_opts = ()

    def __init__(self, *args, **kwargs):
        """Forward the arguments to the UserDict initialiser."""
        super().__init__(*args, **kwargs)

    def __setitem__(self, opt: str, value: str):
        """Verify the option is valid before adding it to the data."""
        if opt not in self.valid_opts:
            raise UnknownOptionError(self, opt)
        super().__setitem__(opt, value)

    @abstractmethod
    def __str__(self):
        """Create a flattened string of options to pass to the fiptool.

        Subclasses must override this method.
        """


class ImageSpec(OptsDict):
    """Data structure representing FIP image attributes.

    A classmethod is provided to build an instance of this object from
    the fiptool info command output.

    You can use the usual dict semantics to dynamically access or add
    option/value pairs.
    """

    # Valid FIP image attributes.
    valid_opts = (
        "scp-fwu-cfg",
        "ap-fwu-cfg",
        "fwu",
        "fwu-cert",
        "tb-fw",
        "scp-fw",
        "soc-fw",
        "tos-fw",
        "tos-fw-extra1",
        "tos-fw-extra2",
        "nt-fw",
        "hw-config",
        "tb-fw-config",
        "soc-fw-config",
        "tos-fw-config",
        "nt-fw-config",
        "rot-cert",
        "trusted-key-cert",
        "scp-fw-key-cert",
        "soc-fw-key-cert",
        "tos-fw-key-cert",
        "nt-fw-key-cert",
        "tb-fw-cert",
        "scp-fw-cert",
        "soc-fw-cert",
        "tos-fw-cert",
        "nt-fw-cert",
    )

    def __str__(self):
        """Return a flattened str of args to pass to the fiptool."""
        output = str()
        for opt, value in self.data.items():
            if value is True:
                # The option is a flag with no value.
                output = "{output} --{opt}".format(output=output, opt=opt)
            elif value.get("path", 0):
                # The option has an associated file path attribute.
                output = "{output} --{opt}={value}".format(
                    output=output, opt=opt, value=value["path"]
                )
        return output.strip()

    @classmethod
    def from_info(cls, info_output: str) -> "ImageSpec":
        """Create an ImageSpec from fiptool 'info' output."""
        return cls(**ImageSpec._parse_info_output(info_output))

    @staticmethod
    def _parse_info_output(info_output: str) -> dict:
        output = dict()
        optdata = dict()
        for info_line in info_output.split("\n"):
            if not info_line:
                continue
            data, opt = info_line.split("cmdline=")
            if not opt:
                continue
            if "--" in opt:
                opt = opt[3:].strip('" ')
            data = data.split(":")[-1]
            categories = data.split(", ")
            for item in categories:
                if not item:
                    continue
                k, v = item.strip().split("=")
                optdata[k] = v
            output[opt] = optdata
        return output


class CommandOpts(OptsDict):
    """Fiptool command options."""

    cmd_opts = dict(
        create=("align", "blob-uuid", "blob-file", "plat-toc-flags"),
        update=("align", "blob-uuid", "blob-file", "plat-toc-flags", "out"),
        unpack=("blob-uuid", "blob-file", "force", "out"),
        remove=("align", "blob-uuid", "force", "out"),
    )

    def __init__(self, fiptool_cmd, **kwargs):
        """Initialise the object with valid fiptool options.

        :param str fiptool_cmd: the fiptool command the options belong to.
        :param dict **kwargs: generic kwargs forwarded to the parent __init__.
        """
        self.valid_opts = self.cmd_opts[fiptool_cmd]
        super().__init__(**kwargs)

    def __str__(self):
        """Return a flattened str of args to pass to the fiptool."""
        output = str()
        for opt, value in self.data.items():
            if value is True:
                # The option is a flag with no value.
                output = "{output} --{opt}".format(output=output, opt=opt)
            elif value:
                # The option has an associated value.
                output = "{output} --{opt}={value}".format(
                    output=output, opt=opt, value=value
                )
        return output.strip()

    @classmethod
    def from_boundargs(cls, cmd, boundargs):
        """Create an instance of CommandOpts from function 'boundargs'.

        :param str cmd: The fiptool command the options are used with.
        :param dict boundargs: dict of args to transform into fiptool options.
        """
        # If there are no values given return none.
        if not any(val for val in boundargs.values()):
            return None
        opts = cls(cmd)
        for k, v in boundargs.items():
            # convert from snake to kebab case
            k = k.replace("_", "-")
            opts[k] = v
        return opts


class FiptoolInvocationError(Exception):
    """ATF fiptool invocation failed."""


class UnknownOptionError(Exception):
    """Invalid fiptool option given."""

    def __init__(self, opt_dict, attribute):
        """Initialise the exception with a custom msg."""
        msg = (
            "{attr} is not in the known valid options.\n"
            "Known options are:\n {valid_opts}".format(
                attr=attribute, valid_opts="\n".join(opt_dict.valid_opts)
            )
        )
        super().__init__(msg)


def _validate_fiptool_exists():
    try:
        _invoke("version")
    except (FileNotFoundError, subprocess.CalledProcessError):
        raise FiptoolInvocationError(
            "The path to the fiptool is incorrect!\n"
            "The current path is set to '{fiptool_path}'.\n"
            "Please refer to the mbl-signing-lib installation guide: "
            " __REPLACE_ME_WITH_INSTALL_DOC_URL__".format(
                fiptool_path=ToolPaths.FIPTOOL_BIN
            )
        )


# Validate the fiptool exists and can be invoked at module import time.
_validate_fiptool_exists()
