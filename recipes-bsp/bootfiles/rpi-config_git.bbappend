SRC_URI = "git://github.com/omnium21/RPi-config.git;protocol=https;branch=master"

do_deploy_append() {
    echo "enable_uart=1" >> ${DEPLOYDIR}/bcm2835-bootfiles/config.txt
}
