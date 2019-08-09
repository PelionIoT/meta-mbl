#!/usr/bin/env bash
# Copyright (c) 2019 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

#shellcheck disable=SC2016
#shellcheck disable=SC2129
set -e
set -u

wget https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz &&
tar -C /usr/local -xzf go1.12.7.linux-amd64.tar.gz

export GOPATH=~/go
echo 'export GOPATH="$HOME/go"' >> ~/.bashrc

export PATH=$PATH:/usr/local/go/bin
echo 'export PATH="$PATH:/usr/local/go/bin"' >> ~/.bashrc

echo 'export GO111MODULE="on"' >> ~/.bashrc

echo 'export PATH="$PATH:$GOPATH/bin"' >> ~/.bashrc

mkdir -p "$GOPATH/src/github.com/hashicorp" && cd "$_"
git clone https://github.com/hashicorp/vault.git &&
cd vault

git checkout -b atf-pki-engine-changes 7f5e7818fd784ae0b7baa906f2c76cafdc5c28b0
