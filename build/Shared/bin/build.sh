#! /bin/sh

#    **********************************************************************    #
#                                                                              #
#    This file builds the project using the Apache Ant Java build tool.  No    #
#    changes are required in this file; that is, build environment             #
#    independent or specific variables should be configured in the             #
#    build_Common.sh or build_<CIS_ENVIRONMENT>.sh environment files           #
#    respectively.                                                             #
#                                                                              #
#    **********************************************************************    #

# Configure environment variables accessible to Ant as properties
PROJECT_VARIABLES=(
 CIS_ENVIRONMENT\
 PROJECT_NAME\
 JAVA_HOME\
 WEBLOGIC_HOME\
 BUILD_HOME\
 BUILD_SHARED_HOME\
 BUILD_COMMON_HOME\
 BUILD_SERVER_HOME\
 BUILD_SERVICE_HOME\
 BUILD_MTP_HOME\
 SOURCE_HOME\
 SOURCE_SHARED_HOME\
 SOURCE_COMMON_HOME\
 SOURCE_SERVER_HOME\
 SOURCE_SERVICE_HOME\
 PACKAGE_HOME\
 PACKAGE_COMMON_HOME\
 PACKAGE_SERVER_HOME\
 PACKAGE_SERVICE_HOME\
 PACKAGE_MTP_HOME\
 DEPLOY_HOME\
 DEPLOY_COMMON_HOME\
 DEPLOY_SERVER_HOME\
 DEPLOY_SERVICE_HOME\
 DEPLOY_MTP_HOME\
 PROJECT_BUILD_HOME\
 PROJECT_SOURCE_HOME\
 PROJECT_PACKAGE_HOME\
 PROJECT_DEPLOY_HOME\
 PROJECT_EXECUTABLE\
 PROJECT_VERSION\
 PROJECT_RELEASE
)

# --- Start Functions ---

usage() {
  echo
  echo "Usage: ${1} CIS_ENVIRONMENT CIS_PROJECT {ANT_TARGET}"
  echo 'Example 1: Refresh "Common" project in "L1" environment:'
  echo "  ${1} L1 COMMON"
  echo 'Example 2: Rebuild "Server" project in "L2" environment:'
  echo "  ${1} L2 SERVER rebuild"
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

# Set CIS project
if [ "${1}" = "" ] ; then
  usage ${0}
  exit 1
else
  CIS_PROJECT="${1}"
  shift
fi

# Get application directory
BIN_HOME=`dirname ${0}`

# Import environment independent variables
if [ -f "${BIN_HOME}/build_Common.sh" ]; then
  . "${BIN_HOME}/build_Common.sh"
else
  echo "Common environment not imported"
  exit 1
fi

# Set environment project variables
PROJECT_VARIABLE="BUILD_${CIS_PROJECT}_HOME"
PROJECT_BUILD_HOME=${!PROJECT_VARIABLE}
if [ -z ${PROJECT_BUILD_HOME} ]; then
  echo "Project \"${CIS_PROJECT}\" build not defined"
  exit 1
elif [ ! -d ${PROJECT_BUILD_HOME} ]; then
  echo "Project \"${CIS_PROJECT}\" build \"${PROJECT_BUILD_HOME}\" not supported"
  exit 1
else
  PROJECT_VARIABLE="SOURCE_${CIS_PROJECT}_HOME"
  PROJECT_SOURCE_HOME=${!PROJECT_VARIABLE}
  if [ ! "${CIS_PROJECT}" == "MTP" ]; then
    if [ -z ${PROJECT_SOURCE_HOME} ]; then
      echo "Project \"${CIS_PROJECT}\" source not defined"
      exit 1
    elif [ ! -d ${PROJECT_SOURCE_HOME} ]; then
      echo "Project \"${CIS_PROJECT}\" source \"${PROJECT_SOURCE_HOME}\" not supported"
      exit 1
    fi
  fi
  PROJECT_VARIABLE="PACKAGE_${CIS_PROJECT}_HOME"
  PROJECT_PACKAGE_HOME=${!PROJECT_VARIABLE}
  PROJECT_VARIABLE="DEPLOY_${CIS_PROJECT}_HOME"
  PROJECT_DEPLOY_HOME=${!PROJECT_VARIABLE}
  PROJECT_BUILD_DIR_ETC="${PROJECT_BUILD_HOME}/etc"
  PROJECT_PROPERTIES=
  for i in ${PROJECT_VARIABLES[*]}
  do
    PROJECT_PROPERTIES="${PROJECT_PROPERTIES} -D${i}=${!i}"
  done
fi

echo
echo "Building \"${CIS_PROJECT}\" project in \"${CIS_ENVIRONMENT}\" environment ..."
echo

# Set Java specific environment variables
JAVA_DIR_BIN="${JAVA_HOME}/bin"

# Set Ant Launcher specific environment variables
ANT_DIR_LIB="${ANT_HOME}/lib"
ANT_JAR_LAUNCHER="${ANT_DIR_LIB}/ant-launcher.jar"
ANT_LAUNCHER_CLASSPATH="${ANT_JAR_LAUNCHER}"
ANT_LAUNCHER_LIB=
ANT_LAUNCHER_BUILDFILE="${PROJECT_BUILD_DIR_ETC}/build.xml"

# Build project
${JAVA_DIR_BIN}/java -Xmx512m -classpath "${ANT_LAUNCHER_CLASSPATH}" -Dant.home=${ANT_HOME} ${PROJECT_PROPERTIES} org.apache.tools.ant.launch.Launcher -lib "${ANT_LAUNCHER_LIB}" -f "${ANT_LAUNCHER_BUILDFILE}" ${@}

# Exit gracefully
exit $?
