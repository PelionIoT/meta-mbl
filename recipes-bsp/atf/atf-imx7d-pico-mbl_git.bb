# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Add this dummy atf recipe to pass build.

PROVIDES += "virtual/atf"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/arm-trusted-firmware.git;protocol=https;nobranch=1;name=atf"
SRCREV_atf = "8a9f3e55ce939f1b2646e044de5eb804437f057f"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://license.rst;md5=e927e02bca647e14efd87e9e914b2443"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

# Although an empty do_deploy() is present in this recipe, the correct code
# (inherit deploy, empty do_deploy and add task directive) are all here so
# when the do_deploy() is popuated everything will work as expected.
inherit deploy

# mbl-console-image.bb has do_image_wic[depends] = "virtual/atf:do_deploy".
# This requires that the following (empty) do_deploy() is present.
do_deploy() {
}

addtask deploy after do_compile
