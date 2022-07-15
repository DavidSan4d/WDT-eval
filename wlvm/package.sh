#! /bin/sh

# Package domain

./package-${WLVM_PACKAGE_TOOL}.sh
if [ ${?} -ne 0 ]; then exit 1; fi

# Exit gracefully

exit 0

