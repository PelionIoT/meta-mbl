SUMMARY = "Mbed Linux (mbl) package group to be used in the test environment"
DESCRIPTION = "This package adds libraries and packages required by the test environment used to test Mbed Linux."

inherit packagegroup


###############################################################################
# MACHINE independent packages
###############################################################################
PACKAGEGROUP_MBL_TEST_ENV_PKGS_append = " pytest-mbl-testing"
PACKAGEGROUP_MBL_TEST_ENV_PKGS_append = " python-numpy"
PACKAGEGROUP_MBL_TEST_ENV_PKGS_append = " python-scipy-stats"
PACKAGEGROUP_MBL_TEST_ENV_PKGS_append = " python3-mbl-testing"



###############################################################################
# <MACHINE> specific packages
# Add packages required for a given machine
###############################################################################
#PACKAGEGROUP_MBL_TEST_ENV_PKGS_append_<MACHINE> = ""


RDEPENDS_packagegroup-mbl-test-env += "${PACKAGEGROUP_MBL_TEST_ENV_PKGS}"