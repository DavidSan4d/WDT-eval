#! /bin/sh

#    **********************************************************************    #
#                                                                              #
#    This file starts the WebLogic admin or managed server in a supported      #
#    CIS environment.  No changes are required in this file; that is,          #
#    environment independent and specific variables should be configured in    #
#    the bin_Common.sh and bin_<CIS_ENVIRONMENT>.sh environment files          #
#    respectively.                                                             #
#                                                                              #
#    **********************************************************************    #

# --- Start Functions ---

usage() {
  echo
  echo "Usage: $1 <CIS_ENVIRONMENT> [MANAGED_SERVER_NUMBER]"
  echo 'Example 1: Start WebLogic admin server in L1 cluster:'
  echo "$1 L1"
  echo 'Example 2: Start WebLogic second managed server in L3 cluster:'
  echo "$1 L3 2"
  echo
}

# --- End Functions ---

# Set CIS environment
if [ ${#*} -lt 1 ] || [ ${#*} -gt 2 ]; then
  usage ${0}
  exit 1
else
  CIS_ENVIRONMENT=${1}
  CIS_MANAGED=${2}
fi

# Get application directory
BIN_HOME=`dirname ${0}`

# Import environment independent variables
if [ -f ${BIN_HOME}/bin_Common.sh ]; then
  . ${BIN_HOME}/bin_Common.sh
else
  echo 'Environment not imported'
  exit 1
fi

# Sanity check mandatory environment specific variables are set
if [ -z ${JRE_LINK} ]; then
  echo 'Environment variable "JRE_LINK" not set'
  exit 1
fi
if [ -z ${PROJECT_DOMAIN_HOME} ]; then
  echo 'Environment variable "PROJECT_DOMAIN_HOME" not set'
  exit 1
fi
if [ -z ${PROJECT_ADMIN_URL} ]; then
  echo 'Environment variable "PROJECT_ADMIN_URL" not set'
  exit 1
fi
if [ -z ${PROJECT_JAR_HOME} ]; then
  echo 'Environment variable "PROJECT_JAR_HOME" not set'
  exit 1
fi
if [ -z ${EAINUMBER} ]; then
  echo 'Environment variable "EAINUMBER" not set'
  exit 1
fi

# Set server name
CIS_NAME=CisAdminServer
if [ ! -z ${CIS_MANAGED} ]; then
  CIS_NAME=CisManagedServer${CIS_MANAGED}
fi

# Set project properties
CIS_DEPLOYMENT=Cis
CIS_PROPERTY_DEPLOYMENT=-DCIS_DEPLOYMENT=${CIS_DEPLOYMENT}
CIS_PROPERTY_ENVIRONMENT=-DCIS_ENVIRONMENT=${CIS_ENVIRONMENT}
CIS_PROPERTY_TIMEZONE=-Duser.timezone=GMT
CIS_PROPERTY_LOG=-Dlog4j.configurationFile=CisLog4j.xml
CIS_PROPERTY_LOG_HOME=-Dlog.home=${PROJECT_LOG_HOME}
CIS_PROPERTY_IPV4=-Djava.net.preferIPv4Stack=true
CIS_PROPERTY_WSAT=-Dweblogic.wsee.wstx.wsat.deployed=false
CIS_PROPERTIES="${CIS_PROPERTY_DEPLOYMENT} ${CIS_PROPERTY_ENVIRONMENT} ${CIS_PROPERTY_TIMEZONE} ${CIS_PROPERTY_LOG} ${CIS_PROPERTY_LOG_HOME} ${CIS_PROPERTY_IPV4} ${CIS_PROPERTY_WSAT}"
export CIS_PROPERTIES

# Set project classpath
PROJECT_JAR_LOG_API=${PROJECT_JAR_HOME}/log4j-api-2.7.jar
PROJECT_JAR_LOG_CORE=${PROJECT_JAR_HOME}/log4j-core-2.7.jar
PROJECT_JAR_DECORATOR=${PROJECT_JAR_HOME}/fedexjms.jar
PROJECT_JAR_TIBCO=${PROJECT_JAR_HOME}/tibjms.jar
#PROJECT_JAR_JMS=${PROJECT_JAR_HOME}/jms.jar
PROJECT_CLASSPATH=${PROJECT_JAR_LOG_API}:${PROJECT_JAR_LOG_CORE}:${PROJECT_JAR_DECORATOR}:${PROJECT_JAR_TIBCO}
EXT_PRE_CLASSPATH=${PROJECT_CLASSPATH}
export EXT_PRE_CLASSPATH

# Set Java vendor
JAVA_VENDOR=Oracle
export JAVA_VENDOR

# Redirect output
LOG_VAR_DIR=${VAR_PROJECT_HOME}/log
WLS_REDIRECT_LOG=${LOG_VAR_DIR}/${CIS_NAME}-Std.log
if [ "${PROJECT_SERVER_LOG_FLAG}" = "true" ] ; then
  if [ ! -d ${LOG_VAR_DIR} ]; then mkdir ${LOG_VAR_DIR}; fi
  export WLS_REDIRECT_LOG
fi

# Start AppDynamics agent
if [ "${APPD_AGENT}" == "true" ] && [ -e /opt/appd/current/appagent/javaagent.jar ]; then
  export JAVA_HOME=`readlink ${JRE_LINK}`
  export SERVER_NAME=${CIS_NAME}
  export EAINUMBER
  if [ ! -d /var/fedex/appd/logs/${EAINUMBER}/${SERVER_NAME} ]; then
    mkdir -pv /var/fedex/appd/logs/${EAINUMBER}/${SERVER_NAME}
  fi
  . /opt/appd/current/scripts/app_agent_appd.sh ${EAINUMBER}
  echo ${JAVA_OPTIONS}
fi

# Start WebLogic server as daemon
if [ -z ${CIS_MANAGED} ]; then
  echo "Starting WebLogic server \"${CIS_NAME}\" for \"${CIS_DEPLOYMENT}/${CIS_ENVIRONMENT}\" deployment environment..."
  nohup ${PROJECT_DOMAIN_HOME}/bin/startWebLogic.sh noderby 1>/dev/null 2>&1 &
  if [ ${?} -ne 0 ]; then exit 1; fi
else
  echo "Starting WebLogic server \"${CIS_NAME}\" in \"${CIS_DEPLOYMENT}/${CIS_ENVIRONMENT}\" deployment environment..."
  nohup ${PROJECT_DOMAIN_HOME}/bin/startManagedWebLogic.sh ${CIS_NAME} ${PROJECT_ADMIN_URL} >/dev/null 2>&1 &
  if [ ${?} -ne 0 ]; then exit 1; fi
fi

# Avoid race condition between remote session closing and server starting
sleep 5

# Exit gracefully
exit 0

