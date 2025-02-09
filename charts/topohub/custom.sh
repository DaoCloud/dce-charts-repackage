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
APP_VERSION=` cat Chart.yaml | grep appVersion | awk '{print $2}'`

sed -iE "s?tag:.*?tag: v${APP_VERSION}?g" values.yaml
yq -i ' .topohub.image.registry = "ghcr.m.daocloud.io" ' values.yaml
yq -i ' .topohub.httpServer.image.registry = "ghcr.m.daocloud.io" ' values.yaml
yq -i ' .topohub.httpServer.enabled = true ' values.yaml

rm -rf values.yamlE || true 
