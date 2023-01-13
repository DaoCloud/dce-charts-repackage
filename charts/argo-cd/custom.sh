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

# remove redis-ha dependencies, https://github.com/DaoCloud/dce-charts-repackage/issues/510
sed -i "\?- condition: redis-ha.enabled?d" Chart.yaml
sed -i "\?name: redis-ha?d" Chart.yaml
sed -i "\?repository: https://dandydeveloper.github.io/charts/?d" Chart.yaml
sed -i "\?version: 4.22.4?d" Chart.yaml

#==============================

yq -i '
  .argo-cd.global.image.registry = "quay.io" |
  .argo-cd.global.image.repository = "argoproj/argocd" |
  .argo-cd.global.image.tag = "v2.5.5" |
  .argo-cd.dex.image.registry = "ghcr.io" |
  .argo-cd.dex.image.repository = "dexidp/dex" |
  .argo-cd.dex.image.tag = "v2.35.3" |
  .argo-cd.redis.image.registry = "public.ecr.aws" |
  .argo-cd.redis.image.repository = "docker/library/redis" |
  .argo-cd.redis.image.tag = "7.0.5-alpine" |
  .argo-cd.redis.metrics.image.registry = "public.ecr.aws" |
  .argo-cd.redis.metrics.image.repository = "bitnami/redis-exporter" |
  .argo-cd.redis.metrics.image.tag = "1.26.0-debian-10-r2" |
  .argo-cd.redis-ha.image.registry = "docker.io" |
  .argo-cd.redis-ha.image.repository = "redis" |
  .argo-cd.redis-ha.image.tag = "7.0.5-alpine3.16" |
  .argo-cd.redis-ha.configmapTest.image.registry = "koalaman" |
  .argo-cd.redis-ha.configmapTest.image.repository = "shellcheck" |
  .argo-cd.redis-ha.configmapTest.image.tag = "v0.5.0" |
  .argo-cd.redis-ha.haproxy.image.registry = "docker.io" |
  .argo-cd.redis-ha.haproxy.image.repository = "haproxy" |
  .argo-cd.redis-ha.haproxy.image.tag = "2.6.4" |
  .argo-cd.redis-ha.sysctlImage.image.registry = "docker.io" |
  .argo-cd.redis-ha.sysctlImage.image.repository = "busybox" |
  .argo-cd.redis-ha.sysctlImage.image.tag = "1.34.1" |
  .argo-cd.redis-ha.exporter.image.registry = "oliver006" |
  .argo-cd.redis-ha.exporter.image.repository = "redis_exporter" |
  .argo-cd.redis-ha.exporter.image.tag = "v1.43.0"
' values.yaml

echo '
{{- define "global.image.repository" -}}
{{- if and .Values.global.image.repository .Values.global.image.registry -}}
    {{- printf "%s/%s" .Values.global.image.registry  .Values.global.image.repository -}}
{{- else -}}
    {{- printf "%s" .Values.controller.image.repository -}}
{{- end -}}
{{- end -}}
'>>charts/argo-cd/templates/_helpers.tpl

sed  -i  's?.Values.global.image.repository?(include "global.image.repository" .)?g' charts/argo-cd/templates/argocd-application-controller/statefulset.yaml
sed  -i  's?.Values.global.image.repository?(include "global.image.repository" .)?g' charts/argo-cd/templates/argocd-applicationset/deployment.yaml
sed  -i  's?.Values.global.image.repository?(include "global.image.repository" .)?g' charts/argo-cd/templates/argocd-notifications/deployment.yaml
sed  -i  's?.Values.global.image.repository?(include "global.image.repository" .)?g' charts/argo-cd/templates/argocd-notifications/bots/slack/deployment.yaml
sed  -i  's?.Values.global.image.repository?(include "global.image.repository" .)?g' charts/argo-cd/templates/argocd-repo-server/deployment.yaml
sed  -i  's?.Values.global.image.repository?(include "global.image.repository" .)?g' charts/argo-cd/templates/argocd-server/deployment.yaml
sed  -i  's?.Values.global.image.repository?(include "global.image.repository" .)?g' charts/argo-cd/templates/dex/deployment.yaml

sed  -i  's?{{ .Values.dex.image.repository }}?{{ .Values.dex.image.registry }}/{{ .Values.dex.image.repository }}?g' charts/argo-cd/templates/dex/deployment.yaml
sed  -i  's?{{ .Values.redis.image.repository }}?{{ .Values.redis.image.registry }}/{{ .Values.redis.image.repository }}?g' charts/argo-cd/templates/redis/deployment.yaml
sed  -i  's?{{ .Values.redis.metrics.image.repository }}?{{ .Values.redis.metrics.image.registry }}/{{ .Values.redis.metrics.image.repository }}?g' charts/argo-cd/templates/redis/deployment.yaml

sed  -i  's?"{{ .Values.exporter.image }}:{{ .Values.exporter.tag }}"?"{{ .Values.exporter.image.registry }}/{{ .Values.exporter.image.repository }}:{{ .Values.exporter.image.tag }}"?g' charts/argo-cd/charts/redis-ha/templates/redis-ha-statefulset.yaml
sed  -i  's?{{ .Values.image.repository }}?{{ .Values.image.registry }}/{{ .Values.image.repository }}?g' charts/argo-cd/charts/redis-ha/templates/redis-ha-statefulset.yaml
sed  -i  's?{{ .Values.image.repository }}?{{ .Values.image.registry }}/{{ .Values.image.repository }}?g' charts/argo-cd/charts/redis-ha/templates/tests/test-redis-ha-pod.yaml
sed  -i  's?{{ .Values.haproxy.image.repository }}:{{ .Values.haproxy.image.tag }}?{{ .Values.haproxy.image.registry }}/{{ .Values.haproxy.image.repository }}:{{ .Values.haproxy.image.tag }}?g' charts/argo-cd/charts/redis-ha/templates/redis-haproxy-deployment.yaml
sed  -i  's?{{ .Values.configmapTest.image.repository }}:{{ .Values.configmapTest.image.tag }}?{{ .Values.configmapTest.image.registry }}/{{ .Values.configmapTest.image.repository }}:{{ .Values.configmapTest.image.tag }}?g' charts/argo-cd/charts/redis-ha/templates/tests/test-redis-ha-configmap.yaml

sed  -i  's?.Values.sysctlImage.registry?.Values.sysctlImage.image.registry?g' charts/argo-cd/charts/redis-ha/templates/_helpers.tpl
sed  -i  's?.Values.sysctlImage.repository?.Values.sysctlImage.image.repository?g' charts/argo-cd/charts/redis-ha/templates/_helpers.tpl
sed  -i  's?.Values.sysctlImage.tag?.Values.sysctlImage.image.tag?g' charts/argo-cd/charts/redis-ha/templates/_helpers.tpl
