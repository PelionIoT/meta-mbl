# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Create the python3-pathlib and python3-ntpath packages as they are
# dependencies of Pytest.
#
# There is not much point upstreaming a fix because python3-pytest is a package
# provided by OE and it has all required dependencies.
#
# The below is only necessary because Pytest is installed on a system running
# MBL OS only for the purpose of running system tests. Thus Pytest expects all
# dependencies to be present on the OS image already.
PACKAGES =+ "${PN}-ntpath"
FILES_${PN}-ntpath += "${libdir}/python${PYTHON_MAJMIN}/ntpath.py"

PACKAGES =+ "${PN}-pathlib"
FILES_${PN}-pathlib += "${libdir}/python${PYTHON_MAJMIN}/pathlib.py"
