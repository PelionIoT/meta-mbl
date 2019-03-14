#!/bin/sh
# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

FW=firmware-qca-2.0.3
FWBIN=$FW.bin

if [ ! -f $FWBIN ]; then
	wget https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/$FWBIN
	rm -rf $FW
fi

if [ ! -f $FW ]; then
	chmod +x $FWBIN
	./$FWBIN
fi

cp -v -r ./$FW/1PJ_QCA9377-3_LEA_2.0/* /
