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

# add deepflow-agent costume value
sed -i '18a\  registry: "docker.m.daocloud.io"' ./charts/deepflow-agent/values.yaml
sed -i '20c\  repository: deepflowce/deepflow-agent' ./charts/deepflow-agent/values.yaml

sed -i '49 c\        image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"' ./charts/deepflow-agent/templates/daemonset.yaml
sed -i '57 c\          image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"' ./charts/deepflow-agent/templates/daemonset.yaml
sed -i '39 c\          image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"' ./charts/deepflow-agent/templates/watcher-deployment.yaml