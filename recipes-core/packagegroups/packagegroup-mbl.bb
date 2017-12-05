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
#      - optee-os. If the machine supports optee include the os.
#      - optee-client. If the machine supports optee include the client.
###############################################################################
RDEPENDS_packagegroup-mbl = "\
    docker \
    iptables \
    kernel-modules \
    rng-tools \
    ${@bb.utils.contains_any("MACHINE", "imx7s-warp imx7s-warp-mbl", "optee-os ", "", d)} \
    ${@bb.utils.contains_any("MACHINE", "imx7s-warp imx7s-warp-mbl", "optee-client ", "", d)} \
    "
