#!/bin/bash


INGORE_LIST="nmstate abc"

PROJECT_LIST="multus abc sriov spiderpool nmstate"
for PROJECT in ${PROJECT_LIST}; do
  grep ${PROJECT} <<< "${INGORE_LIST}" && echo "ingore: ${PROJECT}"
  # echo "handle: ${PROJECT}"
done
