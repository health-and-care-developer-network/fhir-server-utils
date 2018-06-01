#!/bin/bash

baseUrl=${1:-https://fhir.nhs.uk}

resourceTypes=("StructureDefinition" "ValueSet" "OperationDefinition" "STU3/StructureDefinition" "STU3/ValueSet" "STU3/OperationDefinition")

for resourceType in "${resourceTypes[@]}"
do
   echo "Count of resource type: $resourceType"
   curl $baseUrl/$resourceType?_count=1 2>/dev/null | grep -P 'total value=\"([0-9]*)\"' -o
done


