# bluez5 5.49 has a bug where it doesn't compile when configured with
# --disable-client (which we want to avoid a dependency on readline which is
# GPLv3).
#
# The bug is fixed in bluez5 5.50 but until we get that version, patch in the
# commit from 5.50 that fixed it.

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://0001-build-Make-bt_shell-conditional-to-readline.patch"
