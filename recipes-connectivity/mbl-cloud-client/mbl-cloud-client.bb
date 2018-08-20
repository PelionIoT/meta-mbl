SUMMARY="Public mbed Cloud client for mbed Linux"
DESCRIPTION="Provides a mechanism to access ARM's mbed Cloud services from mbed Linux"
HOMEPAGE="https://github.com/ARMmbed/mbl-core/tree/master/cloud-services/mbl-cloud-client"

LICENSE="Apache-2.0"
LIC_FILES_CHKSUM = "file://${S}/cloud-services/mbl-cloud-client/mbed-cloud-client/LICENSE;md5=4336ad26bb93846e47581adc44c4514d"
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

S = "${WORKDIR}/git"

SRC_URI = "git://git@github.com/ARMmbed/mbl-core.git;nobranch=1;protocol=ssh; \
  file://yocto-toolchain.cmake \
  file://arg_too_long_fix_1.patch;patchdir=${S} \
  file://arg_too_long_fix_2.patch;patchdir=${S}/cloud-services/mbl-cloud-client/mbed-cloud-client \
  file://sotp-include-patch.patch;patchdir=${S}/cloud-services/mbl-cloud-client/mbed-cloud-client \
  file://linux-paths-update-client-pal-filesystem.patch;patchdir=${S}/cloud-services/mbl-cloud-client/mbed-cloud-client \
  file://arm_update_local_config.sh \
  file://init \
  file://logrotate.conf \
  "

SRCREV = "0b29b87a6e248bdf42aa728c08871506964bfa51"

DEPENDS = " glibc"

RDEPENDS_${PN} = "\
    e2fsprogs-mke2fs \
    libgcc \
    libstdc++ \
    logrotate \
    start-stop-daemon \
"

# Installed packages
PACKAGES = "${PN}-dbg ${PN}"

FILES_${PN} += "\
    /opt \
    /opt/arm \
    /opt/arm/mbl-cloud-client \
    /opt/arm/arm_update_activate.sh \
    /opt/arm/arm_update_active_details.sh \
    /opt/arm/arm_update_cmdline.sh \
    /opt/arm/arm_update_common.sh \
    /opt/arm/arm_update_local_config.sh \
    ${sysconfdir}/logrotate.d/mbl-cloud-client-logrotate.conf \
"

FILES_${PN}-dbg += "/opt/arm/.debug \
                    /usr/src/debug/mbl-cloud-client"

# !!!
# Note: currently, we use x86_x64 PC Linux PAL platform implementation that is intented 
# for test purposes. That means, that we have test-quality code with possible defects
# and other non-production code issues.
TARGET = "x86_x64_NativeLinux_mbedtls"

export SSH_AUTH_SOCK
export MBED_CLOUD_IDENTITY_CERT_FILE
export MBED_UPDATE_RESOURCE_FILE

# Allowed [Debug|Release]
RELEASE_TYPE="Debug"

MBL_MAX_LOG_SIZE ?= "2M"
MBL_MAX_LOGS ?= "5"

inherit pythonnative
inherit cmake

inherit update-rc.d
INITSCRIPT_NAME = "mbl-cloud-client"
INITSCRIPT_PARAMS = "defaults 90 10"

do_setup_pal_env() {
    echo "Setup pal env"
    CUR_DIR=$(pwd)

    cd "${S}/cloud-services/mbl-cloud-client/"

    # Clean the old build directory
    rm -rf "__${TARGET}"
    mbed deploy --protocol ssh
    python ./pal-platform/pal-platform.py -v deploy --target="${TARGET}" generate
    cd ${CUR_DIR}
}

addtask setup_pal_env after do_unpack before do_patch
do_setup_pal_env[depends] += "mbed-cli-native:do_populate_sysroot"
do_setup_pal_env[depends] += "python-click-native:do_populate_sysroot"
do_setup_pal_env[depends] += "python-requests-native:do_populate_sysroot"
do_setup_pal_env[depends] += "python-urllib3-native:do_populate_sysroot"
do_setup_pal_env[depends] += "python-chardet-native:do_populate_sysroot"
do_setup_pal_env[depends] += "python-certifi-native:do_populate_sysroot"
do_setup_pal_env[depends] += "python-idna-native:do_populate_sysroot"

do_configure() {
    CUR_DIR=$(pwd)
    cd "${S}/cloud-services/mbl-cloud-client/__${TARGET}"

    if [ -z "${MBED_CLOUD_IDENTITY_CERT_FILE}" ]; then
        MBED_CLOUD_IDENTITY_CERT_FILE=${TOPDIR}/mbed_cloud_dev_credentials.c
    fi

    if [ -z "${MBED_UPDATE_RESOURCE_FILE}" ]; then
        MBED_UPDATE_RESOURCE_FILE=${TOPDIR}/update_default_resources.c
    fi

    if [ -e "${MBED_CLOUD_IDENTITY_CERT_FILE}" ]; then
        cp ${MBED_CLOUD_IDENTITY_CERT_FILE} "${S}/cloud-services/mbl-cloud-client/mbed_cloud_dev_credentials.c"
    else
        echo "ERROR mbed cloud credentials file not found!!!"
        exit 1
    fi

    if [ -e "${MBED_UPDATE_RESOURCE_FILE}" ]; then
        cp ${MBED_UPDATE_RESOURCE_FILE} "${S}/cloud-services/mbl-cloud-client/update_default_resources.c"
    else
        echo "ERROR mbed update resource file not found!!!"
        exit 1
    fi
    
    cp "${WORKDIR}/yocto-toolchain.cmake" "${S}/cloud-services/mbl-cloud-client/pal-platform/Toolchain/GCC"

    cmake -G "Unix Makefiles" \
          -DCMAKE_BUILD_TYPE="${RELEASE_TYPE}" \
          -DCMAKE_TOOLCHAIN_FILE="${S}/cloud-services/mbl-cloud-client/pal-platform/Toolchain/GCC/yocto-toolchain.cmake" \
          -DEXTARNAL_DEFINE_FILE="${S}/cloud-services/mbl-cloud-client/define.txt"

    cd ${CUR_DIR}
}

do_compile() {
    CUR_DIR=$(pwd)
    cd "${S}/cloud-services/mbl-cloud-client/__${TARGET}"
    oe_runmake mbl-cloud-client
    cd ${CUR_DIR}
}

# The size and number of mbl-cloud-client log files is configurable via bitbake
# variables. This function substitutes placeholders in the config file with
# values from the variables.
fixup_logrotate_conf() {
conf_file="$1"

    if ! expr match "${MBL_MAX_LOGS}" '^ *[0-9][0-9]* *$' > /dev/null; then
        echo "ERROR: MBL_MAX_LOGS value (\"${MBL_MAX_LOGS}\") is invalid"
        exit 1
    fi
    sed -i -e "s/__REPLACE_ME_WITH_MBL_MAX_LOGS__/${MBL_MAX_LOGS}/" "$conf_file"

    if ! expr match "${MBL_MAX_LOG_SIZE}" '^ *[0-9][0-9]*[kMG] *$' > /dev/null; then
        echo "ERROR: MBL_MAX_LOG_SIZE value (\"${MBL_MAX_LOG_SIZE}\") is invalid"
        exit 1
    fi
    sed -i -e "s/__REPLACE_ME_WITH_MBL_MAX_LOG_SIZE__/${MBL_MAX_LOG_SIZE}/" "$conf_file"
}

do_install() {
    install -d "${D}/opt/arm"
    install "${S}/cloud-services/mbl-cloud-client/__${TARGET}/${RELEASE_TYPE}/mbl-cloud-client" "${D}/opt/arm"

    install -m 755 "${S}/cloud-services/mbl-cloud-client/scripts/arm_update_activate.sh" "${D}/opt/arm"
    install -m 755 "${S}/cloud-services/mbl-cloud-client/scripts/arm_update_active_details.sh" "${D}/opt/arm"
    install -m 755 "${S}/cloud-services/mbl-cloud-client/scripts/arm_update_common.sh" "${D}/opt/arm"
    install -m 755 "${S}/cloud-services/mbl-cloud-client/mbed-cloud-client/update-client-hub/modules/pal-linux/scripts/arm_update_cmdline.sh" "${D}/opt/arm"
    install -m 755 "${WORKDIR}/arm_update_local_config.sh" "${D}/opt/arm"

    install -d "${D}${sysconfdir}/init.d"
    install -m 755 "${WORKDIR}/init" "${D}${sysconfdir}/init.d/mbl-cloud-client"

    logrotate_conf_file="${D}${sysconfdir}/logrotate.d/mbl-cloud-client-logrotate.conf"
    install -d "${D}${sysconfdir}/logrotate.d"
    install -m 644 "${WORKDIR}/logrotate.conf" "$logrotate_conf_file"
    fixup_logrotate_conf "$logrotate_conf_file"
}
