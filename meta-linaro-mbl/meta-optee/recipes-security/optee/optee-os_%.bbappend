# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

DEPENDS += " u-boot-tools-native "
DEPENDS_append_raspberrypi3-mbl = " arm-aarch64-toolchain-native "

LICENSE = "BSD-2-Clause"

# MBL_OPTEE_VERSION should be updated to match version pointed to by SRCREV
MBL_OPTEE_VERSION = "3.4.0"
MBL_OPTEE_VERSION_imx8mmevk-mbl = "3.2.0"

SRCREV="2976273f390e0654fb95928838ed0e251be8451f"
SRCREV_imx8mmevk-mbl = "230e2d697800dcb7070e924577c7a6069c866477"
SRC_URI="git://git.linaro.org/landing-teams/working/mbl/optee_os.git;protocol=https;nobranch=1 \
file://0001-allow-setting-sysroot-for-libgcc-lookup.patch \
"

LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=c1f21c4f72f372ef38a5a4aee55ec173"
LIC_FILES_CHKSUM_imx8mmevk-mbl = "file://${S}/LICENSE;md5=69663ab153298557a59c67a60a743e5b"
OPTEEMACHINE_imx7s-warp-mbl="imx-mx7swarp7_mbl"
OPTEEMACHINE_imx7d-pico-mbl="imx-mx7dpico_mbl"
OPTEEMACHINE_imx8mmevk-mbl = "imx-mx8mmevk_mbl"
OPTEEOUTPUTMACHINE_imx="imx"
OPTEEMACHINE_raspberrypi3-mbl="rpi3"
OPTEEOUTPUTMACHINE_raspberrypi3-mbl="rpi3"

OPTEE_ARCH = "arm32"

# CFG_DT
#    Enable device tree support.
#
# CFG_TEE_CORE_LOG_LEVEL
#   Configure Trusted Execution Environment core log level.
#     1 => only show ERROR logging.
#     4 => most verbose including xtest output.
#
# CROSS_COMPILE_ta_arm32
#   Configure the CROSS_COMPILE symbol for the AArch32 trusted applications.
#   This is the same for all targets.
#
# LDFLAGS
#   The linker flags are cleared in order to stop LDFLAGS breaking
#   compilation of TAs.
#
# LIBGCC_LOCATE_CFLAGS
#   This symbol is used to specify the logical root directory for headers and
#   libraries for the GNU linker. The directory is set to be the
#   STAGING_DIR_HOST i.e. ${WORKDIR}/recipe-sysroot. Support for this is added
#   by optee_os_git.bb patching the optee-os project gcc.mk makefile with
#   0001-allow-setting-sysroot-for-libgcc-lookup.patch.
#   See https://gcc.gnu.org/onlinedocs/gcc/Directory-Options.html for details
#   about --sysroot.
#
# NOWERROR
#   Do not treat warnings as errors.
#
# PLATFORM
#   A platform is a family of closely related hardware configurations.
#   See optee_os/documentation/build_system.md in the optee_os repo
#   for more information.
#
EXTRA_OEMAKE = " \
                CFG_DT=y \
                CFG_TEE_CORE_LOG_LEVEL=1 \
                LDFLAGS= \
                LIBGCC_LOCATE_CFLAGS=--sysroot=${STAGING_DIR_HOST} \
                NOWERROR=1 \
                PLATFORM=${OPTEEMACHINE} \
         "

# CROSS_COMPILE_core: Set the cross-compiler for OPTEE core.
# ta-targets: Set the ta-targets. On WaRP7 and PICO IMX7D it should be ta_arm32
# for 32-bit TA.
# CFG_PAGEABLE_ADDR: Set pageable address. Note that pageable is currently not
#                    using on WaRP7. So we set it to 0.
# CFG_TEE_CORE_NB_CORE: Set the CPU core number information.
# CFG_BOOT_SECONDARY_REQUEST: Enables OP-TEE to respond to SMP boot request
MX7_FLAGS = " \
                CROSS_COMPILE_ta_arm32=${HOST_PREFIX} \
                CFG_ARM32_core=y \
                CFG_PAGEABLE_ADDR=0 \
                CROSS_COMPILE_core=${HOST_PREFIX} \
                ta-targets=ta_arm32 \
	"

EXTRA_OEMAKE_append_imx7s-warp-mbl = " \
		${MX7_FLAGS}           \
                CFG_TEE_CORE_NB_CORE=1 \
        "

EXTRA_OEMAKE_append_imx7d-pico-mbl = " \
		${MX7_FLAGS}           \
                CFG_TEE_CORE_NB_CORE=2 \
		CFG_BOOT_SECONDARY_REQUEST=y \
        "

# CROSS_COMPILE_core: Set the cross-compiler for OPTEE core. On RPi3 it should
#                     be 64-bit because RPi3 boots with 64-bit. But for TA
#                     it supports 32-bit TA. Thus CROSS_COMPILE_ta_arm32
#                     still sets to ${HOST_PREFIX}
# CFG_ARM64_core: set OPTEE core to be in ARM64 rather than ARM32.
# CFG_DT_ADDR: The address of the device tree.
EXTRA_OEMAKE_append_raspberrypi3-mbl = " \
                CROSS_COMPILE_ta_arm32=${HOST_PREFIX} \
                CROSS_COMPILE_core=aarch64-linux-gnu- \
                CFG_DT_ADDR=0x03000000 \
                CFG_ARM64_core=y \
        "

# CFG_DT: Remove as the OPTEE from NXP does not operate upon a DTB right now
# CROSS_COMPILE: specify to the HOST_PREFIX as in both cases we use a 64bit
#                cross compiler and elsewise we default to
#                aarch64-linux-gnu-gcc
EXTRA_OEMAKE_remove_imx8mmevk-mbl = "CFG_DT=y"
EXTRA_OEMAKE_append_imx8mmevk-mbl = " \
		CROSS_COMPILE=${HOST_PREFIX} \
		CROSS_COMPILE64=${HOST_PREFIX} \
        "

do_compile_prepend_raspberrypi3-mbl() {
   export PATH=${STAGING_DIR_NATIVE}/${bindir}/aarch64-linux-gnu/bin:$PATH
}

# This is how we generate a TEE image for SPL loading
# when we convert over to ATF and the v2 OPTEE headers
# we will use the binaries produced by OPTEE directly
# and this piece of the build phase can be removed.
do_deploy_append_imx8mmevk-mbl () {
    ${TARGET_PREFIX}objcopy -O binary ${B}/out/arm-plat-${OPTEEOUTPUTMACHINE}/core/tee.elf ${DEPLOYDIR}/optee/tee.bin
}

# We don't want any part of optee-os ending up on the root file system. It
# would be nice to inherit from the noinstall class here, but the noinstall
# class removes the do_install task and, unconventionally, the optees-os
# recipe's do_deploy task uses files created by the do_install task.
#
# Additionally, the optee-test build uses things that optee-os leaves in
# /usr/include so we can't get rid of do_populate_sysroot either.
PACKAGES = ""
RPROVIDES = ""
inherit nopackages
