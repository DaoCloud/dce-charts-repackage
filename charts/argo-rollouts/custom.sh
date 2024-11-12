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

# re-write global config.

defaultVersion=$(yq .appVersion Chart.yaml)
yq -i "
  .argo-rollouts.controller.image.registry = \"quay.m.daocloud.io\" |
  .argo-rollouts.controller.image.tag = \"${defaultVersion}\" |
  .argo-rollouts.dashboard.image.registry = \"quay.m.daocloud.io\" |
  .argo-rollouts.dashboard.image.tag = \"${defaultVersion}\" |
  .argo-rollouts.global.imageRegistry=\"quay.m.daocloud.io\" |
  .argo-rollouts.global.repository=\"argoproj/argo-rollouts\" |
  .argo-rollouts.global.tag = \"${defaultVersion}\"
" values.yaml

#==============================
os=$(uname)

yq -i '
  .argo-rollouts.controller.metrics.enabled = true |
  .argo-rollouts.controller.metrics.serviceMonitor.enabled = true |
  .argo-rollouts.controller.metrics.serviceMonitor.additionalLabels."operator.insight.io/managed-by" = "insight"
' values.yaml


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
'>>charts/argo-rollouts/templates/_helpers.tpl

if [ $os == "Darwin" ];then
  sed -i "" 's?"{{ .Values.controller.image.registry }}/{{ .Values.controller.image.repository }}:{{ default .Chart.AppVersion .Values.controller.image.tag }}"?{{ include "global.images.image" (dict "imageRoot" .Values.controller.image "global" .Values.global ) }}?g' charts/argo-rollouts/templates/controller/deployment.yaml
  sed -i "" 's?"{{ .Values.dashboard.image.registry }}/{{ .Values.dashboard.image.repository }}:{{ default .Chart.AppVersion .Values.dashboard.image.tag }}"?{{ include "global.images.image" (dict "imageRoot" .Values.dashboard.image "global" .Values.global ) }}?g' charts/argo-rollouts/templates/dashboard/deployment.yaml
elif [ $os == "Linux" ];then
  sed -i 's?"{{ .Values.controller.image.registry }}/{{ .Values.controller.image.repository }}:{{ default .Chart.AppVersion .Values.controller.image.tag }}"?{{ include "global.images.image" (dict "imageRoot" .Values.controller.image "global" .Values.global ) }}?g' charts/argo-rollouts/templates/controller/deployment.yaml
  sed -i 's?"{{ .Values.dashboard.image.registry }}/{{ .Values.dashboard.image.repository }}:{{ default .Chart.AppVersion .Values.dashboard.image.tag }}"?{{ include "global.images.image" (dict "imageRoot" .Values.dashboard.image "global" .Values.global ) }}?g' charts/argo-rollouts/templates/dashboard/deployment.yaml
fi
exit $?