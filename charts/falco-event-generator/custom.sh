#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================
set -o errexit
set -o pipefail
set -o nounset

echo "keywords:" >> Chart.yaml
echo "- monitoring" >> Chart.yaml
echo "- security" >> Chart.yaml

sed -i 's?falcosecurity/event-generator?docker.m.daocloud.io/falcosecurity/event-generator?' values.yaml

