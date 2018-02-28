SRCREV = "224318f95f9e41f916579a20f3275ff3773f9c94"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git.linaro.org/landing-teams/working/mbl/u-boot.git;protocol=https;nobranch=1"

UBOOT_CONFIG[sd] = "warp7_secure_defconfig,sdcard"
