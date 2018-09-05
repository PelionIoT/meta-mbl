# libbacktrace is essential to fix libgfortran breakage due to dependency.
RUNTIMETARGET += "\
    libbacktrace \
    libgfortran \
"
