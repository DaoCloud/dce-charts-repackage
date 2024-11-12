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

# add metrics config
cat <<EOF > charts/vela-core/templates/controller-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: kubevela-controller-service
  namespace: {{ .Release.Namespace }}
  labels:
    component: kubevela-controller
spec:
  ports:
    - name: http
      protocol: TCP
      port: 9443
      targetPort: 9443
    - name: metrics
      protocol: TCP
      port: 8080
      targetPort: 8080
  selector:
    {{- include "kubevela.selectorLabels" . | nindent 6 }}
EOF

cat <<EOF > charts/vela-core/templates/controller-service-monitor.yaml
{{- if and (.Capabilities.APIVersions.Has "monitoring.coreos.com/v1") .Values.multicluster.metrics.enabled -}}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: amamba-kubevela
  namespace: {{ .Release.Namespace }}
  labels:
      operator.insight.io/managed-by: insight
spec:
  endpoints:
    - honorLabels: true
      interval: 10s
      path: /metrics
      port: metrics
      scheme: http
  namespaceSelector:
    matchNames:
      - {{ .Release.Namespace }}
  selector:
    matchLabels:
      component: kubevela-controller
{{- end -}}
EOF

yq -i '.vela-core.multicluster.metrics.enabled=true' values.yaml

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
'>>charts/vela-core/templates/_helpers.tpl

yq -i '.keywords[0]="oam"' Chart.yaml

yq -i '
  .vela-core.image.registry = "docker.m.daocloud.io" |
  .vela-core.image.repository = "oamdev/vela-core" |
  .vela-core.multicluster.clusterGateway.image.registry = "docker.m.daocloud.io" |
  .vela-core.multicluster.clusterGateway.image.repository = "oamdev/cluster-gateway" |
  .vela-core.test.app.registry = "docker.m.daocloud.io" |
  .vela-core.test.app.repository = "oamdev/hello-world" |
  .vela-core.test.k8s.registry = "docker.m.daocloud.io" |
  .vela-core.test.k8s.repository = "oamdev/alpine-k8s" |
  .vela-core.admissionWebhooks.patch.image.registry = "docker.m.daocloud.io" |
  .vela-core.admissionWebhooks.patch.image.repository = "oamdev/kube-webhook-certgen"
' values.yaml

# add global images
originGlobalRepository=$(yq ".vela-core.image.repository" values.yaml)
originGlobalTag=$(yq ".vela-core.image.tag" values.yaml)
yq -i "
  .vela-core.global.imageRegistry=\"docker.m.daocloud.io\" |
  .vela-core.global.repository=\"${originGlobalRepository}\" |
  .vela-core.global.tag=\"${originGlobalTag}\"
" values.yaml

# set default values
yq -i "
  .vela-core.applicationRevisionLimit=10
" values.yaml

# remove test
rm -rf charts/vela-core/templates/test

if [ $os == "Darwin" ];then
  sed -i "" 's?{{ .Values.imageRegistry }}{{ .Values.image.repository }}:{{ .Values.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.image "global" .Values.global ) }}?g' charts/vela-core/templates/kubevela-controller.yaml
  sed -i "" 's?{{ .Values.imageRegistry }}{{ .Values.multicluster.clusterGateway.image.repository }}:{{ .Values.multicluster.clusterGateway.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.multicluster.clusterGateway.image "global" .Values.global ) }}?g' charts/vela-core/templates/cluster-gateway/cluster-gateway.yaml
  sed -i "" 's?{{ .Values.imageRegistry }}{{ .Values.multicluster.clusterGateway.image.repository }}:{{ .Values.multicluster.clusterGateway.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.multicluster.clusterGateway.image "global" .Values.global ) }}?g' charts/vela-core/templates/cluster-gateway/job-patch.yaml
  sed -i "" 's?{{ .Values.imageRegistry }}{{ .Values.admissionWebhooks.patch.image.repository }}:{{ .Values.admissionWebhooks.patch.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.admissionWebhooks.patch.image "global" .Values.global ) }}?g' charts/vela-core/templates/cluster-gateway/job-patch.yaml
  sed -i "" 's?{{ .Values.imageRegistry }}{{ .Values.admissionWebhooks.patch.image.repository }}:{{ .Values.admissionWebhooks.patch.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.admissionWebhooks.patch.image "global" .Values.global ) }}?g' charts/vela-core/templates/admission-webhooks/job-patch/job-createSecret.yaml
  sed -i "" 's?{{ .Values.imageRegistry }}{{ .Values.admissionWebhooks.patch.image.repository }}:{{ .Values.admissionWebhooks.patch.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.admissionWebhooks.patch.image "global" .Values.global ) }}?g' charts/vela-core/templates/admission-webhooks/job-patch/job-patchWebhook.yaml
elif [ $os == "Linux" ];then
  sed -i 's?{{ .Values.imageRegistry }}{{ .Values.image.repository }}:{{ .Values.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.image "global" .Values.global ) }}?g' charts/vela-core/templates/kubevela-controller.yaml
  sed -i 's?{{ .Values.imageRegistry }}{{ .Values.multicluster.clusterGateway.image.repository }}:{{ .Values.multicluster.clusterGateway.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.multicluster.clusterGateway.image "global" .Values.global ) }}?g' charts/vela-core/templates/cluster-gateway/cluster-gateway.yaml
  sed -i 's?{{ .Values.imageRegistry }}{{ .Values.multicluster.clusterGateway.image.repository }}:{{ .Values.multicluster.clusterGateway.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.multicluster.clusterGateway.image "global" .Values.global ) }}?g' charts/vela-core/templates/cluster-gateway/job-patch.yaml
  sed -i 's?{{ .Values.imageRegistry }}{{ .Values.admissionWebhooks.patch.image.repository }}:{{ .Values.admissionWebhooks.patch.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.admissionWebhooks.patch.image "global" .Values.global ) }}?g' charts/vela-core/templates/cluster-gateway/job-patch.yaml
  sed -i 's?{{ .Values.imageRegistry }}{{ .Values.admissionWebhooks.patch.image.repository }}:{{ .Values.admissionWebhooks.patch.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.admissionWebhooks.patch.image "global" .Values.global ) }}?g' charts/vela-core/templates/admission-webhooks/job-patch/job-createSecret.yaml
  sed -i 's?{{ .Values.imageRegistry }}{{ .Values.admissionWebhooks.patch.image.repository }}:{{ .Values.admissionWebhooks.patch.image.tag }}?{{ include "global.images.image" (dict "imageRoot" .Values.admissionWebhooks.patch.image "global" .Values.global ) }}?g' charts/vela-core/templates/admission-webhooks/job-patch/job-patchWebhook.yaml
fi
