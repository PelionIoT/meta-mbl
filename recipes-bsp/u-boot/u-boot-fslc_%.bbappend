SRCBRANCH = "linaro-warp7"
SRCREV = "0a35577ba0a2d23a8c8f088dbcdbedb3490a47e9"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git@github.com/ARMmbed/mbl-u-boot.git;protocol=ssh;branch=${SRCBRANCH}"
SRC_URI += "file://warp7.h-Use-ext4load-to-load-everything-from-ext4-pa.patch"

UBOOT_CONFIG[sd] = "warp7_secure_optee_defconfig,sdcard"
