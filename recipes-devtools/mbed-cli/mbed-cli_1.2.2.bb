LICENSE="Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4336ad26bb93846e47581adc44c4514d"


FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " file://mbed-wrapper "

SRC_URI[md5sum] = "2f708ca555151133afb8bf7267be6df6"

PYPI_PACKAGE = "mbed-cli"
PYPI_PACKAGE_EXT = "zip"

inherit setuptools pypi

# Replace the mbed script with our wrapper script that can deal with the mbed
# script having a shebang line longer than the kernel can cope with
do_install_append() {
    nonwrapped_path="${bindir}/mbed"
    wrapped_path="${bindir}/wrapped_mbed"
    mv "${D}${nonwrapped_path}" "${D}${wrapped_path}"
    install "${WORKDIR}/mbed-wrapper" "${D}${nonwrapped_path}"

    # Tell the wrapper script what the path to the wrapped script is by
    # replacing some placeholder text in the wrapper script.  Note that
    # $wrapped_path is being used here without a preceding $D. This is because
    # the build system itself will insert a placeholder "FIXMESTAGINGDIRHOST"
    # into $wrapped_path that will be substituted later to make the script's
    # final resting place.
    sed -i -e "s|__REPLACE_ME_WITH_WRAPPED_MBED_PATH__|${wrapped_path}|g" "${D}${nonwrapped_path}"
}

BBCLASSEXTEND = "native"
