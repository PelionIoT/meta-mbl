# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# Add logrotate config file
MBL_LOGROTATE_CONFIG_LOG_NAMES = "syslog"
MBL_LOGROTATE_CONFIG_LOG_PATH[syslog] = "/var/log/messages"
MBL_LOGROTATE_CONFIG_SIZE[syslog] = "1M"
MBL_LOGROTATE_CONFIG_ROTATE[syslog] = "4"
MBL_LOGROTATE_CONFIG_NOARG_OPTS[syslog] = "missingok"
inherit mbl-logrotate-config

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# if_updown_ext_dhcp.cfg unsets CONFIG_FEATURE_IFUPDOWN_EXTERNAL_DHCP.
# This means busybox ifup/ifdown will ignore an external managers such as ConnMan.
SRC_URI += "file://if_updown_ext_dhcp.cfg \
    file://dd_ibs_obs.cfg \
    ${@bb.utils.contains('PACKAGECONFIG','minimal',' file://minimal.cfg','',d)} \
    "

PACKAGECONFIG[minimal] = ""
