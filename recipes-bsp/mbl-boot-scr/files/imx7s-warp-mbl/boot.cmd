setenv root /dev/mmcblk1p3
setenv mmcextpart 3
ext4size mmc 0:2 rootfs2 && setenv root /dev/mmcblk1p5 && setenv mmcextpart 5
setenv mmcargs setenv bootargs console=${console},${baudrate} root=${root} rootwait rw
run loadimage && run mmcbootsec
