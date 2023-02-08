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
APP_VERSION=` cat charts/falco/Chart.yaml | grep appVersion | awk '{print $2}'`
sed -iE "s?tag:.*?tag: ${APP_VERSION}?g" values.yaml

rm -f values.yamlE || true

grep "  registry:" ./charts/falco/charts/falcosidekick  -Rl   |xargs -n 1 -i sed -i 's?  registry: docker.io.*?  registry: docker.m.daocloud.io?' {}