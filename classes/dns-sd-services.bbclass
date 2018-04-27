# Copyright (c) 2018 ARM Ltd.
#
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0 (the License); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an AS IS BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Quick introduction
# ------------------
# dns_sd_services is a bbclass to aid in creating packages for advertising
# services via DNS-SD (Zeroconf).
#
# To use this class you should have:
# * A recipe that provides one or more services (e.g. SSH, SFTP).
# * XML service files that describe those services in a format suitable for
#   Avahi (see https://linux.die.net/man/5/avahi.service).
#
# In your recipe you will need to:
#
# * Set the DNS_SD_SERVICES variable to a whitespace delimited list of the
#   names of the services for which packages should be created.
#
# * For each <service-name> listed in DNS_SD_SERVICES, set
#   DNS_SD_SERVICE_SRC[<service-name>] to the path of XML file describing
#   the service.
#
# * For each <service-name> listed in DNS_SD_SERVICES, set
#   DNS_SD_SERVICE_RDEPENDS[<service-name>] to the list of packages required for
#   the service to run.
#
# * Inherit from dns-sd-services.
# 
# The dns_sd_services class will then:
#
# * Define a package "${PN}-<service-name>-dns-sd" for each service in
#   DNS_SD_SERVICES. This package will RDEPEND on avahi-daemon and any packages
#   listed in DNS_SD_SERVICE_RDEPENDS[<service-name>].
#
# * Install the XML description file for each service to the appropriate
#   location (/etc/avahi/services/<service-name>.service).
#
# The dns_sd_services class will NOT:
#
# * Make ${PN} RDEPEND on each DNS-SD service package. You will have to add
#   each DNS-SD service package to your image's package list if you want it to
#   be included in the image.
#
# Example
# -------
# To append the dropbear recipe to include a package for SSH service
# advertisement:
#
# * Create an XML file describing the SSH service and place it at
#   recipes-core/dropbear/dropbear/dropbear-ssh.service in your Bitbake layer.
#
# * Create a bbappend file in your layer at
#   recipes-core/dropbear/dropbear_%.bbappend with the following content.
# ------------------------------------------------------------------------------
# FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"
# SRC_URI += "file://dropbear-ssh.service"
# 
# DNS_SD_SERVICES = "ssh"
# DNS_SD_SERVICE_SRC[ssh] = "${WORKDIR}/dropbear-ssh.service"
# DNS_SD_SERVICE_RDEPENDS[ssh] = "dropbear"
# 
# inherit dns-sd-services
# ------------------------------------------------------------------------------
#
# This will define a package called dropbear-ssh-dns-sd that:
# * Contains the XML service description file.
# * RDEPENDS on avahi-daemon and dropbear.


# Code
# -----

DEPENDS += "avahi"

# This says that we're creating packages dynamically, so if any other package
# RDEPENDS on a package matching this expression, the parse-time dependency
# resolver should just trust that we'll satisfy the dependency at build time
# and not complain. The package system will still complain at do_rootfs time if
# we fail to satisfy any required dependencies at build time.
PACKAGES_DYNAMIC = "${PN}-.*-dns-sd"

# For each <service-name> in DNS_SD_SERVICES, we will add a line to
# DNS_SD_SERVICES_INSTALL_SRCS_AND_DSTS containing the source and destination
# of an "install" command that install's the service's file.
DNS_SD_SERVICES_INSTALL_SRCS_AND_DSTS = ""

python() {
    import shlex

    install_dir = '{}{}/avahi/services'.format(d.getVar('D'), d.getVar('sysconfdir'))

    for service in d.getVar('DNS_SD_SERVICES').split():
        src = d.getVarFlag('DNS_SD_SERVICE_SRC', service)
        if src is None:
            bb.fatal("DNS_SD_SERVICE_SRC[{}] is empty".format(service))

        # Save src and dst for an "install" command
        src_and_dst = "{} {}\n".format(
            shlex.quote(src),
            shlex.quote("{}/{}.service".format(install_dir, service)))

        d.appendVar('DNS_SD_SERVICES_INSTALL_SRCS_AND_DSTS', src_and_dst)

        # Add RDEPENDS for the service
        rdepends = d.getVarFlag('DNS_SD_SERVICE_RDEPENDS', service)
        if src is not None:
            d.appendVar(
                "RDEPENDS-{}-{}-dns-sd".format(d.getVar('PN'), service),
                d.getVarFlag('DNS_SD_SERVICE_RDEPENDS', service))
}

# Run the "install" commands whose sources and destinations were determined
# earlier
do_install_append() {
    printf "%s" "${DNS_SD_SERVICES_INSTALL_SRCS_AND_DSTS}" | while read src dst; do
         install -D -m 0644 "$src" "$dst"
    done
}

# Create a package for each file that has been installed in the services
# directory.
#
# Each package is called "${PN}-<service-name>-dns-sd" where <service-name> is
# obtained by stripping the ".service" suffix from the filename found in the
# services directory (i.e. a value from ${DNS_SD_SERVICES}).
python populate_packages_prepend() {
    pn = d.expand('${PN}')
    do_split_packages(d,
        d.expand('${sysconfdir}/avahi/services'),
        '^(.*)\.service$',
        '{}-%s-dns-sd'.format(pn),
        'DNS-SD advertisement for %s',
        extra_depends='avahi-daemon',
        prepend=True)
}
