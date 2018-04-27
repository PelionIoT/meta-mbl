
# By default avahi will install config files to advertise ssh and ssh-sftp
# services, even if there is no SSH service to advertise. Remove these files
# and let packages that actually provide services add service files if
# required.
do_install_append() {
    rm ${D}${sysconfdir}/avahi/services/*
}
