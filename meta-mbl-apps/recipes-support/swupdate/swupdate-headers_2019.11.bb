# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Building swupdate together with MBL's custom handlers is a bit convoluted.
# See the comment in swupdate_%.bbappend for details.

require recipes-support/swupdate/swupdate_${PV}.bb
require swupdate-append-common.inc

# Make sure that we can find files in meta-swupdate that the recipe needs...
FILESEXTRAPATHS_prepend := "${OEROOT}/layers/meta-swupdate/recipes-support/swupdate/swupdate:"

# ...But prepend our own files path *after* prepending the meta-swupdate path
# so that our files take precedence.
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SUMMARY = "Header files for building handlers for swupdate"
DESCRIPTION = "${SUMMARY}"

PACKAGES = "${PN}-dev"
FILES_${PN}-dev = "${includedir}/*"
RDEPENDS_${PN}-dev = ""

do_compile[noexec] = "1"

do_install() {
    install -d "${D}${includedir}"
    cp -R --no-dereference --preserve=mode,links -v "${S}/include" "${D}${includedir}/swupdate"
}
