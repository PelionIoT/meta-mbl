do_deploy_append() {
    echo "enable_uart=1" >> ${DEPLOYDIR}/bcm2835-bootfiles/config.txt
    echo "kernel_address=0x01000000" >> ${DEPLOYDIR}/bcm2835-bootfiles/config.txt
    echo "device_tree_address=0x03000000" >> ${DEPLOYDIR}/bcm2835-bootfiles/config.txt
}

DEPENDS += "atf-rpi3"
