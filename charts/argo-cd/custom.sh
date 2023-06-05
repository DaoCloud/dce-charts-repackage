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
sysctlImageTag=$(yq .sysctlImage.tag charts/argo-cd/charts/redis-ha/values.yaml)
configmapImageTag=$(yq .configmapTest.image.tag charts/argo-cd/charts/redis-ha/values.yaml)
haproxyImageTag=$(yq .haproxy.image.tag charts/argo-cd/charts/redis-ha/values.yaml)
exporterImageTag=$(yq .exporter.tag charts/argo-cd/charts/redis-ha/values.yaml)
globalImageTag=$(yq .appVersion Chart.yaml)

yq -i '
  .argo-cd.global.image.registry = "quay.m.daocloud.io" |
  .argo-cd.global.image.repository = "argoproj/argocd" |
  .argo-cd.dex.image.registry = "ghcr.m.daocloud.io" |
  .argo-cd.dex.image.repository = "dexidp/dex" |
  .argo-cd.redis.image.registry = "docker.m.daocloud.io" |
  .argo-cd.redis.image.repository = "library/redis" |
  .argo-cd.redis.metrics.image.registry = "docker.m.daocloud.io" |
  .argo-cd.redis.metrics.image.repository = "bitnami/redis-exporter" |
  .argo-cd.redis-ha.image.registry = "docker.m.daocloud.io" |
  .argo-cd.redis-ha.image.repository = "library/redis" |
  .argo-cd.redis-ha.configmapTest.image.registry = "docker.m.daocloud.io" |
  .argo-cd.redis-ha.configmapTest.image.repository = "koalaman/shellcheck" |
  .argo-cd.redis-ha.haproxy.image.registry = "docker.m.daocloud.io" |
  .argo-cd.redis-ha.haproxy.image.repository = "library/haproxy" |
  .argo-cd.redis-ha.sysctlImage.image.registry = "docker.m.daocloud.io" |
  .argo-cd.redis-ha.sysctlImage.image.repository = "library/busybox" |
  .argo-cd.redis-ha.exporter.image.registry = "docker.m.daocloud.io" |
  .argo-cd.redis-ha.exporter.image.repository = "oliver006/redis_exporter"
' values.yaml

yq -i '.argo-cd.dex.resources = {"limits": {"cpu": "50m", "memory": "64Mi"}, "requests": {"cpu": "10m", "memory": "32Mi"}}' values.yaml
yq -i "
  .argo-cd.global.image.tag = \"${globalImageTag}\" |
  .argo-cd.redis-ha.configmapTest.image.tag = \"${configmapImageTag}\" |
  .argo-cd.redis-ha.haproxy.image.tag = \"${haproxyImageTag}\" |
  .argo-cd.redis-ha.sysctlImage.image.tag = \"${sysctlImageTag}\" |
  .argo-cd.redis-ha.exporter.image.tag = \"${exporterImageTag}\"
" values.yaml

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
