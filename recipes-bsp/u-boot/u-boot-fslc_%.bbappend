SRCREV = "c998f4cdfa0a3cb3118b22e7ea8097635beaa03c"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git@github.com/ARMmbed/mbl-u-boot.git;protocol=ssh;nobranch=1"

UBOOT_CONFIG[sd] = "warp7_secure_optee_defconfig,sdcard"
