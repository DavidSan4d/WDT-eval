#! /bin/sh

# Pre-create domain

mkdir -p ${DOMAIN_HOME}
if [ ${?} -ne 0 ]; then exit 1; fi

# Create domain

PATH=${PATH}:${WDT_HOME}/bin
createDomain.sh \
  -use_encryption \
  -domain_type WLS \
  -domain_parent ${DOMAIN_PARENT} \
  -model_file model.yaml \
  -archive_file model.zip \
  -variable_file model.properties \
  < model.secret
if [ ${?} -ne 0 ]; then exit 1; fi

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

