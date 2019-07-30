# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS_append := "${THISDIR}/files:"

SRC_URI_append = " file://fstab "

# override hostname in build time. hostname will be set by hostname.sh init script
hostname_pn-base-files = ""

python __anonymous() {
    # MBL_PARTITION_INFOS is set in mbl-partitions.bbclass. It's a list of
    # dictionaries, each one providing information about a partition.
    parts = d.getVar("MBL_PARTITION_INFOS")
    if not isinstance(parts, list):
        bb.fatal("Failed to read partition info from MBL_PARTITION_INFOS")

    for part in parts:
        if part["skip"] or not part["is_fs"] or part["mount_point"] == "/":
            continue

        # Create a list of mount points that need to be created. We'll use this
        # in do_install
        d.appendVar("MOUNT_POINTS", " {}".format(part["mount_point"]))

        # Create a list of lines to add to fstab. We'll add the lines in
        # do_install
        bank_str = ""
        if part["is_banked"]:
            bank_str = "1"

        fstab_line = "LABEL={}{} {} {} {} {} {}\n".format(
            part["label"],
            bank_str,
            part["mount_point"],
            part["fstype"],
            part["mount_opts"],
            part["fs_freq"],
            part["fs_passno"]
        )
        d.appendVar("FSTAB_LINES", fstab_line)
}

do_install_append() {
    # Ensure that mountpoints specified in fstab exist on the root filesystem
    # MOUNT_POINTS is set in the python __anonymous() block above
    for mountpoint in ${MOUNT_POINTS}; do
        install -d "${D}${mountpoint}"
    done

    # Add a line to fstab for each partition. FSTAB_LINES is set in the python
    # __anonymous() block above.
    while read fstab_line; do
        printf "%s\n" "$fstab_line" >> ${D}${sysconfdir}/fstab
    done <<EOF
${FSTAB_LINES}
EOF
    cat ${D}${sysconfdir}/fstab
}
