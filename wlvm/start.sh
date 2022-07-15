#! /bin/sh

# Start application

mymanaged=${1}
mystatus=0
pushd ${DOMAIN_CONTROL}
. ./env.sh
./start.sh ${DOMAIN_ENVIRONMENT} ${mymanaged}
if [ ${?} -ne 0 ]; then mystatus=1; fi
popd
if [ ${mystatus} -ne 0 ]; then exit 1; fi

# Exit gracefully

exit 0

