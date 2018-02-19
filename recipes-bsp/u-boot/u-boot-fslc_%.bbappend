SRCREV = "224318f95f9e41f916579a20f3275ff3773f9c94"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git@github.com/ARMmbed/mbl-u-boot.git;protocol=ssh;nobranch=1 \
file://files/0001-warp7-use-UART6-in-secure-defconfig.patch "

UBOOT_CONFIG[sd] = "warp7_secure_defconfig,sdcard"
