do_deploy_append() {
    echo "enable_uart=1" >> ${DEPLOYDIR}/bcm2835-bootfiles/config.txt

    # The default kernel_address is 0x00008000. And upstream's u-boot address
    # is also 0x00008000 due to this. But for TF-A, BL33 is being loaded at
    # 0x11000000. Thus we need to change the u-boot address.
    # Since we are not using TF-A currently and we are still using VideoCore4
    # bootloader to boot into U-boot for us. After we change the entry address
    # of U-boot we also need to ask VideoCore4 bootloader to load u-boot in
    # 0x11000000.
    # This variable in config.txt can be removed when we switch to TF-A
    # because we won't need VideoCore4 bootloader to load anything for us
    # except the TF-A.
    echo "kernel_address=0x11000000" >> ${DEPLOYDIR}/bcm2835-bootfiles/config.txt
}
