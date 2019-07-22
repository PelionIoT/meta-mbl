# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

inherit mbl-artifact-names
require recipes-bsp/atf/atf.inc

PLATFORM = "fvp"

ATF_COMPILE_FLAGS = " "

do_compile[noexec] = "1"
do_deploy[noexec] = "1"
