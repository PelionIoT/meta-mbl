SRCBRANCH = "linaro-warp7"
SRCREV = "ce2a7353dbc47bef59db647614ad52a83247c8b6"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git@github.com/ARMmbed/mbl-u-boot.git;protocol=ssh;branch=${SRCBRANCH}"
SRC_URI += "file://warp7.h-Temporary-use-mmcboot-instead-of-mmcbootsec-.patch"

UBOOT_CONFIG[sd] = "warp7_secure_optee_defconfig,sdcard"
