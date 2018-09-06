DESCRIPTION = "Linaro AArch64 toolchain source license checking"
LICENSE  = "BSD-3-Clause & BSD-3-Clause-With-Intel-Modifications & BSD-Prior & BSL-1.0 & bzip2"
LICENSE += " & GPL-2.0 & GPL-3.0 & GPL-3.0-with-GCC-exception"
LICENSE += " & Info-ZIP"
LICENSE += " & LGPL-2.1 & LGPL-3.0"
LICENSE += " & MIT"
LICENSE += " & (MPL-1.1 | GPL-2.0+ | LGPL-2.1+)"
LICENSE += " & NCSA"
LICENSE += " & Zlib"


# The linaro-7.2-2017.11 toolchain source is fetched so the (many) licenses not
# present in the linaro toolchain tarball can be checked. The source used to 
# build the toolchain has been tagged with "linaro-7.2-2017.11", and the 
# commit for this tag is specified at SRCREV_${TOOLCHAIN_NAME} below. 
TOOLCHAIN_NAME = "lintc"
SRC_URI = "git://git.linaro.org/toolchain/gcc.git;nobranch=1;name=${TOOLCHAIN_NAME};destsuffix=git/${TOOLCHAIN_NAME}"
SRCREV_${TOOLCHAIN_NAME} = "ada5dcbb13a703ed2a53922e819f96b998acc443"

# For detailed information on licenses check here: https://spdx.org/licenses. 
# Licenses found in the sources include the following:
#   - <srcdir>/COPYING: GPLv2
#   - <srcdir>/COPYING3: GPLv3
#   - <srcdir>/COPYING.LIB: LGPLv2.1
#   - <srcdir>/COPYING3.LIB: LGPLv3
#   - <srcdir>/COPYING3.RUNTIME: GPL-3.0-with-GCC-exception
#   - <srcdir>/mkdep: BSD-Prior License (included in meta-mbl/files/custom-licenses/BSD-Prior)
#   - <srcdir>/libbacktrace/Makefile.in: BSD-3-Clause 
#   - <srcdir>/libcilkrts/Makefile.in: BSD-3-Clause with Intel modifications 
#     (included in meta-mbl/files/custom-licenses/BSD-3-Clause-with-Intel-Modifications)
#   - <srcdir>/libffi/LICENSE: MIT
#   - <srcdir>/libffi/libffi/msvcc.sh: "MPL-1.1 | GPL-2.0 | LGPL-2.1"
#   - <srcdir>/libgo/LICENSE: BSD-3-Clause
#   - <srcdir>/libhsail-rt/Makefile.in: BSD-3-Clause   
#   - <srcdir>/libiberty/COPYING.LIB: LGPL-2.1
#   - <srcdir>/libmpx/mpxrt/mpxrt.c: BSD-3-Clause
#   - <srcdir>/liboffloadmic/Makefile.in: BSD-3-Clause
#   - <srcdir>/libquadmath/COPYING.LIB: LGPL-2.1
#   - <srcdir>/libsanitizer/LICENSE.TXT: BSD-Like NCSA
#   - <srcdir>/libstdc++-v3/doc/html/manual/license.html: GPL-3.0-with-GCC-exception
#   - <srcdir>/gcc/testsuite/gcc.dg/params/LICENSE: bzip2.
#   - <srcdir>/gcc/go/gofrontend/LICENSE: BSD-3-Clause
#   - <srcdir>/zlib/README: Zlib license.
#   - <srcdir>/zlib/contrib/dotzlib/LICENSE_1_0.txt:  BSL-1.0. (Boost Standard Library).
#   - <srcdir>/zlib/contrib/minizip/unzip.c: Info-ZIP (included in meta-mbl/files/custom-licenses/Info-ZIP)
LIC_FILES_CHKSUM = "\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/COPYING;md5=59530bdf33659b29e73d4adb9f9f6552\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/COPYING3;md5=d32239bcb673463ab874e80d47fae504\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/COPYING.LIB;md5=2d5025d4aa3495befef8f17206a5b0a1\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/COPYING3.LIB;md5=6a6a8e020838b23406c81b19c1d46df6\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/COPYING.RUNTIME;md5=fe60d87048567d4fe8c8a0ed2448bcc8\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/mkdep;md5=fbe2467afef81c41c166173adeb0ee20\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/gcc/go/gofrontend/LICENSE;md5=5d4950ecb7b26d2c5e4e7b4e0dd74707\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/gcc/testsuite/gcc.dg/params/LICENSE;md5=ddeb76cd34e791893c0f539fdab879bb\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libbacktrace/Makefile.in;md5=d470ca14200db6955e2aa4b9e0bdb4ad\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libcilkrts/Makefile.in;md5=6e9956a8b6e5fc457cc5ddb53701d8ca\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libffi/LICENSE;md5=3610bb17683a0089ed64055416b2ae1b\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libgo/LICENSE;md5=5d4950ecb7b26d2c5e4e7b4e0dd74707\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libgo/LICENSE;md5=5d4950ecb7b26d2c5e4e7b4e0dd74707\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libhsail-rt/Makefile.in;md5=a38674477ad0a784b375b84f710eb630\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libiberty/COPYING.LIB;md5=a916467b91076e631dd8edb7424769c7\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libmpx/mpxrt/mpxrt.c;md5=b1f7e289fae56fec6fede250b6afd7e6\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/liboffloadmic/Makefile.in;md5=30b43aa8aba9a4769f58028e2f0424f7\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libquadmath/COPYING.LIB;md5=a916467b91076e631dd8edb7424769c7\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libsanitizer/LICENSE.TXT;md5=0249c37748936faf5b1efd5789587909\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/libstdc++-v3/doc/html/manual/license.html;md5=f2cbe7a16c1459eb9d661c4f59148c85\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/zlib/README;md5=26a915e4bc7d8d65872c524a4716e51e\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/zlib/contrib/dotzlib/LICENSE_1_0.txt;md5=81543b22c36f10d20ac9712f8d80ef8d\
    file://${WORKDIR}/git/${TOOLCHAIN_NAME}/zlib/contrib/minizip/unzip.c;md5=e6ee69414e1309f0669ae661ca56a7b3\
    "

BBCLASSEXTEND="native"
