SRCREV = "4cc8bb37298f02ccfb02e7af0a10b883b2b133d4"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git@github.com/ARMmbed/mbl-u-boot.git;protocol=ssh;nobranch=1"

UBOOT_CONFIG[sd] = "warp7_secure_optee_defconfig,sdcard"
