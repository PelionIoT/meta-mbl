# make sure the local appending config file will be chosen by prepending and extra local path
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI +=  " file://0001-disable-auto-completion.patch \
            "

# disable auto complete
EXTRA_OEMAKE += "CFLAGS='-DDISABLE_AUTO_COMPLETE'"
