# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT
FILESEXTRAPATHS_append := "${THISDIR}/files:"

SRC_URI_append = " file://fstab "
# override hostname in build time. hostname will be set by hostname.sh init script
hostname_pn-base-files = ""

# This is where write_partition_info temporarily stores the partition variable
# files. The files are installed into the factory config partition in do_install.
MBL_PART_INFO_TMP_DIR = "${WORKDIR}/part-info-tmp"

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

# Save the values of all the variables created by mbl-partitions.bbclass.
# Each value will be in its own file with the variable name as the
# file name. These files will end up in /config/factory on the target.
python do_write_partition_vars() {
    import pathlib

    # Create a temporary directory to hold the partition var files.
    # They will be picked up from the temporary dir in do_install.
    part_files_tmp = pathlib.Path(d.getVar("MBL_PART_INFO_TMP_DIR"))
    part_files_tmp.mkdir(parents=True, exist_ok=True)

    # MBL_PARTITION_VARS is a list of the variable names set in mbl-partitions.
    part_vars = d.getVar("MBL_PARTITION_VARS", True)
    if not part_vars:
        bb.fatal("Could not read MBL_PARTITION_VARS.")

    for var in part_vars.split():
        var_value = d.getVar(var, True)
        file_path = pathlib.Path(part_files_tmp, var)
        file_path.write_text(var_value)
}

addtask write_partition_vars before do_install after do_compile
do_write_partition_vars[vardeps] += "MBL_PARTITION_VARS ${MBL_PARTITION_VARS}"

do_install_append() {
    # Ensure that mountpoints specified in fstab exist on the root filesystem
    # MOUNT_POINTS is set in the python __anonymous() block above
    for mountpoint in ${MOUNT_POINTS}; do
        install -d "${D}${mountpoint}"
    done

    # This is where update scripts put flag files. Create it here so that the
    # update scripts don't have to know how to create it (i.e. whether to use
    # just a "mkdir" or whether a partition needs mounting).
    install -d "${D}${MBL_BOOTFLAGS_DIR}"

    # Add a line to fstab for each partition. FSTAB_LINES is set in the python
    # __anonymous() block above.
    while read fstab_line; do
        printf "%s\n" "$fstab_line" >> ${D}${sysconfdir}/fstab
    done <<EOF
${FSTAB_LINES}
EOF
    cat ${D}${sysconfdir}/fstab

    # This directory is where the values of mbl-partitions variables are stored
    # as files on the factory config partition.
    install -d "${D}${MBL_PART_INFO_DIR}"

    # Install the partition variable files with correct permissions.
    for fpath in "${MBL_PART_INFO_TMP_DIR}"/*; do
        install -m 0444 "${fpath}" "${D}${MBL_PART_INFO_DIR}"
    done
}
