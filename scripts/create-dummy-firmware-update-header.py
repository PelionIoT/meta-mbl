#!/usr/bin/env python3
# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""
Write dummy firmware update HEADER data to stdout.

The "version" field will be set to the current UNIX timestamp.
The "campaign_id" field will be set to zeroes.
The "firmware_hash" field will be set to zeroes.
The "magic" and "checksum" fields will be valid"

The existence of this script is just a hack - we need to run some Python code
when an MBL image is being created to add a firmware update HEADER file, but we
can't just add that Python code straight into a function called by BitBake
because BitBake calls functions using the host's Python installation, and we
need to use a library that the host installation probably doesn't have.

To get around that, put the code into this script, which can be run from a
BitBake function using a version of Python that has access to the required
library.
"""
import sys
import time
import mbl.firmware_update_header_util as hu

header = hu.FirmwareUpdateHeader()
header.firmware_version = int(time.time())
header_data = header.pack()
sys.stdout.buffer.write(header_data)
