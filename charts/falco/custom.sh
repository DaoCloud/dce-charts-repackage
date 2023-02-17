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

yq -i ' .falco.image.registry = "docker.m.daocloud.io" ' values.yaml
yq -i ' .falco.falco.json_output = true ' values.yaml
yq -i ' .falco.driver.loader.initContainer.image.registry = "docker.m.daocloud.io" ' values.yaml

KICKAPP_VERSION=` cat charts/falco/charts/falcosidekick/Chart.yaml | grep appVersion | awk '{print $2}'`
yq -i ' .falco.falcosidekick.image.registry = "docker.m.daocloud.io" ' values.yaml
yq -i ' .falco.falcosidekick.image.repository = "falcosecurity/falcosidekick" ' values.yaml
yq -i " .falco.falcosidekick.image.tag = \"${KICKAPP_VERSION}\" " values.yaml

rm -f values.yamlE || true
rm -rf charts/falco/charts/falcosidekick/templates/tests
