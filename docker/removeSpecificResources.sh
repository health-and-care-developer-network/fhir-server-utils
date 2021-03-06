#!/bin/bash

# This script will remove specific resources from the fhir reference server (by moving them into an archive directory). The list of resources (one filename per line) should be set in an environment variable which this script will process.

# Usage:
# build.sh targethostname

TARGET_HOST=${1:-$TARGET_HOST}
CONTAINER_NAME=${2:-${CONTAINER_NAME:-fhir-server}}
RESOURCE_LIST=${RESOURCE_LIST}
COMMENT=${COMMENT}

if [ -z $TARGET_HOST ]
then
  TARGET_PREFIX=""
else
  TARGET_PREFIX="--tlsverify -H $TARGET_HOST:2376"
fi

target_dir="/opt/fhir/archived/$(date +%F)"
report_file="../output/Archive-Results-$(date +%F-%R).txt"
echo "Resource delete job run on: $(date)" > $report_file
echo "Comments:" >> $report_file
echo "$COMMENT" >> $report_file
echo "" >> $report_file
echo "Outputs of delete job:" >> $report_file

moved=0

for line_item in $RESOURCE_LIST
do
	#item=$(readlink -f $line_item)
	#if [[ $item == /opt/fhir/* ]]
	#then
	
	# First, make this a canonical path to remove any nasty hacks to break out of /opt/fhir
	item=$(docker $TARGET_PREFIX exec $CONTAINER_NAME readlink -f $line_item)

	# And check it is a path within /opt/fhir
	if [[ $item == /opt/fhir/* ]]
	then
		target="$target_dir$item"
		docker $TARGET_PREFIX exec $CONTAINER_NAME mkdir -p $(dirname $target)
		docker $TARGET_PREFIX exec $CONTAINER_NAME mv $item $target
		let "moved += 1"
	        echo "Archived resource: $target"  >> $report_file
	else
		echo "ILLEGAL ITEM - IGNORING: $line_item"  >> $report_file
	fi
done

if [ "$moved" -gt "0" ]; then
   cat $report_file
   echo "$moved files moved to the archive - refreshing cache now..."
   echo
   source refreshCache.sh
else
   echo "No files removed!"
fi

