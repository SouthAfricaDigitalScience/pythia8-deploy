#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy

echo "All tests have passed, will now build into ${SOFT_DIR}"
cd ${WORKSPACE}/${NAME}${VERSION}
./configure --prefix=${SOFT_DIR}-root-${ROOT_VERSION} \
--enable-shared \
--enable-64bit \
--with-root=${ROOT_DIR} \
--with-hepmc3=${HEPMC_DIR} \
--with-hepmc3-lib=${HEPMC_DIR}/lib64/ \
--with-boost=${BOOST_DIR} \
--with-python=${PYTHON_DIR} \
--with-python-include=${PYTHON_DIR}/include/python${PYTHON_VERSION:0:3}

make install
echo "Creating the modules file directory ${LIBRARIES_MODULES}"
mkdir -p ${LIBRARIES_MODULES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/pytha8-deploy"
setenv PYTHIA8_VERSION       $VERSION
setenv PYTHIA8_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(PYTHIA8_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(PYTHIA8_DIR)/include
setenv CFLAGS            "$CFLAGS -I${PYTHIA8_DIR}/include"
setenv LDFLAGS           "$LDFLAGS -L${PYTHIA8_DIR}/lib"
MODULE_FILE
) > ${HEP}/${NAME}/${VERSION}-root-${ROOT_VERSION}

module avail ${NAME}
module add ${NAM}/${VERSION}-root-${ROOT_VERSION}
