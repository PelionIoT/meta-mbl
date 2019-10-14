# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# When the PACKAGECONFIG is 'kernel-console-only' we use the "securetty" file from meta-mbl-distro
# that only contains the "console" string. The main recipe will add the devices listed in the
# ${SERIAL_CONSOLES} variable.
FILESEXTRAPATHS_prepend := "${@bb.utils.contains('PACKAGECONFIG','kernel-console-only','${THISDIR}/${PN}:','',d)}"

PACKAGECONFIG[kernel-console-only] = ""
