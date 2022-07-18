#!/bin/bash

set -eux

docker pull nexus2.prod.cloud.fedex.com:8444/fdx/jenkins/default-tools-image

docker build -t fdx/jenkins/wls-12214-image --build-arg TERRAFORM_VERSION=0.14.9 ./wls-12214/
if [ "$?" != "0" ]; then
	echo "Build failed"
	exit 2
fi

if [[ -z "${DOCKER_BUILD_ONLY}" ]]; then
	echo "DOCKER_BUILD_ONLY not set - assuming TRUE and STOPPING"
	exit 0
elif [[ $DOCKER_BUILD_ONLY == "yes" ]]; then
	exit 0
elif [[ $DOCKER_BUILD_ONLY == "no" ]]; then
	echo "DOCKER_BUILD_ONLY is no - will continue and PUSH TO REPO"
else
	echo "UNKNOWN value for DOCKER_BUILD_ONLY ($DOCKER_BUILD_ONLY)"
	exit 7
fi

docker tag fdx/jenkins/wls-12214-image nexus3.prod.cloud.fedex.com:8446/fdx/jenkins/wls-12214-image:latest
if [ "$?" != "0" ]; then
	echo "Tag failed"
	exit 3
fi

docker --config ./base login -u=$USER -p=$PASSWORD nexus3.prod.cloud.fedex.com:8446
if [ "$?" != "0" ]; then
	echo "Login failed"
	exit 4
fi

docker --config ./base push nexus3.prod.cloud.fedex.com:8446/fdx/jenkins/wls-12214-image:latest
if [ "$?" != "0" ]; then
	echo "Push failed"
	docker logout --config ./base nexus3.prod.cloud.fedex.com:8446
	exit 5
fi

docker --config ./base logout nexus3.prod.cloud.fedex.com:8446
if [ "$?" != "0" ]; then
	echo "Logout failed"
	exit 6
fi

