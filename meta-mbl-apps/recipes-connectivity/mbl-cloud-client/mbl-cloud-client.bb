# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

SUMMARY="Public mbed Cloud client for mbed Linux"
DESCRIPTION="Provides a mechanism to access ARM's mbed Cloud services from mbed Linux"
HOMEPAGE="https://github.com/ARMmbed/mbl-core/tree/master/cloud-services/mbl-cloud-client"

LICENSE="Apache-2.0"
LIC_FILES_CHKSUM = "file://${S}/LICENSE.Apache-2.0;md5=e3fc50a88d0a364313df4b21ef20c29e"
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

S = "${WORKDIR}/git"

# common sources for mbl-cloud-client(public) and mbl-cloud-client-internal
SRC_URI_COMMON = "file://yocto-toolchain.cmake \
  file://mbl-cloud-client.service \
  "

# specific sources for the mbl-cloud-client public version
SRC_URI_MBL_CLOUD_CLIENT_PUBLIC = "${SRC_URI_MBL_CORE_REPO} \
  file://arg_too_long_fix_1.patch;patchdir=${S} \
  file://arg_too_long_fix_2.patch;patchdir=${S}/cloud-services/mbl-cloud-client/mbed-cloud-client \
  file://linux-paths-update-client-pal-filesystem.patch;patchdir=${S}/cloud-services/mbl-cloud-client/mbed-cloud-client \
  file://check-min-pthread-stack-size.patch;patchdir=${S}/cloud-services/mbl-cloud-client/mbed-cloud-client \
  "

# all sources for the mbl-cloud-client public version
SRC_URI = "${SRC_URI_COMMON} ${SRC_URI_MBL_CLOUD_CLIENT_PUBLIC}"

SRCREV = "${SRCREV_MBL_CORE_REPO}"

DEPENDS = " glibc jsoncpp xz util-linux"

RDEPENDS_${PN} = "\
    libgcc \
    libstdc++ \
    mbl-dbus-cloud \
    ${PN}-update \
"

RDEPENDS_${PN}-update += "\
    e2fsprogs-mke2fs \
    swupdate \
    tar \
    util-linux-mkfs \
    util-linux-blkid \
    util-linux-lsblk \
    util-linux-mount \
    util-linux-umount \
    xz \
"

# Installed packages
PACKAGES = "${PN}-dbg ${PN} ${PN}-update"

FILES_${PN} += "\
    /opt/arm/mbl-cloud-client \
    /opt/arm/pelion-provisioning-util \
    ${sysconfdir}/logrotate.d/mbl-cloud-client-logrotate.conf \
"
FILES_${PN}-update = "\
    /opt/arm/arm_update_activate.sh \
    /opt/arm/arm_update_active_details.sh \
    /opt/arm/arm_update_cmdline.sh \
    /opt/arm/arm_update_common.sh \
    /opt/arm/arm_update_local_config.sh \
    /opt/arm/bootloader_installer.sh \
    /opt/arm/boot_partition_installer.sh \
    /opt/arm/apps_installer.sh \
    /opt/arm/rootfs_installer.sh \
    ${libdir}/lua/5.3/swupdate_handlers.lua \
"

FILES_${PN}-dbg += "/opt/arm/.debug \
                    /usr/src/debug/mbl-cloud-client"

# !!!
# Note: currently, we use x86_x64 PC Linux PAL platform implementation that is intented
# for test purposes. That means, that we have test-quality code with possible defects
# and other non-production code issues.
TARGET = "x86_x64_NativeLinux_mbedtls"

export SSH_AUTH_SOCK

# Allowed [Debug|Release]
RELEASE_TYPE="Debug"

inherit pythonnative
inherit cmake
inherit systemd

SYSTEMD_SERVICE_${PN} = "mbl-cloud-client.service"

do_setup_pal_env() {
    echo "Setup pal env"
    CUR_DIR=$(pwd)

    cd "${S}/cloud-services/mbl-cloud-client/"

    # Clean the old build directory
    rm -rf "__${TARGET}"
    mbed deploy --protocol git
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

MBL_PAL_BASE_CERT_DIR ?= "/config/user/pal"
MBL_PAL_UPDATE_FIRMWARE_DIR ?= "/scratch/firmware"
MBL_PROVISIONING_CERT_DIR ?= "/scratch/provisioning-certs"

EXTRA_OECMAKE = "\
    -DPAL_FS_MOUNT_POINT_PRIMARY=\"${MBL_PAL_BASE_CERT_DIR}\" \
    -DPAL_FS_MOUNT_POINT_SECONDARY=\"${MBL_PAL_BASE_CERT_DIR}\" \
    -DPAL_UPDATE_FIRMWARE_DIR=\"${MBL_PAL_UPDATE_FIRMWARE_DIR}\" \
    -DMBL_PROVISIONING_CERT_DIR=\"${MBL_PROVISIONING_CERT_DIR}\" \
"

do_configure() {
    CUR_DIR=$(pwd)
    cd "${S}/cloud-services/mbl-cloud-client/__${TARGET}"
    cp "${WORKDIR}/yocto-toolchain.cmake" "${S}/cloud-services/mbl-cloud-client/pal-platform/Toolchain/GCC"

    cmake -G "Unix Makefiles" \
           ${EXTRA_OECMAKE} \
          -DCMAKE_BUILD_TYPE="${RELEASE_TYPE}" \
          -DCMAKE_TOOLCHAIN_FILE="${S}/cloud-services/mbl-cloud-client/pal-platform/Toolchain/GCC/yocto-toolchain.cmake" \
          -DEXTARNAL_DEFINE_FILE="${S}/cloud-services/mbl-cloud-client/define.txt" \
          -DBOOTFLAGS_DIR="${MBL_BOOTFLAGS_DIR}" \
          -DUPDATE_PAYLOAD_DIR="${MBL_SCRATCH_DIR}" \
          -DLOG_DIR="${localstatedir}/log" \
          -DROOTFS1_LABEL="${MBL_ROOT_LABEL}1" \
          -DROOTFS2_LABEL="${MBL_ROOT_LABEL}2" \
          -DROOTFS_TYPE="${MBL_ROOT_FSTYPE}" \
          -DFACTORY_CONFIG_PARTITION="${MBL_FACTORY_CONFIG_DIR}"

    cd ${CUR_DIR}
}

do_compile() {
    CUR_DIR=$(pwd)
    cd "${S}/cloud-services/mbl-cloud-client/__${TARGET}"
    oe_runmake mbl-cloud-client
    oe_runmake pelion-provisioning-util
    cd ${CUR_DIR}
}

do_install() {
    install -d "${D}/opt/arm"
    output_dir="${S}/cloud-services/mbl-cloud-client/__${TARGET}"
    install -m 755 "${output_dir}/${RELEASE_TYPE}/mbl-cloud-client" "${D}/opt/arm"
    install -m 755 "${output_dir}/${RELEASE_TYPE}/pelion-provisioning-util" "${D}/opt/arm"

    install -m 755 "${output_dir}/mbl-cloud-client/scripts/arm_update_activate.sh" "${D}/opt/arm"
    install -m 755 "${output_dir}/mbl-cloud-client/scripts/arm_update_active_details.sh" "${D}/opt/arm"
    install -m 755 "${output_dir}/mbl-cloud-client/scripts/arm_update_common.sh" "${D}/opt/arm"

    install -m 755 "${output_dir}/mbl-cloud-client/scripts/rootfs_installer.sh" "${D}/opt/arm"
    install -m 755 "${output_dir}/mbl-cloud-client/scripts/bootloader_installer.sh" "${D}/opt/arm"
    install -m 755 "${output_dir}/mbl-cloud-client/scripts/apps_installer.sh" "${D}/opt/arm"
    install -m 755 "${output_dir}/mbl-cloud-client/scripts/boot_partition_installer.sh" "${D}/opt/arm"

    install -m 755 "${S}/cloud-services/mbl-cloud-client/mbed-cloud-client/update-client-hub/modules/pal-linux/scripts/arm_update_cmdline.sh" "${D}/opt/arm"

    install -d "${D}${libdir}/lua/5.3"
    install -m 755 "${output_dir}/mbl-cloud-client/scripts/swupdate_handlers.lua" "${D}${libdir}/lua/5.3/swupdate_handlers.lua"

    install -d "${D}${systemd_unitdir}/system/"
    install -m 0644 "${WORKDIR}/mbl-cloud-client.service" "${D}${systemd_unitdir}/system/"
}

# Add a logrotate config files
MBL_LOGROTATE_CONFIG_LOG_NAMES = "mbl-cloud-client arm_update_active_details arm_update_activate"

MBL_LOGROTATE_CONFIG_LOG_PATH[mbl-cloud-client] = "/var/log/mbl-cloud-client.log"
MBL_LOGROTATE_CONFIG_SIZE[mbl-cloud-client] ?= "1M"
MBL_LOGROTATE_CONFIG_ROTATE[mbl-cloud-client] ?= "4"
MBL_LOGROTATE_CONFIG_POSTROTATE[mbl-cloud-client] = "/usr/bin/killall -HUP mbl-cloud-client"

MBL_LOGROTATE_CONFIG_LOG_PATH[arm_update_active_details] = "/var/log/arm_update_active_details.log"
MBL_LOGROTATE_CONFIG_SIZE[arm_update_active_details] ?= "128k"
MBL_LOGROTATE_CONFIG_ROTATE[arm_update_active_details] ?= "4"

MBL_LOGROTATE_CONFIG_LOG_PATH[arm_update_activate] = "/var/log/arm_update_activate.log"
MBL_LOGROTATE_CONFIG_SIZE[arm_update_activate] ?= "128k"
MBL_LOGROTATE_CONFIG_ROTATE[arm_update_activate] ?= "4"

inherit mbl-logrotate-config
