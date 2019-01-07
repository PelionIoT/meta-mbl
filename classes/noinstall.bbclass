# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT


# Description
# -----------
# This class is for recipes that don't have a do_install task (they don't
# produce packages or contribute anything to the root file system). It sets a
# couple of variables and removes some tasks so that BitBake is more likely to
# catch errors when the recipe is misused.
#
# Usage
# ----------
# Just add "inherit noinstall" to your recipe. For maximum effectiveness, put
# that at the end of the recipe.
#

PACKAGES = ""
RPROVIDES = ""

# The nopackages class removes packaging related tasks
inherit nopackages

deltask do_install
deltask do_populate_sysroot
deltask do_populate_sysroot_setscene
