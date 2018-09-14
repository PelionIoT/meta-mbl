# Add logrotate config file
MBL_LOGROTATE_CONFIG_LOG_NAMES = "syslog"
MBL_LOGROTATE_CONFIG_LOG_PATH[syslog] = "/var/log/messages"
MBL_LOGROTATE_CONFIG_SIZE[syslog] = "1M"
MBL_LOGROTATE_CONFIG_ROTATE[syslog] = "4"
inherit mbl-logrotate-config
