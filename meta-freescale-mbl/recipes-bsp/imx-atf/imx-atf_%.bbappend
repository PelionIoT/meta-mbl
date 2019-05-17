# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

ATF_NAME_APPEND = "${@bb.utils.contains('COMBINED_FEATURES', 'optee', '-optee', '', d)}"

do_deploy() {
    install -Dm 0644 ${S}/build/${PLATFORM}/release/bl31.bin ${DEPLOYDIR}/${BOOT_TOOLS}/bl31-${PLATFORM}.bin${ATF_NAME_APPEND}
}
