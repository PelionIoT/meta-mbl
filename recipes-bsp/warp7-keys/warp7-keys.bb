SUMMARY = "i.MX7 Code Signing Tool - Keys"
DESCRIPTION = "Download and install NXP Code Signing Tool private key dependencies"
SECTION = "base"
LICENSE="Propriatery"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

inherit image_sign_mbl

SRC_URI = "git://git@github.com/ARMmbed/mbl-tools.git;protocol=ssh;nobranch=1;destsuffix=${S}/git1;name=warp7-keys"
SRCREV_warp7-keys = "d30c7f205b52c21852ca60388c7bda5b0f2edff7"

LONGPATH = "git1/warp7-tools/imx7-code-signing/warp7-keys"

do_install() {
	install -d ${UBOOT_SHARED_DATA}
	cp ${LONGPATH}/crts/*.bin ${UBOOT_SHARED_DATA}
	install -d ${D}${sysconfdir}/cst
	install -d ${D}${sysconfdir}/cst/warp7/crts
	install -d ${D}${sysconfdir}/cst/warp7/keys
	install -m 0755 ${LONGPATH}/crts/* ${D}${sysconfdir}/cst/warp7/crts
	install -m 0755 ${LONGPATH}/keys/* ${D}${sysconfdir}/cst/warp7/keys
}

BBCLASSEXTEND = "native nativesdk"
