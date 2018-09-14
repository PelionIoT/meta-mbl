SUMMARY = "Mbed Linux (mbl) package group to be used in the test environment"
DESCRIPTION = "\
    This package adds libraries and packages required by the test environment \
    used to test Mbed Linux. \
"

inherit packagegroup

###############################################################################
# MACHINE independent packages
###############################################################################
PACKAGEGROUP_MBL_TEST_ENV_PKGS_append = " pytest-mbl-testing"
PACKAGEGROUP_MBL_TEST_ENV_PKGS_append = " python3-mbl-testing"

RDEPENDS_packagegroup-mbl-test-env += "${PACKAGEGROUP_MBL_TEST_ENV_PKGS}"