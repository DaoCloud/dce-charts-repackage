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
os=$(uname)
echo $os
# set version value to $VERSION
echo $VERSION

nfdVersion=`yq '.appVersion' < ./charts/gpu-operator/charts/node-feature-discovery/Chart.yaml`
export nfdVersion=$nfdVersion

yq e '.image.registry="k8s.m.daocloud.io"' -i ./charts/gpu-operator/charts/node-feature-discovery/values.yaml
yq -i '.image.repository="nfd/node-feature-discovery"' ./charts/gpu-operator/charts/node-feature-discovery/values.yaml
yq e '.image.tag=env(nfdVersion)' -i ./charts/gpu-operator/charts/node-feature-discovery/values.yaml

# reset image value
#yq -i '.spec.template.spec.containers[0].image="{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"' -i ./charts/gpu-operator/charts/node-feature-discovery/templates/master.yaml
#yq -i '.spec.template.spec.containers[0].image="{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"' -i ./charts/gpu-operator/charts/node-feature-discovery/templates/worker.yaml
#yq -i '.spec.template.spec.containers[0].image="{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"' -i ./charts/gpu-operator/charts/node-feature-discovery/templates/topology-gc.yaml
#yq -i '.spec.template.spec.containers[0].image="{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"' -i ./charts/gpu-operator/charts/node-feature-discovery/templates/topologyupdater.yaml
if [ $os == "Darwin" ];then
   sed -i "" "s/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}/{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}/g" ./charts/gpu-operator/charts/node-feature-discovery/templates/master.yaml
   sed -i "" "s/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}/{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}/g" ./charts/gpu-operator/charts/node-feature-discovery/templates/worker.yaml
   sed -i "" "s/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}/{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}/g" ./charts/gpu-operator/charts/node-feature-discovery/templates/topology-gc.yaml
   sed -i "" "s/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}/{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}/g" ./charts/gpu-operator/charts/node-feature-discovery/templates/topologyupdater.yaml
elif [ $os == "Linux" ]; then
   sed -i  "s/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}/{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}/g" ./charts/gpu-operator/charts/node-feature-discovery/templates/master.yaml
   sed -i  "s/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}/{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}/g" ./charts/gpu-operator/charts/node-feature-discovery/templates/worker.yaml
   sed -i  "s/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}/{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}/g" ./charts/gpu-operator/charts/node-feature-discovery/templates/topology-gc.yaml
   sed -i  "s/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}/{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}/g" ./charts/gpu-operator/charts/node-feature-discovery/templates/topologyupdater.yaml
fi


yq e '.gpu-operator.node-feature-discovery.image.registry="k8s.m.daocloud.io"' -i values.yaml
yq e '.gpu-operator.node-feature-discovery.image.repository="nfd/node-feature-discovery"' -i values.yaml
yq e '.gpu-operator.node-feature-discovery.image.tag=env(nfdVersion)' -i values.yaml

yq e '.node-feature-discovery.image.registry="k8s.m.daocloud.io"' -i charts/gpu-operator/values.yaml
yq e '.node-feature-discovery.image.repository="nfd/node-feature-discovery"' -i charts/gpu-operator/values.yaml
yq e '.node-feature-discovery.image.tag=env(nfdVersion)' -i charts/gpu-operator/values.yaml

# set version
if [ $os == "Darwin" ];then
   sed -i "" "s/#version/version/g" values.yaml
   sed -i "" "s/#version/version/g" charts/gpu-operator/values.yaml
elif [ $os == "Linux" ]; then
    sed -i "s/#version/version/g" values.yaml
    sed -i "s/#version/version/g" charts/gpu-operator/values.yaml
fi

yq -i '
  .gpu-operator.validator.version=env(VERSION) |
  .gpu-operator.operator.version=env(VERSION) |
  .gpu-operator.nodeStatusExporter.version=env(VERSION)
' values.yaml

yq -i '
  .validator.version=env(VERSION) |
  .operator.version=env(VERSION) |
  .nodeStatusExporter.version=env(VERSION)
' charts/gpu-operator/values.yaml

# set default enabled value
yq -i '
    .gpu-operator.devicePlugin.enabled=false |
    .gpu-operator.migManager.enabled=false |
    .gpu-operator.vgpuDeviceManager.enabled=false |
    .gpu-operator.vfioManager.enabled=false |
    .gpu-operator.sandboxDevicePlugin.enabled=false
' values.yaml

yq -i '
    .devicePlugin.enabled=false |
    .migManager.enabled=false |
    .vgpuDeviceManager.enabled=false |
    .vfioManager.enabled=false |
    .sandboxDevicePlugin.enabled=false
' charts/gpu-operator/values.yaml

# set image
yq -i '
    .gpu-operator.toolkit.version="v1.13.4-centos7" |
    .gpu-operator.gds.version="2.16.1-ubuntu22.04" |
    .gpu-operator.driver.version="535.104.05"
' values.yaml

yq -i '
    .toolkit.version="v1.13.4-centos7" |
    .gds.version="2.16.1-ubuntu22.04" |
    .driver.version="535.104.05"
' charts/gpu-operator/values.yaml

# set serviceMonitor
yq -i '
    .gpu-operator.dcgmExporter.serviceMonitor.enabled=true |
    .gpu-operator.dcgmExporter.serviceMonitor.relabelings=[{"action":"replace","sourceLabels":["__meta_kubernetes_endpoint_node_name"],"targetLabel":"node"}]
' values.yaml

yq -i '
    .dcgmExporter.serviceMonitor.enabled=true |
    .dcgmExporter.serviceMonitor.relabelings=[{"action":"replace","sourceLabels":["__meta_kubernetes_endpoint_node_name"],"targetLabel":"node"}]
' charts/gpu-operator/values.yaml

# reset image registry and repository
yq -i '
  .gpu-operator.validator.repository="nvcr.io" |
  .gpu-operator.validator.image="nvidia/cloud-native/gpu-operator-validator" |
  .gpu-operator.operator.repository="nvcr.io" |
  .gpu-operator.operator.image="nvidia/gpu-operator" |
  .gpu-operator.operator.initContainer.repository="nvcr.io" |
  .gpu-operator.operator.initContainer.image="nvidia/cuda" |
  .gpu-operator.driver.repository="nvcr.io" |
  .gpu-operator.driver.image="nvidia/driver" |
  .gpu-operator.driver.manager.repository="nvcr.io" |
  .gpu-operator.driver.manager.image="nvidia/cloud-native/k8s-driver-manager" |
  .gpu-operator.toolkit.repository="nvcr.io" |
  .gpu-operator.toolkit.image="nvidia/k8s/container-toolkit" |
  .gpu-operator.devicePlugin.repository="nvcr.io" |
  .gpu-operator.devicePlugin.image="nvidia/k8s-device-plugin" |
  .gpu-operator.dcgm.repository="nvcr.io" |
  .gpu-operator.dcgm.image="nvidia/cloud-native/dcgm" |
  .gpu-operator.dcgmExporter.repository="nvcr.io" |
  .gpu-operator.dcgmExporter.image="nvidia/k8s/dcgm-exporter" |
  .gpu-operator.gfd.repository="nvcr.io" |
  .gpu-operator.gfd.image="nvidia/gpu-feature-discovery" |
  .gpu-operator.migManager.repository="nvcr.io" |
  .gpu-operator.migManager.image="nvidia/cloud-native/k8s-mig-manager" |
  .gpu-operator.nodeStatusExporter.repository="nvcr.io" |
  .gpu-operator.nodeStatusExporter.image="nvidia/cloud-native/gpu-operator-validator" |
  .gpu-operator.gds.repository="nvcr.io" |
  .gpu-operator.gds.image="nvidia/cloud-native/nvidia-fs" |
  .gpu-operator.vgpuDeviceManager.repository="nvcr.io" |
  .gpu-operator.vgpuDeviceManager.image="nvidia/cloud-native/vgpu-device-manager" |
  .gpu-operator.vfioManager.repository="nvcr.io" |
  .gpu-operator.vfioManager.image="nvidia/cuda" |
  .gpu-operator.kataManager.repository="nvcr.io" |
  .gpu-operator.kataManager.image="nvidia/cloud-native/k8s-kata-manager" |
  .gpu-operator.sandboxDevicePlugin.repository="nvcr.io" |
  .gpu-operator.sandboxDevicePlugin.image="nvidia/kubevirt-gpu-device-plugin" |
  .gpu-operator.ccManager.repository="nvcr.io" |
  .gpu-operator.ccManager.image="nvidia/cloud-native/k8s-cc-manager"
' values.yaml

yq -i '
  .validator.repository="nvcr.io" |
  .validator.image="nvidia/cloud-native/gpu-operator-validator" |
  .operator.repository="nvcr.io" |
  .operator.image="nvidia/gpu-operator" |
  .operator.initContainer.repository="nvcr.io" |
  .operator.initContainer.image="nvidia/cuda" |
  .driver.repository="nvcr.io" |
  .driver.image="nvidia/driver" |
  .driver.manager.repository="nvcr.io" |
  .driver.manager.image="nvidia/cloud-native/k8s-driver-manager" |
  .toolkit.repository="nvcr.io" |
  .toolkit.image="nvidia/k8s/container-toolkit" |
  .devicePlugin.repository="nvcr.io" |
  .devicePlugin.image="nvidia/k8s-device-plugin" |
  .dcgm.repository="nvcr.io" |
  .dcgm.image="nvidia/cloud-native/dcgm" |
  .dcgmExporter.repository="nvcr.io" |
  .dcgmExporter.image="nvidia/k8s/dcgm-exporter" |
  .gfd.repository="nvcr.io" |
  .gfd.image="nvidia/gpu-feature-discovery" |
  .migManager.repository="nvcr.io" |
  .migManager.image="nvidia/cloud-native/k8s-mig-manager" |
  .nodeStatusExporter.repository="nvcr.io" |
  .nodeStatusExporter.image="nvidia/cloud-native/gpu-operator-validator" |
  .gds.repository="nvcr.io" |
  .gds.image="nvidia/cloud-native/nvidia-fs" |
  .vgpuDeviceManager.repository="nvcr.io" |
  .vgpuDeviceManager.image="nvidia/cloud-native/vgpu-device-manager" |
  .vfioManager.repository="nvcr.io" |
  .vfioManager.image="nvidia/cuda" |
  .kataManager.repository="nvcr.io" |
  .kataManager.image="nvidia/cloud-native/k8s-kata-manager" |
  .sandboxDevicePlugin.repository="nvcr.io" |
  .sandboxDevicePlugin.image="nvidia/kubevirt-gpu-device-plugin" |
  .ccManager.repository="nvcr.io" |
  .ccManager.image="nvidia/cloud-native/k8s-cc-manager"
' charts/gpu-operator/values.yaml