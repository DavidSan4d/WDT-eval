#! /bin/sh

#    **********************************************************************    #
#                                                                              #
#    This file configures the project WebLogic domain using WLST.  No          #
#    changes are required in this file; that is, environment independent or    #
#    specific variables should be configured in the config-Common.sh or        #
#    config-<CIS_ENVIRONMENT>.sh environment files respectively.  The          #
#    following environment variables are accessible to WLST as properties:     #
#                                                                              #
#           - WEBLOGIC_HOME                                                    #
#                                                                              #
#    **********************************************************************    #

# --- Start Functions ---

usage() {
  echo
  echo "Usage: ${1} CIS_ENVIRONMENT"
  echo "Example 1: Configure domain for \"WLST\" environment:"
  echo "  ${1} WLST"
  echo "Example 2: Configure domain for \"Red\" environment:"
  echo "  ${1} Red"
  echo
}

# --- End Functions ---

# Set CIS environment
if [ "${1}" = "" ] ; then
  usage ${0}
  exit 1
else
  CIS_ENVIRONMENT="${1}"
  shift
fi

# Import environment independent variables
if [ -f "config-Common.sh" ]; then
  . "./config-Common.sh"
fi

# Sanity check mandatory environment variables are set
if [ "${JRE_LINK}" = "" ]; then
  echo "Environment variable JRE_LINK not set"
  exit 1
fi
if [ "${WLS_LINK}" = "" ]; then
  echo "Environment variable WLS_LINK not set"
  exit 1
fi

echo
echo "Configuring domain in \"${CIS_ENVIRONMENT}\" environment ..."
echo

# Set WebLogic environment
JAVA_HOME=`readlink ${JRE_LINK}`
if [ ${?} -ne 0 ]; then exit 1; fi
JAVA_VENDOR=Oracle
WEBLOGIC_HOME=`readlink ${WLS_LINK}`
if [ ${?} -ne 0 ]; then exit 1; fi
WL_HOME="${WEBLOGIC_HOME}/wlserver"
. "${WL_HOME}/server/bin/setWLSEnv.sh"

# Configure domain
java weblogic.WLST config.py ${CIS_ENVIRONMENT}

# Exit gracefully
exit $?

