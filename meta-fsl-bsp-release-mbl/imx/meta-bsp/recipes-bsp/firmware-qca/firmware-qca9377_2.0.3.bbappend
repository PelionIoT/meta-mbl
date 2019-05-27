# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Remove the CHKSUM of the file from meta-freescale/EULA
LIC_FILES_CHKSUM_remove = "file://${FSL_EULA_FILE};md5=ab61cab9599935bfe9f700405ef00f28"

# Add the CHKSUM of the file from meta-fsl-bsp-release/imx/EULA.txt
LIC_FILES_CHKSUM_append = " file://${FSL_EULA_FILE};md5=6dfb32a488e5fd6bae52fbf6c7ebb086"
