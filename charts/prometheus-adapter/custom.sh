#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================
#===============================

set -o errexit
set -o pipefail
set -o nounset

#==============================
image=$(yq '.prometheus-adapter.image.repository' values.yaml)
repository=$(echo ${image} | cut -d'/' -f 2-)
yq -i .prometheus-adapter.image.repository=\"$repository\"  values.yaml

yq -i '.prometheus-adapter.image.registry="k8s.m.daocloud.io"'  values.yaml
yq -i '.prometheus-adapter.prometheus.url="http://insight-agent-kube-prometh-prometheus.insight-system.svc"'  values.yaml

tag=$(yq  '.appVersion' Chart.yaml)
yq -i .prometheus-adapter.image.tag=\"$tag\"  values.yaml

sed -i '/resources: {}/,/^\s*$/{/^\s*$/!s/#/ /g}' values.yaml
sed -i 's/resources: {}/resources: /g' values.yaml

yq -i '
  .prometheus-adapter.resources.requests.cpu = "1" |
  .prometheus-adapter.resources.requests.memory = "1Gi" |
  .prometheus-adapter.resources.limits.cpu = "1" |
  .prometheus-adapter.resources.limits.memory = "1Gi"
' values.yaml

sed  -i  's?"{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"?"{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"?'   charts/prometheus-adapter/templates/deployment.yaml
