do_deploy_append() {
    echo "enable_uart=1" >> ${DEPLOYDIR}/bcm2835-bootfiles/config.txt
}
