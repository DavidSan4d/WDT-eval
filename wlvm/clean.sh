#! /bin/sh

# Clean domain

if [ -d ${DOMAIN_PARENT} ]; then
  rm -r ${DOMAIN_PARENT}
  if [ ${?} -ne 0 ]; then exit 1; fi
fi

# Exit gracefully

exit 0

