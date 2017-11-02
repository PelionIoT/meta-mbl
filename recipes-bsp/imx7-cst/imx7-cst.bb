SUMMARY = "i.MX7 Code Signing Tool"
DESCRIPTION = "Download and install NXP Code Signing Tool as Yocto SDK dependency"
SECTION = "base"
LICENSE="Propriatery"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

#https://github.com/ARMmbed/mbl-tools/blob/linaro-warp7/warp7-tools/imx7-code-signing/nxp-cst/cst-2.3.2.tar.gz
SRCBRANCH = "linaro-warp7"
SRC_URI = "git://git@github.com/ARMmbed/mbl-tools.git;protocol=ssh;branch=${SRCBRANCH};destsuffix=${S}/git1;name=cst"
SRCREV_cst = "9bd83db13362e656be6c98c409ec29e5595595a7"

do_compile() {
	tar zxvf git1/warp7-tools/imx7-code-signing/nxp-cst/cst-2.3.2.tar.gz
}

do_install() {
	install -d ${D}${bindir}
	if [ x${BUILD_ARCH} = xx86_64 ]; then
	   install -m 0755 cst-2.3.2/linux64/cst ${D}${bindir}/cst
	   install -m 0755 cst-2.3.2/linux64/srktool ${D}${bindir}/srktool
	   install -m 0755 cst-2.3.2/linux64/x5092wtls ${D}${bindir}/x5092wtls
	elif [ x${BUILD_ARCH} = xi386 ]; then
	   install -m 0755 cst-2.3.2/linux32/cst ${D}${bindir}/cst
	   install -m 0755 cst-2.3.2/linux32/srktool ${D}${bindir}/srktool
	   install -m 0755 cst-2.3.2/linux32/x5092wtls ${D}${bindir}/x5092wtls
	fi
}

#COMPATIBLE_MACHINE = "(imx7s-warp)"
BBCLASSEXTEND = "native nativesdk"
