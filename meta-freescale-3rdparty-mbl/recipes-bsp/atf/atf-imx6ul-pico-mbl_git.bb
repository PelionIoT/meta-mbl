# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

inherit mbl-artifact-names
require recipes-bsp/atf/atf.inc

# Replace from here:
MBL_ATF_VERSION = "2.0"
SRCREV_atf = "6a80c8bbc961ab55a562e0030247419e363286f7"
# to here: with atf-imx7-mbl_git.inc if/when compiling ATF for this target

PLATFORM = "picopi"

ATF_COMPILE_FLAGS = " "

do_compile[noexec] = "1"
do_deploy[noexec] = "1"
