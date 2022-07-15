#! /bin/sh

# Extract server and cluster information

myservers=(`echo ${WLVM_TARGET_SERVERS} | tr ',' ' '`)
myadminserver=${myservers[0]}
myiscluster='false'
if [ ${#myservers[@]} -gt 1 ]; then myiscluster='true'; fi

# Package initialization

if [ -d ${WLVM_PACKAGE} ]; then
  rm -r ${WLVM_PACKAGE}
  if [ ${?} -ne 0 ]; then exit 1; fi
fi

mydeploy=${WLVM_PACKAGE}/stage
mkdir -p ${mydeploy}
if [ ${?} -ne 0 ]; then exit 1; fi

mywlsdeploy=${mydeploy}/ext
mkdir -p ${mywlsdeploy}
if [ ${?} -ne 0 ]; then exit 1; fi

# Package WLVM scripts

cp ${WLVM_HOME}/env-wlst.sh ${WLVM_PACKAGE}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@JAVA_HOME@@:${WLVM_TARGET_JRE}:g" ${WLVM_PACKAGE}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@ORACLE_HOME@@:${WLVM_TARGET_ORACLE}:g" ${WLVM_PACKAGE}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@WLVM_HOME@@:${WLVM_TARGET_TMP}:g" ${WLVM_PACKAGE}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s/@@DOMAIN_ENVIRONMENT@@/${WLVM_TARGET}/g" ${WLVM_PACKAGE}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@DOMAIN_STAGE@@:${WLVM_TARGET_TMP}/stage:g" ${WLVM_PACKAGE}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@DOMAIN_DEPLOY@@:${WLVM_DOMAIN_HOME}/ext:g" ${WLVM_PACKAGE}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@DOMAIN_PARENT@@:${WLVM_DOMAIN_PARENT}:g" ${WLVM_PACKAGE}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@DOMAIN_HOME@@:${WLVM_DOMAIN_HOME}:g" ${WLVM_PACKAGE}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@DOMAIN_VAR@@:${WLVM_TARGET_VAR}:g" ${WLVM_PACKAGE}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi

cp ${WLVM_HOME}/create.sh ${WLVM_PACKAGE}/create.sh
if [ ${?} -ne 0 ]; then exit 1; fi

cp ${WLVM_HOME}/start.sh ${WLVM_PACKAGE}/start.sh
if [ ${?} -ne 0 ]; then exit 1; fi

cp ${WLVM_HOME}/stop.sh ${WLVM_PACKAGE}/stop.sh
if [ ${?} -ne 0 ]; then exit 1; fi

cp ${WLVM_HOME}/kill.sh ${WLVM_PACKAGE}/kill.sh
if [ ${?} -ne 0 ]; then exit 1; fi

cp ${WLVM_HOME}/clean.sh ${WLVM_PACKAGE}/clean.sh
if [ ${?} -ne 0 ]; then exit 1; fi

# Package domain applications

mydomainapplication=${WLVM_DOMAIN_HOME}/ext/app

myapplications=${mywlsdeploy}/app
mkdir -p ${myapplications}
if [ ${?} -ne 0 ]; then exit 1; fi

cp ${WLVM_ROOT}/build/deploy/Service/* ${myapplications}
if [ ${?} -ne 0 ]; then exit 1; fi

# Package domain classpath libraries

myclasspathlibraries=${mywlsdeploy}/lib
mkdir -p ${myclasspathlibraries}
if [ ${?} -ne 0 ]; then exit 1; fi

cp ${WLVM_ROOT}/domain/lib/* ${myclasspathlibraries}
if [ ${?} -ne 0 ]; then exit 1; fi

# Package domain control scripts

mydomainclasspath=${WLVM_DOMAIN_HOME}/ext/lib

mydomainbin=${mywlsdeploy}/bin
mkdir -p ${mydomainbin}
if [ ${?} -ne 0 ]; then exit 1; fi

cp ${WLVM_ROOT}/domain/bin/* ${mydomainbin}
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@JRE_LINK@@:${WLVM_DOMAIN_PARENT}/jre:g" ${mydomainbin}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@PROJECT_DOMAIN_HOME@@:${WLVM_DOMAIN_HOME}:g" ${mydomainbin}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@PROJECT_JAR_HOME@@:${mydomainclasspath}:g" ${mydomainbin}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@VAR_PROJECT_HOME@@:${WLVM_TARGET_VAR}:g" ${mydomainbin}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@PROJECT_LOG_HOME@@:${WLVM_TARGET_LOG}:g" ${mydomainbin}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s/@@PROJECT_ADMIN_SERVER@@/${myadminserver}/g" ${mydomainbin}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s/@@PROJECT_ADMIN_PORT@@/${WLVM_SERVER_ADMIN_PORT}/g" ${mydomainbin}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s/@@PROJECT_MANAGED_PORT@@/${WLVM_SERVER_MANAGED_PORT}/g" ${mydomainbin}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s/@@PROJECT_SERVER_LOG_FLAG@@/${WLVM_SERVER_LOG}/g" ${mydomainbin}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s/@@APPD_AGENT@@/${WLVM_SERVER_APPD}/g" ${mydomainbin}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi

# Package domain config

cp ${WLVM_ROOT}/domain/wlst/* ${mydeploy}
if [ ${?} -ne 0 ]; then exit 1; fi

sed -i -e "s:@@JAVA_HOME@@:${WLVM_TARGET_JRE}:g" ${mydeploy}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@ORACLE_HOME@@:${WLVM_TARGET_ORACLE}:g" ${mydeploy}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@WLVM_HOME@@:${WLVM_TARGET_TMP}:g" ${mydeploy}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@DOMAIN_PARENT@@:${WLVM_DOMAIN_PARENT}:g" ${mydeploy}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@DOMAIN_HOME@@:${WLVM_DOMAIN_HOME}:g" ${mydeploy}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@DOMAIN_STAGE@@:${WLVM_TARGET_TMP}/stage:g" ${mydeploy}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@DOMAIN_DEPLOY@@:${WLVM_DOMAIN_HOME}/ext:g" ${mydeploy}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s/@@DOMAIN_ENVIRONMENT@@/${WLVM_TARGET}/g" ${mydeploy}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@JRE_LINK@@:${WLVM_TARGET_TMP}/stage/jre:g" ${mydeploy}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@WLS_LINK@@:${WLVM_TARGET_TMP}/stage/wls:g" ${mydeploy}/env.sh
if [ ${?} -ne 0 ]; then exit 1; fi

cp ${WLVM_PACKAGE_SECRET_WLST} ${mydeploy}
if [ ${?} -ne 0 ]; then exit 1; fi

cp ${WLVM_ROOT}/domain/wlst/c2sConfigWlstCisDomain ${mydeploy}
if [ ${?} -ne 0 ]; then exit 1; fi

cp ${WLVM_ROOT}/domain/wlst/config.py ${mydeploy}
if [ ${?} -ne 0 ]; then exit 1; fi

cp ${WLVM_ROOT}/domain/wlst/config.py.properties ${mydeploy}
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s/@@USERNAME@@/${WLVM_DOMAIN_USERNAME}/g" ${mydeploy}/config.py.properties
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s/@@PASSWORD@@/${WLVM_DOMAIN_PASSWORD}/g" ${mydeploy}/config.py.properties
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s/@@DOMAINNAME@@/${WLVM_DOMAIN_NAME}/g" ${mydeploy}/config.py.properties
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@DOMAINHOME@@:${WLVM_DOMAIN_HOME}:g" ${mydeploy}/config.py.properties
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s/@@DOMAINTARGET@@/${WLVM_TARGET}/g" ${mydeploy}/config.py.properties
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s/@@DOMAINCLUSTER@@/${myiscluster}/g" ${mydeploy}/config.py.properties
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s/@@DOMAINPROD@@/${WLVM_DOMAIN_PRODUCTION}/g" ${mydeploy}/config.py.properties
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s/@@ADMINPORT@@/${WLVM_SERVER_ADMIN_PORT}/g" ${mydeploy}/config.py.properties
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s/@@MANAGEDPORT@@/${WLVM_SERVER_MANAGED_PORT}/g" ${mydeploy}/config.py.properties
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s/@@APPVERSION@@/${WLVM_APP_VERSION}/g" ${mydeploy}/config.py.properties
if [ ${?} -ne 0 ]; then exit 1; fi
sed -i -e "s:@@APPARCHIVE@@:${mydomainapplication}/cis-audit.war:g" ${mydeploy}/config.py.properties
if [ ${?} -ne 0 ]; then exit 1; fi

cp ${WLVM_ROOT}/domain/wlst/config.sh ${mydeploy}
if [ ${?} -ne 0 ]; then exit 1; fi

# Exit gracefully

exit 0

