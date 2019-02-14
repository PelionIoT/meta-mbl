# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

DEPENDS += " u-boot-tools-native "
DEPENDS_append_raspberrypi3-mbl = " linaro-aarch64-toolchain-native "

SRCREV="644e5420ae01992e59c29f1417c9fd8445fab521"
SRCREV_imx7d-pico-mbl="89af39033471cb21ed4db18f491ffb77e30e2a68"
SRCREV_imx8mmevk-mbl = "6a52487eb0ff664e4ebbd48497f0d3322844d51d"
SRC_URI="git://git.linaro.org/landing-teams/working/mbl/optee_os.git;protocol=https;nobranch=1 \
file://0001-allow-setting-sysroot-for-libgcc-lookup.patch \
"

OPTEEMACHINE_imx7s-warp-mbl="imx-mx7swarp7_mbl"
OPTEEMACHINE_imx7d-pico-mbl="imx-mx7dpico_mbl"
OPTEEMACHINE_imx8mmevk-mbl="imx"
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
                CROSS_COMPILE_ta_arm32=${HOST_PREFIX} \
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
MX7_FLAGS = " \
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
        "

# CROSS_COMPILE_core: Set the cross-compiler for OPTEE core. On RPi3 it should
#                     be 64-bit because RPi3 boots with 64-bit. But for TA
#                     it supports 32-bit TA. Thus CROSS_COMPILE_ta_arm32
#                     still sets to ${HOST_PREFIX}
# CFG_ARM64_core: set OPTEE core to be in ARM64 rather than ARM32.
# CFG_DT_ADDR: The address of the device tree.
EXTRA_OEMAKE_append_raspberrypi3-mbl = " \
                CROSS_COMPILE_core=aarch64-linux-gnu- \
                CFG_DT_ADDR=0x03000000 \
                CFG_ARM64_core=y \
        "

do_compile_prepend_raspberrypi3-mbl() {
   export PATH=${STAGING_DIR_NATIVE}/${bindir}/aarch64-linux-gnu/bin:$PATH
}

EXTRA_OEMAKE_remove_imx8mmevk-mbl = "CFG_DT=y"
EXTRA_OEMAKE_append_imx8mmevk-mbl = " \
		CROSS_COMPILE=${HOST_PREFIX} \
		CROSS_COMPILE64=${HOST_PREFIX} \
	        PLATFORM_FLAVOR=mx8mmevk \
        "
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
