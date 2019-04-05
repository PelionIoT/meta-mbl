# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

inherit python3native
create_dummy_firmware_update_header() {
    install -d "${IMAGE_ROOTFS}${MBL_BOOTFLAGS_DIR}"
    "${MBL_APPS_LAYER_SCRIPTS}/create-dummy-firmware-update-header.py" > "${IMAGE_ROOTFS}${MBL_BOOTFLAGS_DIR}/header"
}

IMAGE_PREPROCESS_COMMAND += "create_dummy_firmware_update_header;"
do_image[depends] += "mbl-firmware-update-header-util-native:do_populate_sysroot"
