#!/bin/bash -e
# NAME is pythia8
# VERSION is 223
. /etc/profile.d/modules.sh
module add ci
module add root/${ROOT_VERSION}-gcc-${GCC_VERSION}
module add hepmc
module  add  boost/1.63.0-gcc-${GCC_VERSION}-mpi-1.8.8
module add python/2.7.13-gcc-${GCC_VERSION}
SOURCE_FILE=${NAME}${VERSION}.tgz

mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}
mkdir -p ${SOFT_DIR}

#  Download the source file

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's geet the source"
  wget http://home.thep.lu.se/~torbjorn/${NAME}/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi
tar xfz  ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
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

make
