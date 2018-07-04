SUMMARY = "mbed linux additional packages for test distribution"
DESCRIPTION = "mbed linux additional packages to those of the minimal console default setup for test and development."

inherit packagegroup


###############################################################################
# Packages added irrespective of the MACHINE
#     - dropbear. To support ssh during development and test,
###############################################################################
PACKAGEGROUP_MBL_TEST_PKGS_append = " dropbear"
PACKAGEGROUP_MBL_TEST_PKGS_append = " dropbear-ssh-dns-sd"
PACKAGEGROUP_MBL_TEST_PKGS_append = " bash"
PACKAGEGROUP_MBL_TEST_PKGS_append = " python python-pip"
PACKAGEGROUP_MBL_TEST_PKGS_append = " python3 python3-pip"
PACKAGEGROUP_MBL_TEST_PKGS_append = " e2fsprogs"
PACKAGEGROUP_MBL_TEST_PKGS_append = " memtester"


###############################################################################
# Packages that can optionally be added (irrespective of MACHINE)
#     - kernel-devsrc. Include kernel development sources.
# Uncomment the relevant line to include the package
###############################################################################
#PACKAGEGROUP_MBL_TEST_PKGS_append_imx7s-warp = " kernel-devsrc"


###############################################################################
# Packages added for MACHINE=imx7s-warp
#     - v4l-utils. MACHINE has video4linux camera driver so includ utils.
#     - optee-test. MACHINE supports optee so include the optee test suite.
###############################################################################
PACKAGEGROUP_MBL_TEST_PKGS_append_imx7s-warp = " v4l-utils"
PACKAGEGROUP_MBL_TEST_PKGS_append_imx7s-warp = " optee-test"

PACKAGEGROUP_MBL_TEST_PKGS_append_bananapi-zero = " optee-test"
PACKAGEGROUP_MBL_TEST_PKGS_append_raspberrypi3 = " optee-test"


RDEPENDS_packagegroup-mbl-test += "${PACKAGEGROUP_MBL_TEST_PKGS}"



