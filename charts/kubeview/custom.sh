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

echo "keywords:" >> Chart.yaml
echo "- hpa" >> Chart.yaml

if [ "$(uname)" == "Darwin" ];then
  sed  -i '' 's?"{{ .Values.image.repository }}:{{ .Values.image.tag }}"?"{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"?'   charts/kubeview/templates/deployment.yaml
  sed  -i '' 's?"{{ .Values.tests.image.repository }}:{{ .Values.tests.image.tag }}"?"{{ .Values.tests.image.registry }}/{{ .Values.tests.image.repository }}:{{ .Values.tests.image.tag }}"?'   charts/kubeview/templates/tests/pod.yaml
else
  sed  -i  's?"{{ .Values.image.repository }}:{{ .Values.image.tag }}"?"{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"?'   charts/kubeview/templates/deployment.yaml
  sed  -i  's?"{{ .Values.tests.image.repository }}:{{ .Values.tests.image.tag }}"?"{{ .Values.tests.image.registry }}/{{ .Values.tests.image.repository }}:{{ .Values.tests.image.tag }}"?'   charts/kubeview/templates/tests/pod.yaml
fi
