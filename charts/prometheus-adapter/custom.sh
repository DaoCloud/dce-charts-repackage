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

sed -i '/resources: {}/,/^\s*$/{/^\s*$/!s/#/ /g}' values.yaml
sed -i 's/resources: {}/resources: /g' values.yaml

if [ "$(uname)" == "Darwin" ];then
  sed  -i '' 's?"{{ .Values.image.repository }}:{{ .Values.image.tag }}"?"{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"?'   charts/prometheus-adapter/templates/deployment.yaml
else
  sed  -i  's?"{{ .Values.image.repository }}:{{ .Values.image.tag }}"?"{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"?'   charts/prometheus-adapter/templates/deployment.yaml
fi
