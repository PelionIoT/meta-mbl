SRCBRANCH = "linaro-warp7"
SRCREV = "9643d8cd1cfde007058e373f027a08263f47cd0d"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git@github.com/ARMmbed/mbl-u-boot.git;protocol=ssh;branch=${SRCBRANCH}"

UBOOT_CONFIG[sd] = "warp7_secure_optee_defconfig,sdcard"
