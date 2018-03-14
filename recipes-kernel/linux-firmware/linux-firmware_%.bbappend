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

FILESEXTRAPATHS_prepend_imx7s-warp-mbl := "${THISDIR}/../../../meta-raspberrypi/recipes-kernel/linux-firmware/files:"

SRC_URI_append_imx7s-warp-mbl = " \
	file://brcmfmac43430-sdio.bin \
	file://brcmfmac43430-sdio.txt \
	"

do_install_append_imx7s-warp-mbl() {
	# Overwrite v7.45.41.26 by the one we currently provide in this layer
	# (v7.45.41.46)
	local _firmware="brcmfmac43430-sdio.bin"
	local _oldmd5=9258986488eca9fe5343b0d6fe040f8e
	if [ "$(md5sum ${D}${nonarch_base_libdir}/firmware/brcm/$_firmware | awk '{print $1}')" != "$_oldmd5" ]; then
		_firmware=""
		bbwarn "linux-firmware stopped providing brcmfmac43430 v7.45.41.26."
	else
		_firmware="${WORKDIR}/$_firmware"
	fi

	mkdir -p ${D}/${nonarch_base_libdir}/firmware/brcm
	install -m 0644 $_firmware ${WORKDIR}/brcmfmac43430-sdio.txt ${D}${nonarch_base_libdir}/firmware/brcm
}

FILES_${PN}-bcm43430_imx7s-warp-mbl += " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.bin \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.txt \
"
