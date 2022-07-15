#! /bin/sh

#    **********************************************************************    #
#                                                                              #
#    This file stops the WebLogic admin or managed server in a supported       #
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
  echo 'Example 1: Stop WebLogic admin server in L1 cluster:'
  echo "$1 L1"
  echo 'Example 2: Stop WebLogic second managed server in L3 cluster:'
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
if [ -z ${PROJECT_DOMAIN_HOME} ]; then
  echo 'Environment variable "PROJECT_DOMAIN_HOME" not set'
  exit 1
fi
if [ -z ${PROJECT_MANAGED_SERVER_URL} ]; then
  echo 'Environment variable "PROJECT_MANAGED_SERVER_URL" not set'
  exit 1
fi

# Set server name
CIS_NAME=CisAdminServer
if [ ! -z ${CIS_MANAGED} ]; then
  CIS_NAME=CisManagedServer${CIS_MANAGED}
fi

# Stop WebLogic server
if [ -z ${CIS_MANAGED} ]; then
  echo "Stopping WebLogic admin server \"${CIS_NAME}\" in \"${CIS_ENVIRONMENT}\" cluster..."
  ${PROJECT_DOMAIN_HOME}/bin/stopWebLogic.sh
  if [ ${?} -ne 0 ]; then exit 1; fi
else
  echo "Stopping WebLogic managed server \"${CIS_NAME}\" in \"${CIS_ENVIRONMENT}\" cluster..."
  ${PROJECT_DOMAIN_HOME}/bin/stopManagedWebLogic.sh ${CIS_NAME} ${PROJECT_MANAGED_SERVER_URL}
  if [ ${?} -ne 0 ]; then exit 1; fi
fi

# Exit gracefully
exit 0
