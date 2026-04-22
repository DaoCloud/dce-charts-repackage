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
rm -rf ${CURRENT_DIR_PATH}/metax-operator
mkdir -p ${CURRENT_DIR_PATH}/metax-operator
mkdir -p ${CURRENT_DIR_PATH}/metax-operator/charts
tar -xzf ${CURRENT_DIR_PATH}/file/metax-operator-0.14.2.tgz -C ${CURRENT_DIR_PATH}/metax-operator/charts/

echo "copy parent files to metax-operator"
cp -rf ${CURRENT_DIR_PATH}/parent/. ${CURRENT_DIR_PATH}/metax-operator/

VALUES_FILE="${CURRENT_DIR_PATH}/metax-operator/charts/metax-operator/values.yaml"

echo "patch ${VALUES_FILE}"

yq -i "
  .registry = \"release.daocloud.io\" |
  .controller.image.name = \"metax/operator-controller\" |
  .controller.image.version = \"0.14.2\" |
  .gpuLabel.image.name = \"metax/gpu-label\" |
  .gpuLabel.image.version = \"0.14.2\" |
  .driver.image.name = \"metax/driver-manager\" |
  .driver.image.version = \"0.14.2\" |
  .driver.payload.name = \"metax/driver-image\" |
  .driver.payload.version = \"3.2.1.12-amd64\" |
  .maca.image.name = \"metax/driver-manager\" |
  .maca.image.version = \"0.14.2\" |
  del(.maca.payload.registry) |
  .maca.payload.images = {\"name\": \"metax/maca-native\", \"version\": \"3.2.1.4-ubuntu20.04-amd64\"} |
  .runtime.image.name = \"metax/container-runtime\" |
  .runtime.image.version = \"0.14.2\" |
  .gpuDevice.image.name = \"metax/gpu-device\" |
  .gpuDevice.image.version = \"0.14.2\" |
  .dataExporter.image.name = \"metax/mx-exporter\" |
  .dataExporter.image.version = \"0.14.2\" |
  .topoDiscovery.master.image.name = \"metax/topo-master\" |
  .topoDiscovery.master.image.version = \"0.14.2\" |
  .topoDiscovery.worker.image.name = \"metax/topo-worker\" |
  .topoDiscovery.worker.image.version = \"0.14.2\" |
  .gpuScheduler.kubeScheduler.image.registry = \"release.daocloud.io\" |
  .gpuScheduler.kubeScheduler.image.name = \"metax/kube-scheduler\" |
  .gpuScheduler.kubeScheduler.image.version = \"v1.28.2\" |
  .gpuScheduler.gpuAware.image.name = \"metax/gpu-aware\" |
  .gpuScheduler.gpuAware.image.version = \"0.14.2\"
" "${VALUES_FILE}"

# Cross-platform sed -i wrapper (BSD sed on macOS vs GNU sed on Linux)
if [ "$(uname)" = "Darwin" ]; then
  sedi() { sed -i '' "$@"; }
else
  sedi() { sed -i "$@"; }
fi

# Patch templates that can't adapt to the new values structure.
#
# clusteroperator.yaml: maca.payload.images was a string list iterated via
# {{- range }}, but the new values structure (mirroring parent/values.yaml
# and .relok8s-images.yaml, which doesn't support list addressing) defines
# maca.payload.images as a {name, version} map. Rewrite the range block to
# emit a single-entry list built from that map.
CLUSTER_OP_TPL="${CURRENT_DIR_PATH}/metax-operator/charts/metax-operator/templates/clusteroperator.yaml"
sedi '/{{- range \.Values\.maca\.payload\.images }}/,/{{- end }}/c\
      - {{ .Values.maca.payload.images.name }}:{{ .Values.maca.payload.images.version }}
' "${CLUSTER_OP_TPL}"
