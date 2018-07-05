DESCRIPTION = "ARM Trusted Firmware Warp7"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://license.rst;md5=e927e02bca647e14efd87e9e914b2443"

DEPENDS += " coreutils-native optee-os u-boot "

SRC_URI = "git://git@git.linaro.org/landing-teams/working/mbl/arm-trusted-firmware.git;protocol=https;branch=master+imx7"
SRCREV = "5eb0ce4a751764f23efed89f2d4cb73e8dd4478e"
SRC_URI += "https://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/arm-linux-gnueabihf/gcc-linaro-7.3.1-2018.05-x86_64_arm-linux-gnueabihf.tar.xz;name=tc32 "
SRC_URI[tc32.md5sum] = "e414dc2bbd2bbd2f3b10edad0792fdb3"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"
COMPATIBLE_MACHINE = "(mx7|vf|use-mainline-bsp)"

PLATFORM_imx7s-warp = "warp7"

LDFLAGS[unexport] = "1"

do_compile() {
   export PATH=${WORKDIR}/gcc-linaro-7.3.1-2018.05-x86_64_arm-linux-gnueabihf/bin:$PATH
   oe_runmake -C ${S} BUILD_BASE=${B} \
      BUILD_PLAT=${B}/${PLATFORM}/ \
      PLAT=${PLATFORM} \
      ARCH=aarch32 \
      ARM_ARCH_MAJOR=7 \
      CROSS_COMPILE=arm-linux-gnueabihf- \
      LOG_LEVEL=50 V=1 \
      AARCH32_SP=optee \
      fiptool \
      all

#mkdir -p ${WORKDIR}/fiptool_images
pwd > /tmp/curpath
   cp ${B}/${PLATFORM}/bl2.bin \
      ${DEPLOY_DIR_IMAGE}/u-boot.bin \
      ${DEPLOY_DIR_IMAGE}/imx7s-warp.dtb \
      ${DEPLOY_DIR_IMAGE}/optee/tee-header_v2.bin \
      ${DEPLOY_DIR_IMAGE}/optee/tee-pageable_v2.bin \
      ${DEPLOY_DIR_IMAGE}/optee/tee-pager_v2.bin \
      ${B}/

   ${S}/tools/fiptool/fiptool create \
      --tos-fw tee-header_v2.bin \
      --tos-fw-extra1 tee-pager_v2.bin \
      --tos-fw-extra2 tee-pageable_v2.bin \
      --nt-fw u-boot.bin \
      --hw-config imx7s-warp.dtb \
      warp7.fip
}

do_install() {
	FIP_SIZE=$(stat -c %s ${B}/warp7.fip)
	dd if=/dev/zero of=${B}/atf-bl2-fip.bin count=$(expr 32 \* 1024 \+ ${FIP_SIZE}) bs=1
	dd if=${B}/${PLATFORM}/bl2.bin of=${B}/atf-bl2-fip.bin
	# the packed image is burned to 1KB offset, so 1MB is shift to 1023KB in image
	dd if=${B}/warp7.fip of=${B}/atf-bl2-fip.bin bs=1024 seek=1023
	install -D -p -m 0644 ${B}/${PLATFORM}/bl2.bin ${DEPLOY_DIR_IMAGE}/bl2.bin
	install -D -p -m 0644 ${B}/warp7.fip ${DEPLOY_DIR_IMAGE}/warp7.fip
	install -D -p -m 0644 ${B}/atf-bl2-fip.bin ${DEPLOY_DIR_IMAGE}/
}
