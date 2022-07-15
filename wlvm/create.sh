#! /bin/sh

# Create domain

mystatus=0
pushd ${DOMAIN_STAGE}
. ./env.sh
./create.sh ${DOMAIN_ENVIRONMENT}
if [ ${?} -ne 0 ]; then mystatus=1; fi
popd
if [ ${mystatus} -ne 0 ]; then exit 1; fi

# Exit gracefully

exit 0

