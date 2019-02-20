#!/bin/sh

# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

HOME_APP=__REPLACE_ME_WITH_MBL_APP_DIR__

echo "Run all installed applications found at $HOME_APP..." 1>&2
mbl-app-lifecycle-manager --verbose run-all

