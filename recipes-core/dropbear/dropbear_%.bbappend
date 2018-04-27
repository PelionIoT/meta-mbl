FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"
SRC_URI += "file://dropbear-ssh.service"

DNS_SD_SERVICES = "ssh"
DNS_SD_SERVICE_SRC[ssh] = "${WORKDIR}/dropbear-ssh.service"
DNS_SD_SERVICE_RDEPENDS[ssh] = "dropbear"

inherit dns-sd-services
