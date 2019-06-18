#!/usr/bin/env python3
# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

import subprocess
from unittest import mock
import pytest

from signing.fitimage import mkimage
import logging

logger = logging.getLogger("mbl-signing.fit")
logger.setLevel(logging.DEBUG)

VALID_BOOT_CMD = """setenv mmcroot /dev/mmcblk1p3 rootwait rw
setenv image Image-initramfs-imx8mmevk-mbl.bin
run loadimage
run mmcboot"""

VALID_ITS_DATA = """/dts-v1/;

/ {
        description = "U-Boot fitImage for Mbed Linux OS/imx7s-warp-mbl";
        #address-cells = <1>;

        images {
                kernel@test {
                        description = "Linux kernel";
                        data = /incbin/("testlinux.bin");
                        type = "kernel";
                        arch = "arm";
                        os = "linux";
                        compression = "none";
                        load = <0x80800000>;
                        entry = <0x80800000>;
                        hash@1 {
                                algo = "sha1";
                        };
                };
                fdt@test {
                        description = "Flattened Device Tree blob";
                        data = /incbin/("test.dtb");
                        type = "flat_dt";
                        arch = "arm";
                        compression = "none";
                        load = <0x83000000>;
                        hash@1 {
                                algo = "sha1";
                        };
                };
                bootscr {
                        description = "U-boot boot script";
                        data = /incbin/("testboot.cmd");
                        type = "script";
                        arch = "arm";
                        compression = "none";
                        hash@1 {
                                algo = "sha1";
                        };
                };
        };

        configurations {
                default = "conf@test";
                conf@test {
                    description = "1 Linux kernel, FDT blob";
                    kernel = "kernel@test";
                    fdt = "fdt@test";

                    loadables = "bootscr";
                        hash@1 {
                                algo = "sha1";
                        };
                };
        };
};"""

# Removed conditionally mandatory property "address-cells", which is mandatory
# in our case, as we specify load addresses in the sub-image nodes.
INVALID_ITS_DATA = """/dts-v1/;

/ {
        description = "U-Boot fitImage for Mbed Linux OS/imx7s-warp-mbl";

        images {
                kernel@test {
                        description = "Linux kernel";
                        data = /incbin/("testlinux.bin");
                        type = "kernel";
                        arch = "arm";
                        os = "linux";
                        compression = "none";
                        load = <0x80800000>;
                        entry = <0x80800000>;
                        hash@1 {
                                algo = "sha1";
                        };
                };
                fdt@test {
                        description = "Flattened Device Tree blob";
                        data = /incbin/("test.dtb");
                        type = "flat_dt";
                        arch = "arm";
                        compression = "none";
                        load = <0x83000000>;
                        hash@1 {
                                algo = "sha1";
                        };
                };
                bootscr {
                        description = "U-boot boot script";
                        data = /incbin/("testboot.cmd");
                        type = "script";
                        arch = "arm";
                        compression = "none";
                        hash@1 {
                                algo = "sha1";
                        };
                };
        };

        configurations {
                default = "conf@test";
                conf@test {
                    description = "1 Linux kernel, FDT blob";
                    kernel = "kernel@test";
                    fdt = "fdt@test";

                    loadables = "bootscr";
                        hash@1 {
                                algo = "sha1";
                        };
                };
        };
};"""

STDOUT_SUCCESS = (
    "Image 1 (fdt@test)",
    "Image 2 (bootscr)",
    "Configuration 0 (conf@test)",
    "Description:  1 Linux kernel, FDT blob",
    "Kernel:       kernel@test",
    "FDT:          fdt@test",
    "Loadables:    bootscr",
)

STDOUT_SUCCESS_BOOT_CMD = (
    "Image Name:   Boot script",
    "Created:",
    "Image Type:   ARM Linux Script (uncompressed)",
    "Data Size:    122 Bytes = 0.12 kB = 0.00 MB",
    "Load Address: 00000000",
    "Entry Point:  00000000",
    "Image 0: 114 Bytes = 0.11 kB = 0.00 MB",
)


@pytest.fixture
def test_fitimage_blobs(tmp_path):
    kernel = tmp_path / "testlinux.bin"
    ftd = tmp_path / "test.dtb"
    bootscr = tmp_path / "testboot.cmd"
    kernel.touch(exist_ok=True)
    ftd.touch(exist_ok=True)
    bootscr.touch(exist_ok=True)
    yield kernel, ftd, bootscr


@pytest.fixture
def valid_its_path(tmp_path):
    its_path = tmp_path / "valid.its"
    its_path.touch(exist_ok=True)
    its_path.write_text(VALID_ITS_DATA)
    yield its_path


@pytest.fixture
def invalid_its_path(tmp_path):
    its_path = tmp_path / "invalid.its"
    its_path.touch(exist_ok=True)
    its_path.write_text(INVALID_ITS_DATA)
    yield its_path


@pytest.fixture
def valid_boot_cmd_path(tmp_path):
    bcp = tmp_path / "boot.cmd"
    bcp.touch(exist_ok=True)
    bcp.write_text(VALID_BOOT_CMD)
    yield bcp


def test_list_image_header_info(valid_its_path):
    m = mkimage.MkImage()
    expected = ["GP Header: Size 2f647473 LoadAddr 2d76312f"]
    output = m.list_img_header_info(valid_its_path)
    assert output == expected


def test_list_image_types():
    expected_image_types = (
        "aisimage",
        "atmelimage",
        "filesystem",
        "firmware",
        "flat_dt",
        "gpimage",
        "imximage",
        "kernel",
        "kernel_noload",
        "kwbimage",
        "lpc32xximage",
        "multi",
        "omapimage",
        "pblimage",
        "ramdisk",
        "rkimage",
        "rksd",
        "rkspi",
        "script",
        "socfpgaimage",
        "standalone",
        "ublimage",
        "zynqimage",
    )
    m = mkimage.MkImage()
    itl = m.list_image_types()
    assert isinstance(itl, tuple)
    assert len(itl) == len(expected_image_types)
    assert all(expected in itl for expected in expected_image_types)


@pytest.mark.parametrize("opt", (["--space 1"],))
def test_fit_image_creation_with_dtc_opts(
    test_fitimage_blobs, opt, valid_its_path, tmp_path
):
    with mock.patch("signing.fitimage.mkimage.subprocess") as mock_sp:
        m = mkimage.MkImage()
        m.create_fit_img(valid_its_path, tmp_path / "fit.itb", dtc_opts=opt)

        mock_sp.run.assert_called_with(
            [
                "mkimage",
                "-D",
                "--space 1",
                "-f",
                str(valid_its_path),
                str(tmp_path / "fit.itb"),
            ],
            capture_output=True,
            text=True,
            check=True,
        )


@pytest.mark.parametrize("opt", (["invalid"],))
def test_rejects_invalid_dtc_opts(opt, valid_its_path, tmp_path):
    m = mkimage.MkImage()
    with pytest.raises(subprocess.CalledProcessError) as err:
        m.create_fit_img(valid_its_path, tmp_path / "img.itb", dtc_opts=opt)

    assert r"Usage: dtc [options]" in err.value.stderr


def test_fit_image_creation_with_its(
    test_fitimage_blobs, valid_its_path, tmp_path
):
    output_path = tmp_path / "fitvalid.itb"
    m = mkimage.MkImage()
    mkimage_output = m.create_fit_img(valid_its_path, output_path)

    assert all(expect in mkimage_output.stdout for expect in STDOUT_SUCCESS)
    assert mkimage_output.returncode == 0
    assert not mkimage_output.stderr
    assert output_path.is_file()


def test_rejects_invalid_its(tmp_path, invalid_its_path):
    output_path = tmp_path / "fitinvalid"
    output_path.touch(exist_ok=True)
    m = mkimage.MkImage()
    with pytest.raises(subprocess.CalledProcessError) as exc_info:
        m.create_fit_img(invalid_its_path, output_path)

    expected_stderr = "mkimage Can't add hashes to FIT blob\n"
    assert (
        expected_stderr.format(out_path=output_path) in exc_info.value.stderr
    )
    assert exc_info.value.returncode == 255


def test_modify_fit_image(tmp_path, test_fitimage_blobs, valid_its_path):
    mock_fit_path = tmp_path / "fit.itb"
    mock_key_path = tmp_path / "rotkey.pem"
    mock_key_path.touch()
    m = mkimage.MkImage()
    m.create_fit_img(valid_its_path, mock_fit_path)

    result = m.modify_fit_img(
        img_path=mock_fit_path, key_dir=mock_key_path, key_required=True
    )

    assert all(expect in result.stdout for expect in STDOUT_SUCCESS)
    assert not result.stderr
    assert result.returncode == 0


def test_make_boot_cmd(tmp_path, valid_boot_cmd_path):
    m = mkimage.MkImage()
    result = m.create_legacy_image(
        tmp_path / "boot.scr",
        arch="arm",
        img_type="script",
        compression="none",
        data_file_path=valid_boot_cmd_path,
        name="Boot script",
    )

    assert all(expect in result.stdout for expect in STDOUT_SUCCESS_BOOT_CMD)
    assert not result.stderr
