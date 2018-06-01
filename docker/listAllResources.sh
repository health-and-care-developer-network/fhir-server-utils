#!/bin/bash

# This script will list all resources held on the fhir reference server(s), including all versions of those resources
# Usage:
# build.sh targethostname containername

TARGET_HOST=${1:-$TARGET_HOST}
CONTAINER_NAME=${2:-${CONTAINER_NAME:-fhir-server}}

if [ -z $TARGET_HOST ]
then
  TARGET_PREFIX=""
else
  TARGET_PREFIX="--tlsverify -H $TARGET_HOST:2376"
fi

echo "Retrieving list of profiles reference servers"
docker $TARGET_PREFIX exec $CONTAINER_NAME find /opt/fhir -name *.xml

