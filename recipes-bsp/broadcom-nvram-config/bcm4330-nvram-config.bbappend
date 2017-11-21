SUMMARY = "Freescale IMX WaRP7 firmware"
DESCRIPTION = "Freescale IMX WaRP7 firmware for BRCM"
SECTION = "base"
LICENSE = "Proprietary"

SRCBRANCH = "master"
PV="0.12_git${SRCREV}"
SRCREV_linuxfirmware = "a61ac5cf8374edbfe692d12f805a1b194f7fead2"
SRCREV_recalboxbuildroot = "f648e4b54eb5e4be593746d6cc51375b22a7efbd"
SRCREV_miscfirmware = "487c7ee143ba6e8a25cf1883938ff91c9e5d6f19"

BB_STRICT_CHECKSUM = "0"
SRC_URI = "git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git;branch=${SRCBRANCH};destsuffix=${S}/git1;name=linuxfirmware \
git://github.com/recalbox/recalbox-buildroot.git;protocol=https;branch=${SRCBRANCH};destsuffix=${S}/git2;name=recalboxbuildroot \
git://github.com/OpenELEC/misc-firmware.git;protocol=https;branch=${SRCBRANCH};destsuffix=${S}/git3;name=miscfirmware "
LIC_FILES_CHKSUM = "file://git1/LICENCE.broadcom_bcm43xx;md5=3160c14df7228891b868060e1951dfbc \
                    file://git2/COPYING;md5=e4edbc78b8892db416b6a07e0d97309a \
                    file://git3/GPL-3;md5=f27defe1e96c2e1ecd4e0c9be8967949 "

do_install() {
    install -d ${D}${base_libdir}/firmware
    install -d ${D}${base_libdir}/firmware/brcm

    cp -rfv git1/brcm/brcmfmac43430-sdio.bin ${D}${base_libdir}/firmware/brcm
    cp -rfv git2/board/warp7/rootfs_overlay/lib/firmware/brcm/brcmfmac43430-sdio.txt ${D}${base_libdir}/firmware/brcm
    cp -rfv git3/firmware/brcm/BCM43430A1.hcd ${D}${base_libdir}/firmware
}

ALLOW_EMPTY_${PN} = "1"
#FILES_${PN} = "${base_libdir}/firmware/brcm/brcmfmac43430* ${base_libdir}/firmware/BCM43430A1.hcd"
FILES_${PN}-bcm43430 = "${base_libdir}/firmware/brcm/brcmfmac43430* ${base_libdir}/firmware/BCM43430A1.hcd"

COMPATIBLE_MACHINE = "(imx7s-warp)"
