DEPENDS += " atf-fiptool-native"

do_fip_generate() {
}

do_fip_generate_imx7s-warp-mbl() {
    # Generate the FIP image
    atf-fiptool create \
        --tos-fw ${DEPLOY_DIR_IMAGE}/optee/tee-header_v2.bin \
        --tos-fw-extra1 ${DEPLOY_DIR_IMAGE}/optee/tee-pager_v2.bin \
        --tos-fw-extra2 ${DEPLOY_DIR_IMAGE}/optee/tee-pageable_v2.bin \
        --nt-fw ${DEPLOY_DIR_IMAGE}/u-boot.bin \
        --hw-config ${DEPLOY_DIR_IMAGE}/imx7s-warp.dtb \
        ${DEPLOY_DIR_IMAGE}/warp7.fip

    # Unify FIP and ATF into one binary
    FIP_SIZE=$(stat -c %s ${DEPLOY_DIR_IMAGE}/warp7.fip)
    dd if=/dev/zero of=${DEPLOY_DIR_IMAGE}/atf-bl2-fip.bin count=$(expr 32 \* 1024 \+ ${FIP_SIZE}) bs=1
    dd if=${DEPLOY_DIR_IMAGE}/bl2.bin.imx of=${DEPLOY_DIR_IMAGE}/atf-bl2-fip.bin
    # the packed image is burned to 1KB offset, so 1MB is shift to 1023KB in image
    dd if=${DEPLOY_DIR_IMAGE}/warp7.fip of=${DEPLOY_DIR_IMAGE}/atf-bl2-fip.bin bs=1024 seek=1023
}

addtask do_fip_generate after do_image_ext4 before do_image_wic
