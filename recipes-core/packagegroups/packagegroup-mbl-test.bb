SUMMARY = "mbed linux additional packages for test distribution"
DESCRIPTION = "mbed linux additional packages to those of the minimal console default setup for test and development."

inherit packagegroup

###############################################################################
# RDEPENDS_packagegroup-mbl-test
#    The list of runtime depends packages can include:
#      - kernel-devsrc. Include kernel development sources.
#      - optee-test. If this MACHINE supportes optee then include the optee
#        test suite.
# Uncomment the relevant line to include the package
###############################################################################

# RDEPENDS_packagegroup-mbl-test += " kernel-devsrc"
RDEPENDS_packagegroup-mbl-test += " ${@bb.utils.contains_any("MACHINE", "imx7s-warp imx7s-warp-mbl", "optee-test ", "", d)}"



