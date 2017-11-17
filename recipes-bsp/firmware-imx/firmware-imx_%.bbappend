
SRCREV_linuxfirmware = "a61ac5cf8374edbfe692d12f805a1b194f7fead2"
SRCREV_recalboxbuildroot = "f648e4b54eb5e4be593746d6cc51375b22a7efbd"
SRCREV_miscfirmware = "487c7ee143ba6e8a25cf1883938ff91c9e5d6f19"

SRC_URI += "git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git;branch=${SRCBRANCH};destsuffix=${S}/git1;name=linuxfirmware \
git://github.com/recalbox/recalbox-buildroot.git;protocol=https;branch=${SRCBRANCH};destsuffix=${S}/git2;name=recalboxbuildroot "
LIC_FILES_CHKSUM += "file://git1/LICENCE.broadcom_bcm43xx;md5=3160c14df7228891b868060e1951dfbc \
                    file://git2/COPYING;md5=e4edbc78b8892db416b6a07e0d97309a "

do_install_append() {
    install -d ${D}${base_libdir}/firmware
    install -d ${D}${base_libdir}/firmware/brcm

    cp -rfv git1/brcm/brcmfmac43430-sdio.bin ${D}${base_libdir}/firmware/brcm
    cp -rfv git2/board/warp7/rootfs_overlay/lib/firmware/brcm/brcmfmac43430-sdio.txt ${D}${base_libdir}/firmware/brcm
}

FILES_${PN} += "${base_libdir}/firmware/brcm/brcmfmac43430*"

COMPATIBLE_MACHINE = "(imx7s-warp)"
