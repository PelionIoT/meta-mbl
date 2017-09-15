SRCBRANCH = "mbl-warp7"
SRCREV = "${SRCBRANCH}"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git@github.com/ARMmbed/mbl-u-boot.git;protocol=ssh;branch=${SRCBRANCH}"
SRC_URI += "file://warp7.h-Temporary-use-mmcboot-instead-of-mmcbootsec-.patch"

UBOOT_CONFIG[sd] = "warp7_secure_optee_defconfig,sdcard"
