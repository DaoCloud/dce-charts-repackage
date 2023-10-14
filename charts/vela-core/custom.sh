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
echo $os

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

echo '
  fluxcd:
    helm_controller:
      image:
        registry: fluxcd
        repository: helm-controller
        tag: v0.11.1
    image_automation_controller:
      image:
        registry: fluxcd
        repository: image-automation-controller
        tag: v0.14.0
    image_reflector_controller:
      image:
        registry: fluxcd
        repository: image-reflector-controller
        tag: v0.11.0
    kustomize_controller:
      image:
        registry: fluxcd
        repository: kustomize-controller
        tag: v0.13.1
    source_controller:
      image:
        registry: fluxcd
        repository: source-controller
        tag: v0.15.3
'>>values.yaml

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

yq -i '
  .keywords[0]="oam"
' Chart.yaml


if [ $os == "Darwin" ];then
  sed -i "" 's?{{ .Values.image.repository }}?{{ .Values.image.registry }}/{{ .Values.image.repository }}?g' charts/vela-core/templates/kubevela-controller.yaml
  sed -i "" 's?{{ .Values.multicluster.clusterGateway.image.repository }}?{{ .Values.multicluster.clusterGateway.image.registry }}/{{ .Values.multicluster.clusterGateway.image.repository }}?g' charts/vela-core/templates/cluster-gateway/cluster-gateway.yaml
  sed -i "" 's?{{ .Values.multicluster.clusterGateway.image.repository }}?{{ .Values.multicluster.clusterGateway.image.registry }}/{{ .Values.multicluster.clusterGateway.image.repository }}?g' charts/vela-core/templates/cluster-gateway/job-patch.yaml
  sed -i "" 's?{{ .Values.test.app.repository }}?{{ .Values.test.app.registry }}/{{ .Values.test.app.repository }}?g' charts/vela-core/templates/test/test-application.yaml
  sed -i "" 's?{{ .Values.test.k8s.repository }}?{{ .Values.test.k8s.registry }}/{{ .Values.test.k8s.repository }}?g' charts/vela-core/templates/test/test-application.yaml
  sed -i "" 's?{{ .Values.admissionWebhooks.patch.image.repository }}?{{ .Values.admissionWebhooks.patch.image.registry }}/{{ .Values.admissionWebhooks.patch.image.repository }}?g' charts/vela-core/templates/admission-webhooks/job-patch/job-createSecret.yaml
  sed -i "" 's?{{ .Values.admissionWebhooks.patch.image.repository }}?{{ .Values.admissionWebhooks.patch.image.registry }}/{{ .Values.admissionWebhooks.patch.image.repository }}?g' charts/vela-core/templates/admission-webhooks/job-patch/job-patchWebhook.yaml
  sed -i "" 's?{{ .Values.admissionWebhooks.patch.image.repository }}?{{ .Values.admissionWebhooks.patch.image.registry }}/{{ .Values.admissionWebhooks.patch.image.repository }}?g' charts/vela-core/templates/cluster-gateway/job-patch.yaml
  sed -i "" 's?fluxcd/helm-controller:v0.11.1?{{ .Values.fluxcd.helm_controller.image.registry }}/{{ .Values.fluxcd.helm_controller.image.repository }}:{{ .Values.fluxcd.helm_controller.image.tag }}?g' charts/vela-core/templates/addon/fluxcd.yaml
  sed -i "" 's?fluxcd/image-automation-controller:v0.14.0?{{ .Values.fluxcd.image_automation_controller.image.registry }}/{{ .Values.fluxcd.image_automation_controller.image.repository }}:{{ .Values.fluxcd.image_automation_controller.image.tag }}?g' charts/vela-core/templates/addon/fluxcd.yaml
  sed -i "" 's?fluxcd/image-reflector-controller:v0.11.0?{{ .Values.fluxcd.image_reflector_controller.image.registry }}/{{ .Values.fluxcd.image_reflector_controller.image.repository }}:{{ .Values.fluxcd.image_reflector_controller.image.tag }}?g' charts/vela-core/templates/addon/fluxcd.yaml
  sed -i "" 's?fluxcd/kustomize-controller:v0.13.1?{{ .Values.fluxcd.kustomize_controller.image.registry }}/{{ .Values.fluxcd.kustomize_controller.image.repository }}:{{ .Values.fluxcd.kustomize_controller.image.tag }}?g' charts/vela-core/templates/addon/fluxcd.yaml
  sed -i "" 's?fluxcd/fluxcd/source-controller:v0.15.3?{{ .Values.fluxcd.source_controller.image.registry }}/{{ .Values.fluxcd.source_controller.image.repository }}:{{ .Values.fluxcd.source_controller.image.tag }}?g' charts/vela-core/templates/addon/fluxcd.yaml
elif [ $os == "Linux" ];then
  sed -i 's?{{ .Values.image.repository }}?{{ .Values.image.registry }}/{{ .Values.image.repository }}?g' charts/vela-core/templates/kubevela-controller.yaml
  sed -i 's?{{ .Values.multicluster.clusterGateway.image.repository }}?{{ .Values.multicluster.clusterGateway.image.registry }}/{{ .Values.multicluster.clusterGateway.image.repository }}?g' charts/vela-core/templates/cluster-gateway/cluster-gateway.yaml
  sed -i 's?{{ .Values.multicluster.clusterGateway.image.repository }}?{{ .Values.multicluster.clusterGateway.image.registry }}/{{ .Values.multicluster.clusterGateway.image.repository }}?g' charts/vela-core/templates/cluster-gateway/job-patch.yaml
  sed -i 's?{{ .Values.test.app.repository }}?{{ .Values.test.app.registry }}/{{ .Values.test.app.repository }}?g' charts/vela-core/templates/test/test-application.yaml
  sed -i 's?{{ .Values.test.k8s.repository }}?{{ .Values.test.k8s.registry }}/{{ .Values.test.k8s.repository }}?g' charts/vela-core/templates/test/test-application.yaml
  sed -i 's?{{ .Values.admissionWebhooks.patch.image.repository }}?{{ .Values.admissionWebhooks.patch.image.registry }}/{{ .Values.admissionWebhooks.patch.image.repository }}?g' charts/vela-core/templates/admission-webhooks/job-patch/job-createSecret.yaml
  sed -i 's?{{ .Values.admissionWebhooks.patch.image.repository }}?{{ .Values.admissionWebhooks.patch.image.registry }}/{{ .Values.admissionWebhooks.patch.image.repository }}?g' charts/vela-core/templates/admission-webhooks/job-patch/job-patchWebhook.yaml
  sed -i 's?{{ .Values.admissionWebhooks.patch.image.repository }}?{{ .Values.admissionWebhooks.patch.image.registry }}/{{ .Values.admissionWebhooks.patch.image.repository }}?g' charts/vela-core/templates/cluster-gateway/job-patch.yaml
  sed -i 's?fluxcd/helm-controller:v0.11.1?{{ .Values.fluxcd.helm_controller.image.registry }}/{{ .Values.fluxcd.helm_controller.image.repository }}:{{ .Values.fluxcd.helm_controller.image.tag }}?g' charts/vela-core/templates/addon/fluxcd.yaml
  sed -i 's?fluxcd/image-automation-controller:v0.14.0?{{ .Values.fluxcd.image_automation_controller.image.registry }}/{{ .Values.fluxcd.image_automation_controller.image.repository }}:{{ .Values.fluxcd.image_automation_controller.image.tag }}?g' charts/vela-core/templates/addon/fluxcd.yaml
  sed -i 's?fluxcd/image-reflector-controller:v0.11.0?{{ .Values.fluxcd.image_reflector_controller.image.registry }}/{{ .Values.fluxcd.image_reflector_controller.image.repository }}:{{ .Values.fluxcd.image_reflector_controller.image.tag }}?g' charts/vela-core/templates/addon/fluxcd.yaml
  sed -i 's?fluxcd/kustomize-controller:v0.13.1?{{ .Values.fluxcd.kustomize_controller.image.registry }}/{{ .Values.fluxcd.kustomize_controller.image.repository }}:{{ .Values.fluxcd.kustomize_controller.image.tag }}?g' charts/vela-core/templates/addon/fluxcd.yaml
  sed -i 's?fluxcd/fluxcd/source-controller:v0.15.3?{{ .Values.fluxcd.source_controller.image.registry }}/{{ .Values.fluxcd.source_controller.image.repository }}:{{ .Values.fluxcd.source_controller.image.tag }}?g' charts/vela-core/templates/addon/fluxcd.yaml
fi

