#! /bin/sh

# Pre-build application

if [ -d ${WLVM_PACKAGE} ]; then
  rm -r ${WLVM_PACKAGE}
  if [ ${?} -ne 0 ]; then exit 1; fi
fi

mkdir -p ${WLVM_PACKAGE}
if [ ${?} -ne 0 ]; then exit 1; fi

cp ${WLVM_ROOT}/build/Shared/bin/env.sh ${WLVM_PACKAGE}
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@JAVA_HOME@@:${JAVA_HOME}:g" ${WLVM_PACKAGE}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@WEBLOGIC_HOME@@:${WL_HOME}:g" ${WLVM_PACKAGE}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi

# Build application

mystatus=0
pushd ${WLVM_ROOT}/build/Shared/bin
. ${WLVM_PACKAGE}/env.sh
./build.sh ${WLVM_TARGET} MTP
if [ ${?} -ne 0 ]; then mystatus=1; fi
popd
if [ ${mystatus} -ne 0 ]; then exit 1; fi

# Post-build application

rm -r ${WLVM_PACKAGE}
if [ ${?} -ne 0 ]; then exit 1; fi

# Exit gracefully

exit 0

