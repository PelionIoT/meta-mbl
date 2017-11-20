SRCREV = "9d0cacf402425e29a316b09610be2debbf38dc6c"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git@github.com/ARMmbed/mbl-u-boot.git;protocol=ssh;nobranch=1"

UBOOT_CONFIG[sd] = "warp7_secure_optee_defconfig,sdcard"
