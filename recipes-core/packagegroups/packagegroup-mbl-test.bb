SUMMARY = "mbed linux additional packages for test distribution"
DESCRIPTION = "mbed linux additional packages to those of the minimal console default setup for test and development."

inherit packagegroup

###############################################################################
# RDEPENDS_packagegroup-mbl-test
#    The list of runtime depends packages includes:
#      - kernel-devsrc. Include kernel development sources.
#      - optee-test. If this MACHINE supportes optee then include the optee
#        test suite.
###############################################################################
RDEPENDS_packagegroup-mbl-test += "\
    kernel-devsrc \
    ${@bb.utils.contains("MACHINE", "imx7s-warp", "optee-test", "", d)} \
    "

