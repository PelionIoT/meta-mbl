#!/usr/bin/env python3
# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""Install mbl-signing-lib package."""

from distutils.command.build import build
import subprocess

from setuptools import setup, find_packages


NOTICE = (
    "\nTrusted Firmware build failed!\n\n"
    "If you are running Ubuntu 16.04, "
    "please ensure you have the following packages installed "
    "before building the library:\n\n"
    "git\nmake\nu-boot-tools\nbuild-essential\nlibssl-dev\nlibffi-dev\n\n"
)


class BuildError(Exception):
    """Trusted Firmware Tools build failed."""


class ArmTrustedFirmwareToolsBuild(build):
    """Compile the tools from ATF."""

    def run(self):
        """Clone and build the ATF dependencies."""
        subprocess.run(
            [
                "git",
                "clone",
                "https://github.com/ARM-software/arm-trusted-firmware.git",
                "--branch",
                "v2.1",
                "--depth",
                "1",
            ],
            check=True,
        )
        try:
            subprocess.run(
                ["make", "fiptool"], cwd="arm-trusted-firmware", check=True
            )
        except subprocess.CalledProcessError as err:
            raise BuildError(NOTICE) from err
        subprocess.run(
            ["cp", "tools/fiptool/fiptool", "../signing"],
            cwd="arm-trusted-firmware",
            check=True,
        )
        build.run(self)


setup(
    name="mbl-signing-lib",
    author="Arm Ltd.",
    license="BSD-3-Clause",
    version="1.0.0",
    packages=find_packages(exclude=["*.pyc", "*test_*", "*__pycache__*"]),
    include_package_data=True,
    install_requires=[
        "hvac",
        "pyasn1",
        "cryptography",
        "connexion[swagger-ui]",
        "requests",
    ],
    tests_require=["pytest", "pexpect"],
    cmdclass={"build": ArmTrustedFirmwareToolsBuild},
)
