#!/bin/bash

CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

echo "custom shell: CHART_DIRECTORY $CURRENT_DIR_PATH"
echo "CHART_DIRECTORY $(ls $CURRENT_DIR_PATH)"

#========================= add your customize bellow ====================
#===============================

set -o errexit
set -o pipefail
set -o nounset

#==============================

echo "extract original chart from file/"
rm -rf ${CURRENT_DIR_PATH}/metax-exporter
mkdir -p ${CURRENT_DIR_PATH}/metax-exporter
mkdir -p ${CURRENT_DIR_PATH}/metax-exporter/charts
tar -xzf ${CURRENT_DIR_PATH}/file/mx-exporter-0.8.1.tgz -C ${CURRENT_DIR_PATH}/metax-exporter/charts/

echo "copy parent files to metax-exporter"
cp -rf ${CURRENT_DIR_PATH}/parent/. ${CURRENT_DIR_PATH}/metax-exporter/

CHART_DIR="${CURRENT_DIR_PATH}/metax-exporter/charts/mx-exporter"

sed -i '7a\  registry: "cr.metax-tech.com"' ${CHART_DIR}/values.yaml
sed -i '38 c\          image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"' ${CHART_DIR}/templates/daemonset.yaml

# inject resource limits into daemonset template
echo "inject resources into daemonset.yaml"
sed -i '76 a\          {{- with .Values.resources }}' ${CHART_DIR}/templates/daemonset.yaml
sed -i '77 a\          resources:' ${CHART_DIR}/templates/daemonset.yaml
sed -i '78 a\            {{- toYaml . | nindent 14 }}' ${CHART_DIR}/templates/daemonset.yaml
sed -i '79 a\          {{- end }}' ${CHART_DIR}/templates/daemonset.yaml
