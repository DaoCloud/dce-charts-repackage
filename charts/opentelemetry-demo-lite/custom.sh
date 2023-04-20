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

# remove dep in opentelemetry-demo chart

rm -rf ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/ci
rm -rf ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/examples
rm -rf ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/grafana-dashboards
rm -rf ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/templates/grafana-dashboards.yaml
rm -rf ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/charts

if [ "$(uname)" == "Darwin" ];then
  sed -i '' '/dependencies/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.lock
  sed -i '' '/  repository/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.lock
  sed -i '' '/  version/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.lock
  sed -i '' '/- name:/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.lock

  sed -i '' '/dependencies/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '' '/- condition/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '' '/  repository/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '' '/  version: 0.52.1/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '' '/  version: 0.69.1/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '' '/  version: 20.2.0/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '' '/  version: 6.52.8/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '' '/  name: opentelemetry-collector/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '' '/  name: jaeger/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '' '/  name: prometheus/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '' '/  name: grafana/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
else
  sed -i '/dependencies/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.lock
  sed -i '/  repository/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.lock
  sed -i '/  version/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.lock
  sed -i '/- name:/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.lock

  sed -i '/dependencies/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '/- condition/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '/  repository/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '/  version: 0.52.1/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '/  version: 0.69.1/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '/  version: 20.2.0/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '/  version: 6.52.8/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '/  name: opentelemetry-collector/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '/  name: jaeger/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '/  name: prometheus/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
  sed -i '/  name: grafana/d' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/Chart.yaml
fi

# replace registry/repository:tag
if [ "$(uname)" == "Darwin" ];then
  sed  -i '' '1 i\
global: {}
' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/values.yaml
  sed  -i '' '2 i\
    {{- $config := set . "global" $.Values.global }}
' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/templates/component.yaml
  sed -i '' 's?{{ ((.imageOverride).repository) | default .defaultValues.image.repository }}?{{ .global.opentelemetryDemo.image.registry }}/{{ .global.opentelemetryDemo.image.repository }}?' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/templates/_objects.tpl
  sed -i '' 's?docker.m.daocloud.io/rancher/busybox:1.31.1?"{{ .global.opentelemetryDemo.busyboxImage.registry }}/{{ .global.opentelemetryDemo.busyboxImage.repository }}:{{ .global.opentelemetryDemo.busyboxImage.tag }}"?' ./charts/opentelemetry-demo-lite/values.yaml
else
  sed -i '1i\global: {}' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/values.yaml
  sed -i '2i\    {{- $config := set . "global" $.Values.global }}' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/templates/component.yaml
  sed -i 's?{{ ((.imageOverride).repository) | default .defaultValues.image.repository }}?{{ .global.opentelemetryDemo.image.registry }}/{{ .global.opentelemetryDemo.image.repository }}?' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/templates/_objects.tpl
  sed -i 's?docker.m.daocloud.io/rancher/busybox:1.31.1?"{{ .global.opentelemetryDemo.busyboxImage.registry }}/{{ .global.opentelemetryDemo.busyboxImage.repository }}:{{ .global.opentelemetryDemo.busyboxImage.tag }}"?' ./charts/opentelemetry-demo-lite/values.yaml
fi

# add istio label support https://github.com/open-telemetry/opentelemetry-helm-charts/pull/751
if [ "$(uname)" == "Darwin" ];then
  sed -i '' '16 i\
        sidecar.istio.io/inject: {{ printf "%t" .global.opentelemetryDemo.istioSidecar.enabled | squote }}
' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/templates/_objects.tpl
else
  sed -i '16i\        sidecar.istio.io/inject: {{ printf "%t" .global.opentelemetryDemo.istioSidecar.enabled | squote }}' ./charts/opentelemetry-demo-lite/charts/opentelemetry-demo/templates/_objects.tpl
fi