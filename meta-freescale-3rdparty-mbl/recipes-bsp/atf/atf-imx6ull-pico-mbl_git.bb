# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

#require atf-imx7-mbl_git.inc
inherit mbl-artifact-names

require recipes-bsp/atf/atf.inc

PLATFORM = "picopi"

ATF_COMPILE_FLAGS = " "

do_compile () {
	:
}

do_deploy() {
	:
}
