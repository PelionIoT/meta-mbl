# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

# This class adds a task to merge kernel config fragments into the main kernel config.
# Recipes which add kernel config fragments should inherit this class.

do_merge_kconfig() {
	cfgs=`find ${WORKDIR}/ -maxdepth 1 -name '*.cfg' | wc -l`;
	if [ ${cfgs} -gt 0 ]; then
		${S}/scripts/kconfig/merge_config.sh -m -O ${B} ${B}/.config ${WORKDIR}/*.cfg
	fi
}

addtask merge_kconfig before do_configure after do_preconfigure
