#! /bin/sh

# Pre-create domain

mkdir -p ${DOMAIN_HOME}
if [ ${?} -ne 0 ]; then exit 1; fi

mkdir -p ${DOMAIN_DEPLOY}
if [ ${?} -ne 0 ]; then exit 1; fi

cp -R ${DOMAIN_STAGE}/ext/* ${DOMAIN_DEPLOY}
if [ ${?} -ne 0 ]; then exit 1; fi

ln -s ${JAVA_HOME} ${JRE_LINK}
if [ ${?} -ne 0 ]; then exit 1; fi

ln -s ${ORACLE_HOME} ${WLS_LINK}
if [ ${?} -ne 0 ]; then exit 1; fi

# Create domain

mystatus=0
pushd ${DOMAIN_STAGE}
./config.sh ${DOMAIN_ENVIRONMENT}
if [ ${?} -ne 0 ]; then mystatus=1; fi
popd
if [ ${mystatus} -ne 0 ]; then exit 1; fi

# Post-create domain

sed -i -e 's/\${PROXY_SETTINGS}/\${CIS_PROPERTIES} \${PROXY_SETTINGS}/g' ${DOMAIN_HOME}/bin/startWebLogic.sh
if [ ${?} -ne 0 ]; then exit 1; fi

mystatus=0
pushd ${DOMAIN_PARENT}
ln -s ${JAVA_HOME} jre
if [ ${?} -ne 0 ]; then mystatus=1; fi
popd
if [ ${mystatus} -ne 0 ]; then exit 1; fi

# Exit gracefully

exit 0

