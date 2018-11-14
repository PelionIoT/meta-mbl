#!/bin/sh
# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

source __REPLACE_ME_WITH_MBL_APP_DIR__/__REPLACE_ME_WITH_libdir__/set-up-test-env.sh
exec pip3.5 "$@"
