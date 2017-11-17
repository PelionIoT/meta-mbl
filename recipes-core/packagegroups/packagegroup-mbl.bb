SUMMARY = "mbed linux additional packages"
DESCRIPTION = "mbed linux additional packages to those of the minimal console default setup."

inherit packagegroup

###############################################################################
# RDEPENDS_packagegroup-mbl
#    The list of runtime depends packages includes:
#      - docker. Containerised environment for secure application execution.
#      - iptables. Required by docker for building iptables DOCKER-ISOLATION 
#        and DOCKER chains for the FORWARD table.
#      - kernel-modules. Required by iptables related modules (e.g. netfilter
#        connection tracking. 
###############################################################################
RDEPENDS_packagegroup-mbl = "\
    docker \
    iptables \
    kernel-modules \
    ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'optee-os', '', d)} \
    "
