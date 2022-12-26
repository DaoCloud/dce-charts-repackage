#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

set -x
set -o errexit
set -o pipefail
set -o nounset

#========================= add your customize bellow ====================

echo "keywords:" >> Chart.yaml
echo "- monitoring" >> Chart.yaml
echo "- security" >> Chart.yaml

echo "insert custom resources"
CUSTOM_CPU='180m'
CUSTOM_MEMORY='60Mi'

echo -e >> values.yaml
echo "  resources: " >> values.yaml
echo "    requests: " >> values.yaml
echo "      cpu: $CUSTOM_CPU" >> values.yaml
echo "      memory: $CUSTOM_MEMORY" >> values.yaml

sed -i -E 's?^name: event-generator?name: falco-event-generator?' Chart.yaml

sed -i 's?falcosecurity/event-generator?docker.m.daocloud.io/falcosecurity/event-generator?' values.yaml


#========================= add image registry for relok8s

sed -i '/repository:/ a\\    registry: docker.m.daocloud.io' values.yaml
sed -i '/repository:/ a\\  registry: docker.m.daocloud.io' charts/event-generator/values.yaml
sed -iE 's?repository: .*?repository: falcosecurity/event-generator?' values.yaml
sed -iE 's?repository: .*?repository: falcosecurity/event-generator?' charts/event-generator/values.yaml
sed -iE 's?image:.*?image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"?'  charts/event-generator/templates/pod-template.tpl

# remove temporary file
rm -f values.yamlE || true
rm -f charts/event-generator/values.yamlE || true
rm -f charts/event-generator/templates/pod-template.tplE || true