# Descriptive Meta-data
SUMMARY = "Python library for mathematics, science, and engineering"
DESCRIPTION = "\
    SciPy (pronounced “Sigh Pie”) is open-source software for \
    mathematics, science, and engineering. The SciPy library depends on NumPy, \
    which provides convenient and fast N-dimensional array manipulation. The SciPy \
    library is built to work with NumPy arrays, and provides many user-friendly and \
    efficient numerical routines such as routines for numerical integration and \
    optimization. Together, they run on all popular operating systems, are quick to \
    install, and are free of charge. NumPy and SciPy are easy to use, but powerful \
    enough to be depended upon by some of the world’s leading scientists and \
    engineers. If you need to manipulate numbers on a computer and display or \
    publish the results, give SciPy a try! \
"
AUTHOR = "SciPy developers <https://www.scipy.org/>"
HOMEPAGE = "https://www.scipy.org/index.html"

# Package Manager Meta-data
SECTION = "devel/python"
PRIORITY = "optional"

# Licensing Meta-data
LICENSE = " Apache-2.0 & BSD & BSD-2-Clause & BSD-3-Clause & MIT & PSF & Qhull"
LIC_FILES_CHKSUM = "\
    file://LICENSE.txt;md5=be4a7946a904c1b639bcfe4da4f795b8 \
    file://doc/sphinxext/LICENSE.txt;md5=dc37e8b18377b83250218fc557984e1a \
    file://scipy/sparse/linalg/dsolve/SuperLU/License.txt;md5=665d3a848ec7c94b78ae986bd84e640a \
    file://scipy/sparse/linalg/eigen/arpack/ARPACK/COPYING;md5=29e47344f98423df9aa3032994f313fc \
    file://scipy/spatial/qhull/COPYING.txt;md5=6cf68697da2f499f1207c84dc319b727 \
    file://scipy/linalg/src/id_dist/doc/doc.tex;md5=b261e300b0d4e1e43ca3f2af300bc56b \
    file://scipy/_lib/six.py;md5=718bf2c48324fce8ac372ea33b119645 \
    file://scipy/_lib/decorator.py;md5=8b1ffef5d43b36cb2e8357161e07fc9c \
    file://scipy/optimize/lbfgsb/README;md5=9d8fbfae24e8b51c9fbd2dde89b8ee65 \
"

# Build Meta-data
DEPENDS += "\
    ${PYTHON_PN}-numpy \
"
SRCNAME = "scipy"
SRC_URI = "https://github.com/${SRCNAME}/${SRCNAME}/releases/download/v${PV}/${SRCNAME}-${PV}.tar.gz"
S = "${WORKDIR}/${SRCNAME}-${PV}"
SRC_URI[md5sum] = "aa6bcc85276b6f25e17bcfc4dede8718"
SRC_URI[sha256sum] = "878352408424dffaa695ffedf2f9f92844e116686923ed9aa8626fc30d32cfd1"

# Runtime Meta-data
RDEPENDS_${PN} += "\
    ${PYTHON_PN}-numpy \
"