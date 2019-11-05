# Copyright (c) 2018 Arm Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: MIT

DESCRIPTION = "ARM AArch64 toolchain source license checking."
LICENSE  = "BSD-3-Clause & BSD-3-Clause-With-Intel-Modifications & BSD-Prior & BSL-1.0 & bzip2"
LICENSE += " & GPL-2.0 & GPL-3.0 & GPL-3.0-with-GCC-exception"
LICENSE += " & Info-ZIP"
LICENSE += " & LGPL-2.1 & LGPL-3.0"
LICENSE += " & MIT"
LICENSE += " & (MPL-1.1 | GPL-2.0+ | LGPL-2.1+)"
LICENSE += " & NCSA"
LICENSE += " & Zlib"


# The arm-8.2-2019.01 toolchain source is fetched so the (many) licenses not
# present in the toolchain tarball can be checked. The source used to
# build the toolchain has been tagged with "gcc-8_2_0-release", and the
# commit for this tag is specified at SRCREV_${TOOLCHAIN_NAME} below.
TOOLCHAIN_NAME = "gcc"
SRC_URI = "git://github.com/gcc-mirror/gcc.git;nobranch=1;protocol=https;name=${TOOLCHAIN_NAME};destsuffix=git/${TOOLCHAIN_NAME}"
SRCREV_${TOOLCHAIN_NAME} = "9fb89fa845c1b2e0a18d85ada0b077c84508ab78"

# For detailed information on licenses check here: https://spdx.org/licenses.
# The methodology is to check all licenses found, and to check a representative license
# in every subdirectory. When the toolchain is updated, this has a reasonable
# chance of detecting changes.
# Licenses found in the sources include the following:
#   - <srcdir>/COPYING: GPLv2.
#   - <srcdir>/COPYING3: GPLv3.
#   - <srcdir>/COPYING.LIB: LGPLv2.1.
#   - <srcdir>/COPYING3.LIB: LGPLv3.
#   - <srcdir>/COPYING3.RUNTIME: GPL-3.0-with-GCC-exception.
#   - <srcdir>/mkdep: BSD-Prior License (included in meta-mbl/files/custom-licenses/BSD-Prior).
#   - <srcdir>/gcc/go/gofrontend/LICENSE: BSD-3-Clause.
#   - <srcdir>/gcc/testsuite/gcc.dg/params/LICENSE: bzip2.
#   - <srcdir>/gnattools: GPLv3.
#   - <srcdir>/gotools: GPLv3.
#   - <srcdir>/include: GPLv2 | GPLv3.
#   - <srcdir>/INSTALL: obsolete and therefore not checked.
#   - <srcdir>/intl: GPLv2, based on the gettext sources.
#   - <srcdir>/libada/Makfile.in: GPLv3.
#   - <srcdir>/libatomic/libatomic_i.h: GPLv3.
#   - <srcdir>/libbacktrace/backtrace.h/c: BSD-3-Clause.
#   - <srcdir>/libcc1/libcc1.cc: GPLv3.
#   - <srcdir>/libccp/libccp/cpplib.h: GPLv3.
#   - <srcdir>/libdecnumber/libdecnumber.h: GPLv3.
#   - <srcdir>/libdecnumber/libdecnumber.c: GPLv3.
#   - <srcdir>/libffi/LICENSE: MIT.
#   - <srcdir>/libffi/msvcc.sh: MPL-1.1 | GPL-2.0 | LGPL-2.1.
#   - <srcdir>/libgcc/libgcc2.h: GPLv3.
#   - <srcdir>/libgcc/libgcc2.c: GPLv3.
#   - <srcdir>/libgfortran/libgfortran.h: GPLv3.
#   - <srcdir>/libgo/LICENSE: BSD-3-Clause.
#   - <srcdir>/libgomp/libgomph.h: GPLv3.
#   - <srcdir>/libhsail-rt/Makefile.in: BSD-3-Clause.
#   - <srcdir>/libiberty/COPYING.LIB: LGPL-2.1.
#   - <srcdir>/libitm/libitm.h: GPLv3.
#   - <srcdir>/libmpx/mpxrt/mpxrt.c: BSD-3-Clause.
#   - <srcdir>/libobjc/objc/objc.h: GPLv3.
#   - <srcdir>/liboffloadmic/Makefile.in:  BSD-3-Clause with Intel modifications.
#   - <srcdir>/libquadmath/COPYING.LIB: LGPL-2.1.
#   - <srcdir>/libsanitizer/LICENSE.TXT: BSD-Like NCSA.
#   - <srcdir>/libssp/ssp/ssp.h.in: GPLv3.
#   - <srcdir>/libssp/ssp.c: GPLv3.
#   - <srcdir>/libstdc++-v3/doc/html/manual/license.html: GPL-3.0-with-GCC-exception.
#   - <srcdir>/libvtv/vtv_fail.h: GPLv3.
#   - <srcdir>/lto-plugin/lto-plugin.c: GPLv3.
#   - <srcdir>/zlib/README: Zlib license.
#   - <srcdir>/zlib/contrib/dotzlib/LICENSE_1_0.txt:  BSL-1.0. (Boost Standard Library).
#   - <srcdir>/zlib/contrib/minizip/unzip.c: Info-ZIP (included in meta-mbl/files/custom-licenses/Info-ZIP).
#   - <srcdir>/include/COPYING: GPLv2.
#   - <srcdir>/gcc/COPYING: GPLv2.
#   - <srcdir>/include/COPYING3: GPLv3.
#   - <srcdir>/gcc/COPYING3: GPLv3.
#   - <srcdir>/gcc/COPYING.LIB: LGPLv2.1.
#   - <srcdir>/gcc/COPYING3.LIB: LGPLv3.
LIC_FILES_CHKSUM = "\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/COPYING;md5=59530bdf33659b29e73d4adb9f9f6552\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/COPYING3;md5=d32239bcb673463ab874e80d47fae504\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/COPYING.LIB;md5=2d5025d4aa3495befef8f17206a5b0a1\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/COPYING3.LIB;md5=6a6a8e020838b23406c81b19c1d46df6\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/COPYING.RUNTIME;md5=fe60d87048567d4fe8c8a0ed2448bcc8\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/mkdep;md5=fbe2467afef81c41c166173adeb0ee20\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/gcc/go/gofrontend/LICENSE;md5=5d4950ecb7b26d2c5e4e7b4e0dd74707\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/gcc/testsuite/gcc.dg/params/LICENSE;md5=ddeb76cd34e791893c0f539fdab879bb\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/gotools/Makefile.in;beginline=1;endline=33;md5=d13646d8eef44071b7af6c0642cafaf1\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/intl/gettext.c;beginline=1;endline=17;md5=6d7d46dac1353cac04ea59467b610126\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libada/Makefile.in;beginline=1;endline=16;md5=0c95248f87a70187cd160609cb6d6d43\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libatomic/libatomic_i.h;beginline=1;endline=26;md5=1d09eb9af057b8c94e73b1d103d631ce\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libbacktrace/backtrace.h;beginline=1;endline=31;md5=50ea1611bd45c44e438e41fc5067579e\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libbacktrace/backtrace.c;beginline=1;endline=31;md5=b8e8487161e4c704a6d6698ea0d3e8a1\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libcc1/libcc1.cc;beginline=1;endline=18;md5=2128c47250bff81b99bffd8ed20d1337\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libcpp/include/cpplib.h;beginline=1;endline=17;md5=db815b4c63e65daf114838dfcdca7ff8\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libdecnumber/decNumber.h;beginline=1;endline=24;md5=d5e78290aaf71fb8d6f463f7c73e086e\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libdecnumber/decNumber.c;beginline=1;endline=24;md5=b5d692afe4b0319831feafa63d9a3d8f\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libffi/LICENSE;md5=3610bb17683a0089ed64055416b2ae1b\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libffi/msvcc.sh;md5=0dd931f90b5ac8568d3cd820c0560d03\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libgcc/libgcc2.h;beginline=1;endline=23;md5=c04db6aabf222f1142b4bae1255f0c2d\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libgcc/libgcc2.c;beginline=1;endline=24;md5=f4da1d5464848e3d64ed960043cba393\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libgfortran/libgfortran.h;beginline=1;endline=25;md5=3c41ebff2e8f2850942f8cdcc60a5a72\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libgo/LICENSE;md5=5d4950ecb7b26d2c5e4e7b4e0dd74707\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libgomp/libgomp.h;beginline=1;endline=24;md5=67b4d3be7189a2bf1bed9ba9166c1e84\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libhsail-rt/Makefile.in;md5=a38674477ad0a784b375b84f710eb630\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libiberty/COPYING.LIB;md5=a916467b91076e631dd8edb7424769c7\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libitm/libitm.h;beginline=1;endline=23;md5=8112d5bf9ce530070a965d345145fc5c\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libmpx/mpxrt/mpxrt.c;md5=b1f7e289fae56fec6fede250b6afd7e6\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libobjc/objc/objc.h;beginline=1;endline=23;md5=70510e8e8190ab89a0e1e5138636e9d6\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/liboffloadmic/Makefile.in;md5=30b43aa8aba9a4769f58028e2f0424f7\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libquadmath/COPYING.LIB;md5=a916467b91076e631dd8edb7424769c7\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libsanitizer/LICENSE.TXT;md5=0249c37748936faf5b1efd5789587909\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libssp/ssp/ssp.h.in;beginline=1;endline=32;md5=1696be708b1bfbc4754690ac8a4f33e2\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libssp/ssp.c;beginline=1;endline=32;md5=c06d391208c0cfcbc541a6728ed65cc4\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libstdc++-v3/doc/html/manual/license.html;md5=ae9b2e57903953c857a0a2314010036c\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libvtv/vtv_fail.h;beginline=1;endline=22;md5=d43c393c2488b12873345aa6da1ca5bc\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/lto-plugin/lto-plugin.c;beginline=1;endline=17;md5=f3e320a775f0bd3171a79d617d634a71\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/zlib/README;md5=26a915e4bc7d8d65872c524a4716e51e\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/zlib/contrib/dotzlib/LICENSE_1_0.txt;md5=81543b22c36f10d20ac9712f8d80ef8d\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/zlib/contrib/minizip/unzip.c;md5=e6ee69414e1309f0669ae661ca56a7b3\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/include/COPYING;md5=59530bdf33659b29e73d4adb9f9f6552\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/gcc/COPYING;md5=59530bdf33659b29e73d4adb9f9f6552\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/include/COPYING3;md5=d32239bcb673463ab874e80d47fae504\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/gcc/COPYING3;md5=d32239bcb673463ab874e80d47fae504\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/gcc/COPYING3.LIB;md5=6a6a8e020838b23406c81b19c1d46df6\
    "

BBCLASSEXTEND="native"
