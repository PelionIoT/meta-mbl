# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

python __anonymous() {
    # If the second bootloader slot in mbl.wks.in is being used for BL3, set
    # the BL3 offset that is used by BL2 to be same as the offset of the second
    # bootloader slot in mbl.wks.in
    wks_bootloader2_is_bl3_str = d.getVar('MBL_WKS_BOOTLOADER2_IS_BL3', True)
    wks_bootloader2_is_bl3 = wks_bootloader2_is_bl3_str and int(wks_bootloader2_is_bl3_str)
    if wks_bootloader2_is_bl3:
        bl3_offset_KiB = int(d.getVar('MBL_WKS_BOOTLOADER2_OFFSET_BANK1_KiB', True))
        bl3_offset_B = bl3_offset_KiB * 1024
        d.setVar('MBL_FIP_ROM_OFFSET', str(bl3_offset_B))
}
