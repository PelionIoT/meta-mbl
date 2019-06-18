#!/usr/bin/env python3
# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

import logging
import pathlib
import subprocess

from collections import namedtuple
from unittest import mock

import pytest

from signing.fip import fiptool
from signing.conf.toolpaths import ToolPaths
from signing.fip import fiputils

logger = logging.getLogger("mbl-signing.fiptool")
logger.setLevel(logging.DEBUG)


@pytest.fixture
def mock_subprocess():
    with mock.patch("signing.fip.fiptool.subprocess") as ms:
        ms.run.return_value = subprocess.CompletedProcess([], 0)
        yield ms


def test_create(mock_subprocess):
    img_spec = fiptool.ImageSpec(
        {
            "tb-fw": {"path": "bl1.bin"},
            "trusted-key-cert": {"path": "rotkey.pem"},
        }
    )
    output = fiptool.create(img_spec, pathlib.Path("fip.bin"))

    assert isinstance(output, subprocess.CompletedProcess)
    mock_subprocess.run.assert_called_once_with(
        [fiptool.ToolPaths.FIPTOOL_BIN, "create", str(img_spec), "fip.bin"],
        check=True,
        capture_output=True,
        text=True,
    )


def test_info(mock_subprocess):
    mock_ret = namedtuple("CompletedProcess", "stdout, stderr, returncode")
    mock_ret.stdout = (
        "Trusted Boot Firmware BL2: offset=0xB0, size=0x145E0, "
        'cmdline="--tb-fw"\n'
        "Trusted Boot Firmware BL2 certificate: offset=0x14C9E, size=0x46F,"
        ' cmdline="--tb-fw-cert"\n'
    )
    mock_subprocess.run.return_value = mock_ret

    spec = fiptool.info(pathlib.Path("fip.bin"))

    expected = ("tb-fw", "tb-fw-cert")
    assert isinstance(spec, fiptool.ImageSpec)
    assert len(spec) == len(expected)
    for i in expected:
        assert i in spec
        assert spec[i].get("offset", 0)
        assert spec[i].get("size", 0)


def test_update(mock_subprocess):
    img_spec = fiptool.ImageSpec({"soc-fw-cert": dict()})
    output = fiptool.update(img_spec, pathlib.Path("fip.bin"))

    assert isinstance(output, subprocess.CompletedProcess)
    mock_subprocess.run.assert_called_once_with(
        [fiptool.ToolPaths.FIPTOOL_BIN, "update", str(img_spec), "fip.bin"],
        check=True,
        capture_output=True,
        text=True,
    )


def test_unpack(mock_subprocess):
    mock_ret = namedtuple("CompletedProcess", "stdout, stderr, returncode")
    mock_ret.stdout = (
        "Trusted Boot Firmware BL2: offset=0xB0, size=0x145E0, "
        'cmdline="--tb-fw"\n'
        "Trusted Boot Firmware BL2 certificate: offset=0x14C9E, size=0x46F,"
        ' cmdline="--tb-fw-cert"\n'
    )
    mock_subprocess.run.return_value = mock_ret

    img_spec = fiptool.ImageSpec({"nt-fw": True, "trusted-key-cert": True})
    fiptool.unpack(pathlib.Path("fip.bin"), img_spec=img_spec)

    mock_subprocess.run.assert_any_call(
        [
            fiptool.ToolPaths.FIPTOOL_BIN,
            "unpack",
            "--nt-fw --trusted-key-cert",
            "fip.bin",
        ],
        check=True,
        capture_output=True,
        text=True,
    )


def test_remove(mock_subprocess):
    img_spec = fiptool.ImageSpec({"soc-fw-cert": dict()})
    output = fiptool.remove(img_spec, pathlib.Path("fip.bin"))

    assert isinstance(output, subprocess.CompletedProcess)
    mock_subprocess.run.assert_called_once_with(
        [fiptool.ToolPaths.FIPTOOL_BIN, "remove", str(img_spec), "fip.bin"],
        check=True,
        capture_output=True,
        text=True,
    )


def test_remove_with_opts(mock_subprocess):
    img_spec = fiptool.ImageSpec({"soc-fw-cert": {"path": "fw_cert.pem"}})
    output = fiptool.remove(
        img_spec,
        "fip.bin",
        align=1,
        blob_uuid="2222",
        force=True,
        out=pathlib.Path("output", "path"),
    )

    assert isinstance(output, subprocess.CompletedProcess)
    mock_subprocess.run.assert_called_once_with(
        [
            fiptool.ToolPaths.FIPTOOL_BIN,
            "remove",
            str(img_spec),
            "--align=1 --blob-uuid=2222 --force --out=output/path",
            "fip.bin",
        ],
        check=True,
        capture_output=True,
        text=True,
    )


def test_image_spec_invalid_options():
    with pytest.raises(fiptool.UnknownOptionError):
        fiptool.ImageSpec({"invalid": "aaaaa"})


@pytest.mark.parametrize(
    "cmd, options",
    (
        ("unpack", {"blah": "1", "not": "2", "real": "3", "options": "4"}),
        ("create", {"blah": "1", "not": "2", "real": "3", "options": "4"}),
        ("remove", {"blah": "1", "not": "2", "real": "3", "options": "4"}),
    ),
)
def test_cmd_opts_invalid_options(cmd, options):
    with pytest.raises(fiptool.UnknownOptionError):
        fiptool.CommandOpts.from_boundargs(cmd, options)
    with pytest.raises(fiptool.UnknownOptionError):
        opts = fiptool.CommandOpts(cmd)
        opts.update(options)
    with pytest.raises(fiptool.UnknownOptionError):
        fiptool.CommandOpts(cmd, **options)


def test_optsdict_cannot_be_directly_instantiated():
    with pytest.raises(
        TypeError,
        match=(
            "Can't instantiate abstract class OptsDict with abstract "
            "methods __str__"
        ),
    ):
        fiptool.OptsDict()


def test_raises_correct_exception_on_invalid_command(tmp_path):
    with pytest.raises(fiputils.FiptoolCommandError) as err:
        fiptool.create(fiptool.ImageSpec(), tmp_path)
        assert err.return_code is not 0
        assert err.stderr is not None
        assert str(err) != ""


def test_fiptool_check_fails_with_invalid_toolpath():
    with pytest.raises(fiptool.FiptoolInvocationError):
        ToolPaths.FIPTOOL_BIN = "jfalkjaflkja"
        fiptool._validate_fiptool_exists()
