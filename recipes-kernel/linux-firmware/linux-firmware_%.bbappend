# SPDX-License-Identifier: MIT
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

SRC_URI_append_bcm43430a1 = " \
	git://github.com/murata-wireless/cyw-fmac-fw.git;protocol=https;branch=master;name=fw;destsuffix=git/fw \
	git://github.com/murata-wireless/cyw-fmac-nvram.git;protocol=https;branch=master;name=nvram;destsuffix=git/nvram \
	git://github.com/armbian/firmware.git;protocol=https;branch=master;name=ap6212;destsuffix=git/ap6212 \
	"
SRCREV_FORMAT = "linuxfw_fw_nvram"

SRCREV_linuxfw = "4c0bf113a55975d702673e57c5542f150807ad66"
SRCREV_fw = "2242fd3f67a913fbfff8678cc8f7761629dca8ca"
SRCREV_nvram = "ae2c8b2bd93f9a51cca984dbc7dd0659b0babe92"
SRCREV_ap6212 = "d48638ae83026979d617f80c054f8f239d8945dd"

S = "${WORKDIR}/git"

LIC_FILES_CHKSUM_append_bcm43430a1 = " \
    file://LICENCE.cypress;md5=cbc5f665d04f741f1e006d2096236ba7 \
"
do_install_prepend_bananapi-zero() {
	cp ${S}/ap6212/ap6212/nvram.txt ${S}/nvram/brcmfmac43430-sdio.txt
}

do_install_append_bcm43430a1() {
	mkdir -p ${D}/${nonarch_base_libdir}/firmware/brcm
	install -m 0644 ${S}/fw/LICENCE.cypress ${D}${nonarch_base_libdir}/firmware
	install -m 0644 ${S}/fw/brcmfmac43430-sdio.bin ${S}/nvram/brcmfmac43430-sdio.txt ${D}${nonarch_base_libdir}/firmware/brcm
}

FILES_${PN}-bcm43430_bcm43430a1 += " \
	${nonarch_base_libdir}/firmware/LICENCE.cypress \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.bin \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.txt \
"
