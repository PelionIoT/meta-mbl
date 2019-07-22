# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

inherit mbl-artifact-names
require recipes-bsp/atf/atf.inc

# Replace from here:
# to here: with atf-imx7-mbl_git.inc if/when compiling ATF for this target

PLATFORM = "picopi"

ATF_COMPILE_FLAGS = " "

do_compile[noexec] = "1"
do_deploy[noexec] = "1"
