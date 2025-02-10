#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

set -o errexit
set -o nounset

#========================= add your customize bellow ====================


#========= set tag for relok8s-images
export APP_VERSION=` cat Chart.yaml | grep appVersion | awk '{print $2}'`

# image
yq -i ' .topohub.image.registry = "ghcr.m.daocloud.io" ' values.yaml
yq -i ' .topohub.image.tag = env(APP_VERSION) ' values.yaml
yq -i ' .topohub.fileBrowser.image.registry = "docker.m.daocloud.io" ' values.yaml
#
yq -i ' .topohub.fileBrowser.enabled = true ' values.yaml

rm -rf values.yamlE || true 
