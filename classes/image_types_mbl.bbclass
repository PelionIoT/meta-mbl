inherit image_types_fsl

_generate_boot_image_append() {
    if [ -f ${WORKDIR}/rootfs/lib/firmware/uTee.optee ]; then
        mcopy -i ${WORKDIR}/boot.img -s ${WORKDIR}/rootfs/lib/firmware/uTee.optee ::/uTee.optee
    fi
}
