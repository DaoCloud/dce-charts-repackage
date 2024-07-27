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

#==============================
if [ "$(uname)" == "Darwin" ];then
  sed -i '' 's?{{ include "vpa.test.image" . }}?{{ .Values.crdAvailable.image.registry }}/{{ .Values.crdAvailable.image.repository }}:{{ .Values.crdAvailable.image.tag }}?'  charts/vpa/templates/tests/crds-available.yaml
  sed -i '' 's?{{ include "vpa.test.image" . }}?{{ .Values.crdAvailable.image.registry }}/{{ .Values.crdAvailable.image.repository }}:{{ .Values.crdAvailable.image.tag }}?'  charts/vpa/templates/tests/webhook.yaml
  
  sed -i '' 's?{{ printf "%s:%s" .Values.admissionController.certGen.image.repository .Values.admissionController.certGen.image.tag?{{ .Values.admissionController.certGen.image.registry }}/{{ .Values.admissionController.certGen.image.repository }}:{{ .Values.admissionController.certGen.image.tag?' charts/vpa/templates/webhooks/jobs/certgen-create.yaml
  sed -i '' 's?{{ printf "%s:%s" .Values.admissionController.certGen.image.repository .Values.admissionController.certGen.image.tag?{{ .Values.admissionController.certGen.image.registry }}/{{ .Values.admissionController.certGen.image.repository }}:{{ .Values.admissionController.certGen.image.tag?' charts/vpa/templates/webhooks/jobs/certgen-patch.yaml
  sed -i '' 's?{{ printf "%s:%s" .Values.admissionController.image.repository (.Values.admissionController.image.tag | default .Chart.AppVersion) }}?{{ .Values.admissionController.image.registry }}/{{ .Values.admissionController.image.repository }}:{{ .Values.admissionController.image.tag }}?' charts/vpa/templates/admission-controller-deployment.yaml
  sed -i '' 's?{{ printf "%s:%s" .Values.recommender.image.repository (.Values.recommender.image.tag | default .Chart.AppVersion) }}?{{ .Values.recommender.image.registry }}/{{ .Values.recommender.image.repository }}:{{ .Values.recommender.image.tag }}?' charts/vpa/templates/recommender-deployment.yaml
  sed -i '' 's?{{ printf "%s:%s" .Values.updater.image.repository (.Values.updater.image.tag | default .Chart.AppVersion) }}?{{ .Values.updater.image.registry }}/{{ .Values.updater.image.repository }}:{{ .Values.updater.image.tag }}?' charts/vpa/templates/updater-deployment.yaml

  sed -i '' 's?{{ include "metrics-server.image" . }}?{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}?' charts/vpa/charts/metrics-server/templates/deployment.yaml
  sed -i '' 's?{{ include "metrics-server.addonResizer.image" . }}?{{ .Values.addonResizer.image.registry }}/{{ .Values.addonResizer.image.repository }}:{{ .Values.addonResizer.image.tag }}?' charts/vpa/charts/metrics-server/templates/deployment.yaml
  
else
  sed -i 's?{{ include "vpa.test.image" . }}?{{ .Values.crdAvailable.image.registry }}/{{ .Values.crdAvailable.image.repository }}:{{ .Values.crdAvailable.image.tag }}?'  charts/vpa/templates/tests/crds-available.yaml
  sed -i 's?{{ include "vpa.test.image" . }}?{{ .Values.crdAvailable.image.registry }}/{{ .Values.crdAvailable.image.repository }}:{{ .Values.crdAvailable.image.tag }}?'  charts/vpa/templates/tests/webhook.yaml
  
  sed -i 's?{{ printf "%s:%s" .Values.admissionController.certGen.image.repository .Values.admissionController.certGen.image.tag?{{ .Values.admissionController.certGen.image.registry }}/{{ .Values.admissionController.certGen.image.repository }}:{{ .Values.admissionController.certGen.image.tag?' charts/vpa/templates/webhooks/jobs/certgen-create.yaml
  sed -i 's?{{ printf "%s:%s" .Values.admissionController.certGen.image.repository .Values.admissionController.certGen.image.tag?{{ .Values.admissionController.certGen.image.registry }}/{{ .Values.admissionController.certGen.image.repository }}:{{ .Values.admissionController.certGen.image.tag?' charts/vpa/templates/webhooks/jobs/certgen-patch.yaml
  sed -i 's?{{ printf "%s:%s" .Values.admissionController.image.repository (.Values.admissionController.image.tag | default .Chart.AppVersion) }}?{{ .Values.admissionController.image.registry }}/{{ .Values.admissionController.image.repository }}:{{ .Values.admissionController.image.tag }}?' charts/vpa/templates/admission-controller-deployment.yaml
  sed -i 's?{{ printf "%s:%s" .Values.recommender.image.repository (.Values.recommender.image.tag | default .Chart.AppVersion) }}?{{ .Values.recommender.image.registry }}/{{ .Values.recommender.image.repository }}:{{ .Values.recommender.image.tag }}?' charts/vpa/templates/recommender-deployment.yaml
  sed -i 's?{{ printf "%s:%s" .Values.updater.image.repository (.Values.updater.image.tag | default .Chart.AppVersion) }}?{{ .Values.updater.image.registry }}/{{ .Values.updater.image.repository }}:{{ .Values.updater.image.tag }}?' charts/vpa/templates/updater-deployment.yaml

  sed -i 's?{{ include "metrics-server.image" . }}?{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}?' charts/vpa/charts/metrics-server/templates/deployment.yaml
  sed -i 's?{{ include "metrics-server.addonResizer.image" . }}?{{ .Values.addonResizer.image.registry }}/{{ .Values.addonResizer.image.repository }}:{{ .Values.addonResizer.image.tag }}?' charts/vpa/charts/metrics-server/templates/deployment.yaml

fi

yq -i '
  .vpa.kubeVersion = "" |
  .vpa.global.imageRegistry = "" |
  .vpa.global.vpa.imageTag = "1.0.0" |
  .vpa.crds.needcreate = true |
  .vpa.recommender.image.registry = "k8s.m.daocloud.io" |
  .vpa.recommender.image.repository = "autoscaling/vpa-recommender" |
  .vpa.recommender.image.tag = "1.0.0" |
  .vpa.recommender.image.oldTag = "0.9.0" |
  .vpa.updater.image.registry = "k8s.m.daocloud.io" |
  .vpa.updater.image.repository = "autoscaling/vpa-updater" |
  .vpa.updater.image.tag = "1.0.0" |
  .vpa.updater.image.oldTag = "0.9.0" |
  .vpa.admissionController.enabled = true |
  .vpa.admissionController.image.registry = "k8s.m.daocloud.io" |
  .vpa.admissionController.image.repository = "autoscaling/vpa-admission-controller" |
  .vpa.admissionController.image.tag = "1.0.0" |
  .vpa.admissionController.image.oldTag = "0.9.0" |
  .vpa.admissionController.certGen.image.registry = "k8s.m.daocloud.io" |
  .vpa.admissionController.certGen.image.repository = "ingress-nginx/kube-webhook-certgen" |
  .vpa.admissionController.certGen.image.tag = "v20230312-helm-chart-4.5.2-28-g66a760794" |
  .vpa.createVpa.image.registry = "release.daocloud.io" |
  .vpa.createVpa.image.repository = "common-ci/common-ci-deployer" |
  .vpa.createVpa.image.tag = "v0.1.52" |
  .vpa.metrics.image.registry = "release.daocloud.io" |
  .vpa.metrics.image.repository = "common-ci/common-ci-deployer" |
  .vpa.metrics.image.tag = "v0.1.52" |
  .vpa.metrics.image.tag = "v0.1.52" |
  .vpa.crdAvailable.image.registry = "release.daocloud.io" |
  .vpa.crdAvailable.image.repository = "common-ci/common-ci-deployer" |
  .vpa.crdAvailable.image.tag = "v0.1.52"
' values.yaml

yq -i '
   .annotations["addon.kpanda.io/namespace"]="kube-system" |
   .annotations["addon.kpanda.io/release-name"]="vpa"
' Chart.yaml


yq -i '
  .addonResizer.image.registry = "k8s.m.daocloud.io" |
  .addonResizer.image.repository = "autoscaling/addon-resizer"
'  charts/vpa/charts/metrics-server/values.yaml

yq -i '
  .image.registry = "k8s.m.daocloud.io" |
  .image.repository = "metrics-server/metrics-server" |
  .image.tag = "v0.6.4"
'  charts/vpa/charts/metrics-server/values.yaml

yq -i '.defaultArgs += ["--kubelet-insecure-tls"]' charts/vpa/charts/metrics-server/values.yaml

if ! grep "keywords:" Chart.yaml &>/dev/null ; then
    echo "keywords:" >> Chart.yaml
    echo "  - vpa" >> Chart.yaml
    echo "  - autoscale" >> Chart.yaml
fi

yq e '.vpa.metrics-server.image.registry="k8s.m.daocloud.io"' -i values.yaml
yq e '.vpa.metrics-server.image.repository="metrics-server/metrics-server"' -i values.yaml
yq e '.vpa.metrics-server.image.tag="v0.6.4"' -i values.yaml

yq e '.vpa.metrics-server.addonResizer.image.registry="k8s.m.daocloud.io"' -i values.yaml
yq e '.vpa.metrics-server.addonResizer.image.repository="autoscaling/addon-resizer"' -i values.yaml
yq e '.vpa.metrics-server.addonResizer.image.tag="1.8.19"' -i values.yaml


mv ./_commans.tpl ./charts/vpa/templates
mv ./_helpers.tpl ./charts/vpa/templates
mv ./crds.yaml ./charts/vpa/templates
mv ./vpa-v1beta1-crd.yaml ./charts/vpa/crds
mv ./crd-available.yaml ./charts/vpa/templates/tests
mv ./create-vpa.yaml ./charts/vpa/templates/tests
mv ./metrics.yaml ./charts/vpa/templates/tests
