# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Images that use MBL secure boot should inherit from this class

do_image_wic[depends] += "virtual/atf:do_deploy"

# Convince the task that creates image_license.manifest to include atf.
do_populate_lic_deploy[depends] += "virtual/atf:do_deploy"
