# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# imx-boot recipe from meta-freescale DEPENDS on firmware-imx-8m
PROVIDES_imx8mmevk-mbl += "firmware-imx-8m"

# Remove the CHKSUM of the file from meta-freescale/EULA
LIC_FILES_CHKSUM_remove = "file://${FSL_EULA_FILE};md5=6c12031a11b81db21cdfe0be88cac4b3"

# Add the CHKSUM of the file from meta-fsl-bsp-release/imx/EULA.txt
LIC_FILES_CHKSUM_append = " file://${FSL_EULA_FILE};md5=6dfb32a488e5fd6bae52fbf6c7ebb086"
