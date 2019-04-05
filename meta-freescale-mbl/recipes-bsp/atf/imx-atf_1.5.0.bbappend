# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Use of this imx-atf_1.5.0.bb(append) is a temporary measure
# for importing the imx8mmevk BSP as-is from the vendor.
# It will be removed when the BSP adopts the generic ATF
# recipe structure (i.e. adopting atf.inc).
#
# NOTE: imx-atf_1.5.0.bb does the following
# - Uses the imx-atf repository at codeaurora here: git://source.codeaurora.org/external/imx/imx-atf.git
# - checks the BSD-3-Clause license in the openembedded-core layer, rather than checking the
#   license.rst in the source repo.
# When the standard recipe processing is adopted, the license checking should check the
# license in the source repo.

PROVIDES += "virtual/atf"

SRCBRANCH = "imx_4.14.78_1.0.0_ga"
SRCREV = "d6451cc1e162eff89b03dd63e86d55b9baa8885b"

# This option tells ATF to use optee for runtime SPD instead of internal ATF code.
EXTRA_OEMAKE += " SPD=opteed "
