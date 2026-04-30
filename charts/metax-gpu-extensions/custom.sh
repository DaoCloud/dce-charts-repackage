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
rm -rf ${CURRENT_DIR_PATH}/metax-gpu-extensions
mkdir -p ${CURRENT_DIR_PATH}/metax-gpu-extensions
mkdir -p ${CURRENT_DIR_PATH}/metax-gpu-extensions/charts
tar -xzf ${CURRENT_DIR_PATH}/file/metax-gpu-extensions-0.14.2.tgz -C ${CURRENT_DIR_PATH}/metax-gpu-extensions/charts/

echo "copy parent files to metax-gpu-extensions"
cp -rf ${CURRENT_DIR_PATH}/parent/. ${CURRENT_DIR_PATH}/metax-gpu-extensions/

CHART_DIR="${CURRENT_DIR_PATH}/metax-gpu-extensions/charts/metax-gpu-extensions"

echo "inject image and resources blocks into subchart values.yaml (bottom-up to preserve line numbers)"
sed -i '78 a\  image:\n    registry: "cr.metax-tech.com"\n    repository: "cloud/gpu-aware"\n    tag: "0.14.2"\n    pullPolicy: IfNotPresent\n  resources:\n    limits:\n      cpu: 500m\n      memory: 512Mi\n    requests:\n      cpu: 100m\n      memory: 128Mi' ${CHART_DIR}/values.yaml
sed -i '73 a\    image:\n      registry: "cr.metax-tech.com"\n      repository: "cloud/topo-worker"\n      tag: "0.14.2"\n      pullPolicy: IfNotPresent\n    resources:\n      limits:\n        cpu: 500m\n        memory: 512Mi\n      requests:\n        cpu: 100m\n        memory: 128Mi' ${CHART_DIR}/values.yaml
sed -i '71 a\    image:\n      registry: "cr.metax-tech.com"\n      repository: "cloud/topo-master"\n      tag: "0.14.2"\n      pullPolicy: IfNotPresent\n    resources:\n      limits:\n        cpu: 500m\n        memory: 512Mi\n      requests:\n        cpu: 100m\n        memory: 128Mi' ${CHART_DIR}/values.yaml
sed -i '25 a\  image:\n    registry: "cr.metax-tech.com"\n    repository: "cloud/gpu-label"\n    tag: "0.14.2"\n    pullPolicy: IfNotPresent\n  resources:\n    limits:\n      cpu: 500m\n      memory: 512Mi\n    requests:\n      cpu: 100m\n      memory: 128Mi' ${CHART_DIR}/values.yaml
sed -i '22 a\  image:\n    registry: "cr.metax-tech.com"\n    repository: "cloud/gpu-device"\n    tag: "0.14.2"\n    pullPolicy: IfNotPresent\n  resources:\n    limits:\n      cpu: 500m\n      memory: 512Mi\n    requests:\n      cpu: 100m\n      memory: 128Mi' ${CHART_DIR}/values.yaml

echo "rewrite template image references to {registry}/{repository}:{tag} format"
sed -i 's|image: {{ .Values.registry }}/{{ include "GPUExt.deviceImage" . }}|image: "{{ .Values.gpuDevice.image.registry }}/{{ .Values.gpuDevice.image.repository }}:{{ .Values.gpuDevice.image.tag }}"|' ${CHART_DIR}/templates/gpudevice_daemonset.yaml
sed -i 's|image: {{ .Values.registry }}/{{ include "GPUExt.labelImage" . }}|image: "{{ .Values.gpuLabel.image.registry }}/{{ .Values.gpuLabel.image.repository }}:{{ .Values.gpuLabel.image.tag }}"|' ${CHART_DIR}/templates/gpulabel_daemonset.yaml
sed -i 's|image: {{ .Values.registry }}/{{ include "GPUExt.topoMasterImage" . }}|image: "{{ .Values.topoDiscovery.master.image.registry }}/{{ .Values.topoDiscovery.master.image.repository }}:{{ .Values.topoDiscovery.master.image.tag }}"|' ${CHART_DIR}/templates/topomaster_deployment.yaml
sed -i 's|image: {{ .Values.registry }}/{{ include "GPUExt.topoMasterImage" . }}|image: "{{ .Values.topoDiscovery.master.image.registry }}/{{ .Values.topoDiscovery.master.image.repository }}:{{ .Values.topoDiscovery.master.image.tag }}"|' ${CHART_DIR}/templates/topomaster_pre_delete_job.yaml
sed -i 's|image: {{ .Values.registry }}/{{ include "GPUExt.topoWorkerImage" . }}|image: "{{ .Values.topoDiscovery.worker.image.registry }}/{{ .Values.topoDiscovery.worker.image.repository }}:{{ .Values.topoDiscovery.worker.image.tag }}"|' ${CHART_DIR}/templates/topoworker_daemonset.yaml
sed -i 's|image: {{ .Values.registry }}/{{ include "GPUExt.gpuAwareImage" . }}|image: "{{ .Values.gpuAware.image.registry }}/{{ .Values.gpuAware.image.repository }}:{{ .Values.gpuAware.image.tag }}"|' ${CHART_DIR}/templates/extender_daemonset.yaml

echo "inject resources into gpudevice_daemonset.yaml"
sed -i '32 a\        {{- with .Values.gpuDevice.resources }}' ${CHART_DIR}/templates/gpudevice_daemonset.yaml
sed -i '33 a\        resources:' ${CHART_DIR}/templates/gpudevice_daemonset.yaml
sed -i '34 a\          {{- toYaml . | nindent 12 }}' ${CHART_DIR}/templates/gpudevice_daemonset.yaml
sed -i '35 a\        {{- end }}' ${CHART_DIR}/templates/gpudevice_daemonset.yaml

echo "inject resources into gpulabel_daemonset.yaml"
sed -i '30 a\        {{- with .Values.gpuLabel.resources }}' ${CHART_DIR}/templates/gpulabel_daemonset.yaml
sed -i '31 a\        resources:' ${CHART_DIR}/templates/gpulabel_daemonset.yaml
sed -i '32 a\          {{- toYaml . | nindent 12 }}' ${CHART_DIR}/templates/gpulabel_daemonset.yaml
sed -i '33 a\        {{- end }}' ${CHART_DIR}/templates/gpulabel_daemonset.yaml

echo "inject resources into topomaster_deployment.yaml"
sed -i '33 a\        {{- with .Values.topoDiscovery.master.resources }}' ${CHART_DIR}/templates/topomaster_deployment.yaml
sed -i '34 a\        resources:' ${CHART_DIR}/templates/topomaster_deployment.yaml
sed -i '35 a\          {{- toYaml . | nindent 12 }}' ${CHART_DIR}/templates/topomaster_deployment.yaml
sed -i '36 a\        {{- end }}' ${CHART_DIR}/templates/topomaster_deployment.yaml

echo "inject resources into topoworker_daemonset.yaml"
sed -i '30 a\        {{- with .Values.topoDiscovery.worker.resources }}' ${CHART_DIR}/templates/topoworker_daemonset.yaml
sed -i '31 a\        resources:' ${CHART_DIR}/templates/topoworker_daemonset.yaml
sed -i '32 a\          {{- toYaml . | nindent 12 }}' ${CHART_DIR}/templates/topoworker_daemonset.yaml
sed -i '33 a\        {{- end }}' ${CHART_DIR}/templates/topoworker_daemonset.yaml

echo "inject resources into extender_daemonset.yaml"
sed -i '35 a\        {{- with .Values.gpuAware.resources }}' ${CHART_DIR}/templates/extender_daemonset.yaml
sed -i '36 a\        resources:' ${CHART_DIR}/templates/extender_daemonset.yaml
sed -i '37 a\          {{- toYaml . | nindent 12 }}' ${CHART_DIR}/templates/extender_daemonset.yaml
sed -i '38 a\        {{- end }}' ${CHART_DIR}/templates/extender_daemonset.yaml
