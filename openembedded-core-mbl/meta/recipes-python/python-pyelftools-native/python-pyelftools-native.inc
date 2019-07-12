# Based on: python-pyelftools-native.inc
# In open-source project: https://github.com/priv-kweihmann/meta-sca.git
#
# Original file: Copyright (c) 2019 Konrad Weihmann <kweihmann@outlook.com>
# Modifications: Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-2-Clause

SUMMARY = "Parsing ELF and DWARF in Python"
DESCRIPTION = "Parsing ELF and DWARF in Python"
HOMEPAGE = "https://github.com/eliben/pyelftools"
LICENSE = "PYELFTOOLS"
LIC_FILES_CHKSUM = "file://LICENSE;md5=5ce2a2b07fca326bc7c146d10105ccfc"

RDEPENDS_${PN} += "${PYTHON_PN}-native"

PYPI_PACKAGE = "pyelftools"

inherit pypi

FILES_${PN} += "${datadir}/pyelftools"

inherit native
