#!/bin/bash -e
. /etc/profile.d/modules.sh
module add ci
module add gcc/${GCC_VERSION}
module add root/${ROOT_VERSION}-gcc-${GCC_VERSION}
module add hepmc
module  add  boost/1.63.0-gcc-${GCC_VERSION}-mpi-1.8.8
module add python/2.7.13-gcc-${GCC_VERSION}

cd ${WORKSPACE}/${NAME}${VERSION}/examples
./runmains
echo $?
cd ${WORKSPACE}/${NAME}${VERSION}
make install
mkdir -p ${REPO_DIR}
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       PYTHIA8_VERSION       $VERSION
setenv       PYTHIA8_DIR           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(PYTHIA8_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(PYTHIA8_DIR)/include
setenv CFLAGS            "$CFLAGS -I${PYTHIA8_DIR}/include"
setenv LDFLAGS           "$LDFLAGS -L${PYTHIA8_DIR}/lib"
MODULE_FILE
) > modules/$VERSION-root-${ROOT_VERSION}

mkdir -vp ${HEP}/${NAME}
cp -v modules/$VERSION-root-${ROOT_VERSION} ${HEP}/${NAME}

echo "checking module availability"

module avail ${NAME}

echo "checking module "
module add  ${NAME}-root-${ROOT_VERSION}
