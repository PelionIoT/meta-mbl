# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause


"""Setup script."""

from setuptools import setup, find_packages


setup(
    name="signctl",
    author="Arm Ltd.",
    license="BSD-3-Clause",
    version="0.0.9",
    packages=find_packages(exclude=["*.pyc", "*test_*", "*__pycache__*"]),
    install_requires=[
        (
            "mbl-signing-lib @ "
            "git+https://github.com/ARMmbed/meta-mbl.git"
            "@warrior-dev#egg=mbl-signing-lib-1.0.0"
            "&subdirectory=openembedded-core-mbl/scripts/lib/mbl-signing"
        )
    ],
    entry_points={"console_scripts": ["signctl = src.signctl:main"]},
)
