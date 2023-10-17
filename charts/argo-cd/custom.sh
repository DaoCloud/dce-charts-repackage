#!/bin/bash
set -x

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================
#===============================
os=$(uname)

os=$(uname)

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



#==============================
sysctlImageTag=$(yq .sysctlImage.tag charts/argo-cd/charts/redis-ha/values.yaml)
configmapImageTag=$(yq .configmapTest.image.tag charts/argo-cd/charts/redis-ha/values.yaml)
haproxyImageTag=$(yq .haproxy.image.tag charts/argo-cd/charts/redis-ha/values.yaml)
exporterImageTag=$(yq .exporter.tag charts/argo-cd/charts/redis-ha/values.yaml)
globalImageTag=$(yq .appVersion Chart.yaml)
redisTag=$(yq .redis.image.tag charts/argo-cd/values.yaml)


if [[ ${exporterImageTag:0:1} != "v" ]]; then
    exporterImageTag="v$exporterImageTag"
fi

redisTag=$(yq .redis.image.tag charts/argo-cd/values.yaml)
redisNewTag=${redisTag//-alpine/}

redisHaProxyTag=${haproxyImageTag//-alpine/}

yq -i '
  .argo-cd.global.image.registry = "quay.m.daocloud.io" |
  .argo-cd.global.image.repository = "argoproj/argocd" |
  .argo-cd.dex.image.registry = "ghcr.m.daocloud.io" |
  .argo-cd.dex.image.repository = "dexidp/dex" |
  .argo-cd.redis.image.registry = "docker.m.daocloud.io" |
  .argo-cd.redis.image.repository = "library/redis" |
  .argo-cd.redis.image.tag = "'${redisTag}'" |
  .argo-cd.redis.metrics.image.registry = "docker.m.daocloud.io" |
  .argo-cd.redis.metrics.image.repository = "oliver006/redis_exporter" |
  .argo-cd.redis.exporter.image.registry = "docker.m.daocloud.io" |
  .argo-cd.redis.exporter.image.repository = "oliver006/redis_exporter" |
  .argo-cd.redis.exporter.image.tag =  "'${exporterImageTag}'" |
  .argo-cd.redis-ha.image.registry = "docker.m.daocloud.io" |
  .argo-cd.redis-ha.image.repository = "library/redis" |
  .argo-cd.redis-ha.image.tag = "'${redisTag}'" |
  .argo-cd.redis-ha.configmapTest.image.registry = "docker.m.daocloud.io" |
  .argo-cd.redis-ha.configmapTest.image.repository = "koalaman/shellcheck" |
  .argo-cd.redis-ha.haproxy.image.registry = "docker.m.daocloud.io" |
  .argo-cd.redis-ha.haproxy.image.repository = "library/haproxy" |
  .argo-cd.redis-ha.haproxy.image.tag = "'${haproxyImageTag}'" |
  .argo-cd.redis-ha.sysctlImage.image.registry = "docker.m.daocloud.io" |
  .argo-cd.redis-ha.sysctlImage.image.repository = "library/busybox" |
  .argo-cd.redis-ha.exporter.image.registry = "docker.m.daocloud.io" |
  .argo-cd.redis-ha.exporter.image.repository = "oliver006/redis_exporter"
' values.yaml


# reset image to strut
yq -i 'del(.exporter.image)' charts/argo-cd/charts/redis-ha/values.yaml
yq -i "
  .exporter.image.registry = \"docker.m.daocloud.io\" |
  .exporter.image.repository = \"oliver006/redis_exporter\" |
  .exporter.image.tag = \"${exporterImageTag}\" |
  .image.registry = \"docker.m.daocloud.io\" |
  .haproxy.image.registry = \"docker.m.daocloud.io\"
" charts/argo-cd/charts/redis-ha/values.yaml

yq -i 'del(.redis-ha.exporter.image)' charts/argo-cd/values.yaml
yq -i "
  .redis-ha.exporter.image.registry = \"docker.m.daocloud.io\" |
  .redis-ha.exporter.image.repository = \"oliver006/redis_exporter\" |
  .redis-ha.exporter.image.tag = \"${exporterImageTag}\"
" charts/argo-cd/values.yaml

yq -i "
  .argo-cd.global.image.tag = \"${globalImageTag}\" |
  .argo-cd.redis-ha.configmapTest.image.tag = \"${configmapImageTag}\" |
  .argo-cd.redis-ha.sysctlImage.image.tag = \"${sysctlImageTag}\" |
  .argo-cd.redis-ha.exporter.image.tag = \"${exporterImageTag}\"
" values.yaml

yq -i 'del(.argo-cd.redis-ha.exporter.image)' values.yaml
yq -i "
  .argo-cd.redis-ha.exporter.image.registry = \"docker.m.daocloud.io\" |
  .argo-cd.redis-ha.exporter.image.repository = \"oliver006/redis_exporter\" |
  .argo-cd.redis-ha.exporter.image.tag = \"${exporterImageTag}\"
" values.yaml

# replace resources
yq -i '
  .argo-cd.controller.resources.requests.cpu = "100m" |
  .argo-cd.controller.resources.requests.memory = "256Mi" |
  .argo-cd.controller.resources.limits.cpu = "1000m" |
  .argo-cd.controller.resources.limits.memory = "1024Mi" |
  .argo-cd.dex.resources.requests.cpu = "100m" |
  .argo-cd.dex.resources.requests.memory = "256Mi" |
  .argo-cd.dex.resources.limits.cpu = "1000m" |
  .argo-cd.dex.resources.limits.memory = "1024Mi" |
  .argo-cd.redis.resources.requests.cpu = "100m" |
  .argo-cd.redis.resources.requests.memory = "256Mi" |
  .argo-cd.redis.resources.limits.cpu = "1000m" |
  .argo-cd.redis.resources.limits.memory = "1024Mi" |
  .argo-cd.server.resources.requests.cpu = "100m" |
  .argo-cd.server.resources.requests.memory = "256Mi" |
  .argo-cd.server.resources.limits.cpu = "1000m" |
  .argo-cd.server.resources.limits.memory = "1024Mi" |
  .argo-cd.repoServer.resources.requests.cpu = "100m" |
  .argo-cd.repoServer.resources.requests.memory = "256Mi" |
  .argo-cd.repoServer.resources.limits.cpu = "1000m" |
  .argo-cd.repoServer.resources.limits.memory = "1024Mi" |
  .argo-cd.applicationSet.resources.requests.cpu = "100m" |
  .argo-cd.applicationSet.resources.requests.memory = "256Mi" |
  .argo-cd.applicationSet.resources.limits.cpu = "1000m" |
  .argo-cd.applicationSet.resources.limits.memory = "1024Mi" |
  .argo-cd.notifications.resources.requests.cpu = "100m" |
  .argo-cd.notifications.resources.requests.memory = "256Mi" |
  .argo-cd.notifications.resources.limits.cpu = "1000m" |
  .argo-cd.notifications.resources.limits.memory = "1024Mi" |
  .argo-cd.redis-ha.exporter.resources.requests.cpu = "100m" |
  .argo-cd.redis-ha.exporter.resources.requests.memory = "256Mi" |
  .argo-cd.redis-ha.exporter.resources.limits.cpu = "1000m" |
  .argo-cd.redis-ha.exporter.resources.limits.memory = "1024Mi"
' values.yaml

# replace amamba rbac
yq -i '
  .argo-cd.configs.cm["accounts.amamba"]="apiKey" |
  .argo-cd.configs.rbac["policy.csv"]="g, amamba, role:admin" |
  .argo-cd.redis-ha.exporter.enabled=false
' values.yaml

# re-write global config.
originGlobalRegistry=$(yq ".argo-cd.global.image.registry" values.yaml)
originGlobalRepository=$(yq ".argo-cd.global.image.repository" values.yaml)
originGlobalTag=$(yq ".argo-cd.global.image.tag" values.yaml)

yq -i "
  .argo-cd.global.imageRegistry=\"${originGlobalRegistry}\" |
  .argo-cd.global.repository=\"${originGlobalRepository}\" |
  .argo-cd.global.tag=\"${originGlobalTag}\"
" values.yaml


echo '
{{- define "global.images.image" -}}
{{- $registryName := .imageRoot.registry -}}
{{- $repositoryName := .imageRoot.repository -}}
{{- $tag := .imageRoot.tag | toString -}}
{{- if .global }}
    {{- if .global.imageRegistry }}
     {{- $registryName = .global.imageRegistry -}}
    {{- end -}}
    {{- if and .global.repository (eq $repositoryName "") }}
     {{- $repositoryName = .global.repository -}}
    {{- end -}}
    {{- if and .global.tag (eq $tag "")}}
     {{- $tag = .global.tag -}}
    {{- end -}}
{{- end -}}
{{- if .tag }}
    {{- if .tag.imageTag }}
     {{- $tag = .tag.imageTag -}}
    {{- end -}}
{{- end -}}
{{- if $registryName }}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
{{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}
'>>charts/argo-cd/templates/_helpers.tpl

if [ $os == "Darwin" ];then
  sed -i "" 's?{{ default .Values.global.image.repository .Values.controller.image.repository }}:{{ default (include "argo-cd.defaultTag" .) .Values.controller.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.controller.image "global" .Values.global ) }}?g' charts/argo-cd/templates/argocd-application-controller/statefulset.yaml
  sed -i "" 's?{{ default .Values.global.image.repository .Values.applicationSet.image.repository }}:{{ default (include "argo-cd.defaultTag" .) .Values.applicationSet.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.applicationSet.image "global" .Values.global ) }}?g' charts/argo-cd/templates/argocd-applicationset/deployment.yaml
  sed -i "" 's?{{ default .Values.global.image.repository .Values.notifications.image.repository }}:{{ default (include "argo-cd.defaultTag" .) .Values.notifications.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.notifications.image "global" .Values.global ) }}?g' charts/argo-cd/templates/argocd-notifications/deployment.yaml
  sed -i "" 's?{{ default .Values.global.image.repository .Values.repoServer.image.repository }}:{{ default (include "argo-cd.defaultTag" .) .Values.repoServer.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.repoServer.image "global" .Values.global ) }}?g' charts/argo-cd/templates/argocd-repo-server/deployment.yaml
  sed -i "" 's?{{ default .Values.global.image.repository .Values.server.image.repository }}:{{ default (include "argo-cd.defaultTag" .) .Values.server.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.server.image "global" .Values.global ) }}?g' charts/argo-cd/templates/argocd-server/deployment.yaml
  sed -i "" 's?{{ default .Values.global.image.repository .Values.dex.initImage.repository }}:{{ default (include "argo-cd.defaultTag" .) .Values.dex.initImage.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.dex.initImage "global" .Values.global ) }}?g' charts/argo-cd/templates/dex/deployment.yaml
  sed -i "" 's?{{ .Values.dex.image.repository }}:{{ .Values.dex.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.dex.image "global" .Values.global ) }}?g' charts/argo-cd/templates/dex/deployment.yaml
  sed -i "" 's?{{ .Values.redis.image.repository }}:{{ .Values.redis.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.redis.image "global" .Values.global ) }}?g' charts/argo-cd/templates/redis/deployment.yaml
  sed -i "" 's?{{ .Values.redis.exporter.image.repository }}:{{ .Values.redis.exporter.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.redis.exporter.image "global" .Values.global ) }}?g' charts/argo-cd/templates/redis/deployment.yaml
  sed -i "" 's?{{ .Values.redis.metrics.image.repository }}:{{ .Values.redis.metrics.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.redis.metrics.image "global" .Values.global ) }}?g' charts/argo-cd/templates/redis/deployment.yaml
  sed -i "" 's?{{ .Values.image.repository }}:{{ .Values.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.image "global" .Values.global ) }}?g' charts/argo-cd/charts/redis-ha/templates/redis-ha-statefulset.yaml
  sed -i "" 's?"{{ .Values.exporter.image }}:{{ .Values.exporter.tag }}"?{{ include "global.images.image" (dict "imageRoot" .Values.exporter.image "global" .Values.global ) }}?g' charts/argo-cd/charts/redis-ha/templates/redis-ha-statefulset.yaml
  sed -i "" 's?{{ .Values.image.repository }}:{{ .Values.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.image "global" .Values.global ) }}?g' charts/argo-cd/charts/redis-ha/templates/tests/test-redis-ha-pod.yaml
  sed -i "" 's?{{ .Values.haproxy.image.repository }}:{{ .Values.haproxy.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.haproxy.image "global" .Values.global ) }}?g' charts/argo-cd/charts/redis-ha/templates/redis-haproxy-deployment.yaml
  sed -i "" 's?{{ .Values.configmapTest.image.repository }}:{{ .Values.configmapTest.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.configmapTest.image "global" .Values.global ) }}?g' charts/argo-cd/charts/redis-ha/templates/tests/test-redis-ha-configmap.yaml
  sed -i "" 's?.Values.sysctlImage.registry?.Values.sysctlImage.image.registry?g' charts/argo-cd/charts/redis-ha/templates/_helpers.tpl
  sed -i "" 's?.Values.sysctlImage.repository?.Values.sysctlImage.image.repository?g' charts/argo-cd/charts/redis-ha/templates/_helpers.tpl
elif [ $os == "Linux" ];then
  sed -i 's?{{ default .Values.global.image.repository .Values.controller.image.repository }}:{{ default (include "argo-cd.defaultTag" .) .Values.controller.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.controller.image "global" .Values.global ) }}?g' charts/argo-cd/templates/argocd-application-controller/statefulset.yaml
  sed -i 's?{{ default .Values.global.image.repository .Values.applicationSet.image.repository }}:{{ default (include "argo-cd.defaultTag" .) .Values.applicationSet.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.applicationSet.image "global" .Values.global ) }}?g' charts/argo-cd/templates/argocd-applicationset/deployment.yaml
  sed -i 's?{{ default .Values.global.image.repository .Values.notifications.image.repository }}:{{ default (include "argo-cd.defaultTag" .) .Values.notifications.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.notifications.image "global" .Values.global ) }}?g' charts/argo-cd/templates/argocd-notifications/deployment.yaml
  sed -i 's?{{ default .Values.global.image.repository .Values.repoServer.image.repository }}:{{ default (include "argo-cd.defaultTag" .) .Values.repoServer.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.repoServer.image "global" .Values.global ) }}?g' charts/argo-cd/templates/argocd-repo-server/deployment.yaml
  sed -i 's?{{ default .Values.global.image.repository .Values.server.image.repository }}:{{ default (include "argo-cd.defaultTag" .) .Values.server.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.server.image "global" .Values.global ) }}?g' charts/argo-cd/templates/argocd-server/deployment.yaml
  sed -i 's?{{ default .Values.global.image.repository .Values.dex.initImage.repository }}:{{ default (include "argo-cd.defaultTag" .) .Values.dex.initImage.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.dex.initImage "global" .Values.global ) }}?g' charts/argo-cd/templates/dex/deployment.yaml
  sed -i 's?{{ .Values.dex.image.repository }}:{{ .Values.dex.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.dex.image "global" .Values.global ) }}?g' charts/argo-cd/templates/dex/deployment.yaml
  sed -i 's?{{ .Values.redis.image.repository }}:{{ .Values.redis.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.redis.image "global" .Values.global ) }}?g' charts/argo-cd/templates/redis/deployment.yaml
  sed -i 's?{{ .Values.redis.exporter.image.repository }}:{{ .Values.redis.exporter.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.redis.exporter.image "global" .Values.global ) }}?g' charts/argo-cd/templates/redis/deployment.yaml
  sed -i 's?{{ .Values.redis.metrics.image.repository }}:{{ .Values.redis.metrics.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.redis.metrics.image "global" .Values.global ) }}?g' charts/argo-cd/templates/redis/deployment.yaml
  sed -i 's?{{ .Values.image.repository }}:{{ .Values.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.image "global" .Values.global ) }}?g' charts/argo-cd/charts/redis-ha/templates/redis-ha-statefulset.yaml
  sed -i 's?"{{ .Values.exporter.image }}:{{ .Values.exporter.tag }}"?{{ include "global.images.image" (dict "imageRoot" .Values.exporter.image "global" .Values.global ) }}?g' charts/argo-cd/charts/redis-ha/templates/redis-ha-statefulset.yaml
  sed -i 's?{{ .Values.image.repository }}:{{ .Values.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.image "global" .Values.global ) }}?g' charts/argo-cd/charts/redis-ha/templates/tests/test-redis-ha-pod.yaml
  sed -i 's?{{ .Values.haproxy.image.repository }}:{{ .Values.haproxy.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.haproxy.image "global" .Values.global ) }}?g' charts/argo-cd/charts/redis-ha/templates/redis-haproxy-deployment.yaml
  sed -i 's?{{ .Values.configmapTest.image.repository }}:{{ .Values.configmapTest.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.configmapTest.image "global" .Values.global ) }}?g' charts/argo-cd/charts/redis-ha/templates/tests/test-redis-ha-configmap.yaml
  sed -i 's?.Values.sysctlImage.registry?.Values.sysctlImage.image.registry?g' charts/argo-cd/charts/redis-ha/templates/_helpers.tpl
  sed -i 's?.Values.sysctlImage.repository?.Values.sysctlImage.image.repository?g' charts/argo-cd/charts/redis-ha/templates/_helpers.tpl
fi
