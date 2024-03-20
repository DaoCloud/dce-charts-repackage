#!/bin/bash
set -x

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

os=$(uname)
echo $os

if ! which yq &>/dev/null ; then
    echo " 'yq' no found"
    if [ "$(uname)" == "Darwin" ];then
      exit 1
    fi
    echo "try to install..."
    YQ_VERSION=v4.30.6
    YQ_BINARY="yq_$(uname | tr 'A-Z' 'a-z')_amd64"
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O /tmp/yq.tar.gz &&
     tar -xzf /tmp/yq.tar.gz -C /tmp &&
     mv /tmp/${YQ_BINARY} /usr/bin/yq
fi

yq -i '
  .volcano.controller.image.registry = "docker.m.daocloud.io" |
  .volcano.controller.image.repository = "volcanosh/vc-controller-manager" |
  .volcano.controller.image.pullPolicy = "IfNotPresent" |
  .volcano.scheduler.image.registry = "docker.m.daocloud.io" |
  .volcano.scheduler.image.repository = "volcanosh/vc-scheduler" |
  .volcano.scheduler.image.pullPolicy = "IfNotPresent" |
  .volcano.admission.image.registry = "docker.m.daocloud.io" |
  .volcano.admission.image.repository = "volcanosh/vc-webhook-manager" |
  .volcano.admission.image.pullPolicy = "IfNotPresent" |
  .volcano.grafana.image.registry = "docker.m.daocloud.io" |
  .volcano.grafana.image.repository = "grafana/grafana" |
  .volcano.grafana.image.tag = "10.0.12" |
  .volcano.prometheus.image.registry = "docker.m.daocloud.io" |
  .volcano.prometheus.image.repository = "prom/prometheus" |
  .volcano.prometheus.image.tag = "v2.51.0" |
  .volcano.kubeStateMetrics.image.registry = "quay.m.daocloud.io" |
  .volcano.kubeStateMetrics.image.repository = "coreos/kube-state-metrics" |
  .volcano.kubeStateMetrics.image.tag = "v1.9.7" |
  .volcano.kubeStateMetrics.image.pullPolicy = "IfNotPresent"
' values.yaml

yq -i '
  .controller.image.registry = "docker.m.daocloud.io" |
  .controller.image.repository = "volcanosh/vc-controller-manager" |
  .controller.image.pullPolicy = "IfNotPresent" |
  .scheduler.image.registry = "docker.m.daocloud.io" |
  .scheduler.image.repository = "volcanosh/vc-scheduler" |
  .scheduler.image.pullPolicy = "IfNotPresent" |
  .admission.image.registry = "docker.m.daocloud.io" |
  .admission.image.repository = "volcanosh/vc-webhook-manager" |
  .admission.image.pullPolicy = "IfNotPresent" |
  .grafana.image.registry = "docker.m.daocloud.io" |
  .grafana.image.repository = "grafana/grafana" |
  .grafana.image.tag = "10.0.12" |
  .prometheus.image.registry = "docker.m.daocloud.io" |
  .prometheus.image.repository = "prom/prometheus" |
  .prometheus.image.tag = "v2.51.0" |
  .kubeStateMetrics.image.registry = "quay.m.daocloud.io" |
  .kubeStateMetrics.image.repository = "coreos/kube-state-metrics" |
  .kubeStateMetrics.image.tag = "v1.9.7" |
  .kubeStateMetrics.image.pullPolicy = "IfNotPresent"
' charts/volcano/values.yaml

# replace latest version with the accurate version for grafana and prometheus and kube-state-metrics.
tag=$(yq '.basic.image_tag_version' charts/volcano/values.yaml)
yq -i .volcano.controller.image.tag=\"$tag\" values.yaml
yq -i .volcano.scheduler.image.tag=\"$tag\" values.yaml
yq -i .volcano.admission.image.tag=\"$tag\" values.yaml
yq -i .controller.image.tag=\"$tag\" charts/volcano/values.yaml
yq -i .scheduler.image.tag=\"$tag\" charts/volcano/values.yaml
yq -i .admission.image.tag=\"$tag\" charts/volcano/values.yaml

if [ $os == "Darwin" ];then
  sed -i "" 's?{{.Values.basic.controller_image_name}}:{{.Values.basic.image_tag_version}}?{{ .Values.controller.image.registry }}/{{ .Values.controller.image.repository }}:{{.Values.controller.image.tag }}?g' charts/volcano/templates/controllers.yaml
  sed -i "" 's?{{ .Values.basic.image_pull_policy }}?{{ .Values.controller.image.pullPolicy }}?g' charts/volcano/templates/controllers.yaml

  sed -i "" 's?{{.Values.basic.scheduler_image_name}}:{{.Values.basic.image_tag_version}}?{{ .Values.scheduler.image.registry }}/{{ .Values.scheduler.image.repository }}:{{.Values.scheduler.image.tag }}?g' charts/volcano/templates/scheduler.yaml
  sed -i "" 's?{{ .Values.basic.image_pull_policy }}?{{ .Values.scheduler.image.pullPolicy }}?g' charts/volcano/templates/scheduler.yaml

  sed -i "" 's?{{.Values.basic.admission_image_name}}:{{.Values.basic.image_tag_version}}?{{ .Values.admission.image.registry }}/{{ .Values.admission.image.repository }}:{{.Values.admission.image.tag }}?g' charts/volcano/templates/admission.yaml
  sed -i "" 's?{{ .Values.basic.image_pull_policy }}?{{ .Values.admission.image.pullPolicy }}?g' charts/volcano/templates/admission.yaml

  sed -i "" 's?grafana/grafana:latest?{{ .Values.grafana.image.registry }}/{{ .Values.grafana.image.repository }}:{{.Values.grafana.image.tag }}?g' charts/volcano/templates/grafana.yaml

  sed -i "" 's?prom/prometheus?{{ .Values.prometheus.image.registry }}/{{ .Values.prometheus.image.repository }}:{{.Values.prometheus.image.tag }}?g' charts/volcano/templates/prometheus.yaml

  sed -i "" 's?quay.io/coreos/kube-state-metrics:v1.9.7?{{ .Values.kubeStateMetrics.image.registry }}/{{ .Values.kubeStateMetrics.image.repository }}:{{.Values.kubeStateMetrics.image.tag }}?g' charts/volcano/templates/kubestatemetrics.yaml
  sed -i "" 's?{{ .Values.basic.image_pull_policy }}?{{ .Values.kubeStateMetrics.image.pullPolicy }}?g' charts/volcano/templates/kubestatemetrics.yaml
elif [ $os == "Linux" ];then
  sed -i 's?{{.Values.basic.controller_image_name}}:{{.Values.basic.image_tag_version}}?{{ .Values.controller.image.registry }}/{{ .Values.controller.image.repository }}:{{.Values.controller.image.tag }}?g' charts/volcano/templates/controllers.yaml
  sed -i 's?{{ .Values.basic.image_pull_policy }}?{{ .Values.controller.image.pullPolicy }}?g' charts/volcano/templates/controllers.yaml

  sed -i 's?{{.Values.basic.scheduler_image_name}}:{{.Values.basic.image_tag_version}}?{{ .Values.scheduler.image.registry }}/{{ .Values.scheduler.image.repository }}:{{.Values.scheduler.image.tag }}?g' charts/volcano/templates/scheduler.yaml
  sed -i 's?{{ .Values.basic.image_pull_policy }}?{{ .Values.scheduler.image.pullPolicy }}?g' charts/volcano/templates/scheduler.yaml

  sed -i 's?{{.Values.basic.admission_image_name}}:{{.Values.basic.image_tag_version}}?{{ .Values.admission.image.registry }}/{{ .Values.admission.image.repository }}:{{.Values.admission.image.tag }}?g' charts/volcano/templates/admission.yaml
  sed -i 's?{{ .Values.basic.image_pull_policy }}?{{ .Values.admission.image.pullPolicy }}?g' charts/volcano/templates/admission.yaml

  sed -i 's?grafana/grafana:latest?{{ .Values.grafana.image.registry }}/{{ .Values.grafana.image.repository }}:{{.Values.grafana.image.tag }}?g' charts/volcano/templates/grafana.yaml
  
  sed -i 's?prom/prometheus?{{ .Values.prometheus.image.registry }}/{{ .Values.prometheus.image.repository }}:{{.Values.prometheus.image.tag }}?g' charts/volcano/templates/prometheus.yaml

  sed -i 's?quay.io/coreos/kube-state-metrics:v1.9.7?{{ .Values.kubeStateMetrics.image.registry }}/{{ .Values.kubeStateMetrics.image.repository }}:{{.Values.kubeStateMetrics.image.tag }}?g' charts/volcano/templates/kubestatemetrics.yaml
  sed -i 's?{{ .Values.basic.image_pull_policy }}?{{ .Values.kubeStateMetrics.image.pullPolicy }}?g' charts/volcano/templates/kubestatemetrics.yaml
fi

if ! grep "keywords:" Chart.yaml &>/dev/null ; then
    echo "keywords:" >> Chart.yaml
    echo "  - volcano" >> Chart.yaml
    echo "  - scheduler" >> Chart.yaml
fi

