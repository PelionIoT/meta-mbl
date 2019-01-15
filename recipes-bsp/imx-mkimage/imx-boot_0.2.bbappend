
compile_mx8m_prepend() {
    # Fixup the name expected by the incoming imx-boot recipe
    ln -sf ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/u-boot-nodtb.bin-${MACHINE}-${UBOOT_CONFIG} ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/u-boot-nodtb.bin 
}
