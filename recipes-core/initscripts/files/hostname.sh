#!/bin/sh
### BEGIN INIT INFO
# Provides:          hostname
# Required-Start:
# Required-Stop:
# Default-Start:     S
# Default-Stop:
# Short-Description: Set hostname based on /etc/hostname
### END INIT INFO


if [[ -r /config/user/hostname && -s /config/user/hostname ]]; then
    /bin/hostname $(/bin/cat /config/user/hostname)
elif [[ -r /config/factory/hostname && -s /config/factory/hostname ]]; then
    /bin/hostname $(/bin/cat /config/factory/hostname)
else
    rand=$(shuf -i0-9999 -n1)
    echo "mbed_linux_${rand}" > /config/user/hostname
    /bin/hostname $(/bin/cat /config/user/hostname)
fi


