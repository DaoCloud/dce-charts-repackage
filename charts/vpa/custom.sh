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
  sed  -i '' 's?apk --update add openssl??'  charts/vpa/templates/admission-controller-certgen.yaml
  sed  -i '' 's?{{ .Values.admissionController.certGen.image.repository }}:{{ .Values.admissionController.certGen.image.tag?{{ .Values.admissionController.certGen.image.registry }}/{{ .Values.admissionController.certGen.image.repository }}:{{ .Values.admissionController.certGen.image.tag?'  charts/vpa/templates/admission-controller-certgen.yaml
  sed  -i '' 's?{{ .Values.admissionController.cleanupOnDelete.image.repository }}:{{ .Values.admissionController.cleanupOnDelete.image.tag?{{ .Values.admissionController.cleanupOnDelete.image.registry }}/{{ .Values.admissionController.cleanupOnDelete.image.repository }}:{{ .Values.admissionController.cleanupOnDelete.image.tag?'  charts/vpa/templates/admission-controller-cleanup.yaml
  sed  -i '' 's?"{{ .Values.admissionController.image.repository }}:{{ .Values.admissionController.image.tag | default .Chart.AppVersion }}"?{{ template "admissionController.image" . }}?'   charts/vpa/templates/admission-controller-deployment.yaml
  sed  -i '' 's?"{{ .Values.recommender.image.repository }}:{{ .Values.recommender.image.tag | default .Chart.AppVersion }}"?{{ template "recommender.image" . }}?'  charts/vpa/templates/recommender-deployment.yaml
  sed  -i '' 's?"{{ .Values.updater.image.repository }}:{{ .Values.updater.image.tag | default .Chart.AppVersion }}"?{{ template "updater.image" . }}?'   charts/vpa/templates/updater-deployment.yaml
  sed  -i '' 's?quay.io/reactiveops/ci-images:v11-alpine?release.daocloud.io/common-ci/common-ci-deployer:v0.1.52?'  charts/vpa/templates/tests/crd-available.yaml
  sed  -i '' 's?quay.io/reactiveops/ci-images:v11-alpine?release.daocloud.io/common-ci/common-ci-deployer:v0.1.52?'  charts/vpa/templates/tests/create-vpa.yaml
  sed  -i '' 's?quay.io/reactiveops/ci-images:v11-alpine?release.daocloud.io/common-ci/common-ci-deployer:v0.1.52?'  charts/vpa/templates/tests/metrics.yaml
else
  sed  -i  's?apk --update add openssl??'  charts/vpa/templates/admission-controller-certgen.yaml
  sed  -i  's?{{ .Values.admissionController.certGen.image.repository }}:{{ .Values.admissionController.certGen.image.tag?{{ .Values.admissionController.certGen.image.registry }}/{{ .Values.admissionController.certGen.image.repository }}:{{ .Values.admissionController.certGen.image.tag?'   charts/vpa/templates/admission-controller-certgen.yaml
  sed  -i  's?{{ .Values.admissionController.cleanupOnDelete.image.repository }}:{{ .Values.admissionController.cleanupOnDelete.image.tag?{{ .Values.admissionController.cleanupOnDelete.image.registry }}/{{ .Values.admissionController.cleanupOnDelete.image.repository }}:{{ .Values.admissionController.cleanupOnDelete.image.tag?'   charts/vpa/templates/admission-controller-cleanup.yaml
  sed  -i  's?"{{ .Values.admissionController.image.repository }}:{{ .Values.admissionController.image.tag | default .Chart.AppVersion }}"?{{ template "admissionController.image" . }}?'   charts/vpa/templates/admission-controller-deployment.yaml
  sed  -i  's?"{{ .Values.recommender.image.repository }}:{{ .Values.recommender.image.tag | default .Chart.AppVersion }}"?{{ template "recommender.image" . }}?'  charts/vpa/templates/recommender-deployment.yaml
  sed  -i  's?"{{ .Values.updater.image.repository }}:{{ .Values.updater.image.tag | default .Chart.AppVersion }}"?{{ template "updater.image" . }}?' charts/vpa/templates/updater-deployment.yaml
  sed  -i  's?quay.io/reactiveops/ci-images:v11-alpine?release.daocloud.io/common-ci/common-ci-deployer:v0.1.52?'  charts/vpa/templates/tests/crd-available.yaml
  sed  -i  's?quay.io/reactiveops/ci-images:v11-alpine?release.daocloud.io/common-ci/common-ci-deployer:v0.1.52?'  charts/vpa/templates/tests/create-vpa.yaml
  sed  -i  's?quay.io/reactiveops/ci-images:v11-alpine?release.daocloud.io/common-ci/common-ci-deployer:v0.1.52?'  charts/vpa/templates/tests/metrics.yaml
fi

yq -i '
  .vpa.kubeVersion = "" |
  .vpa.global.imageRegistry = "" |
  .vpa.global.vpa.imageTag = "0.12.0" |
  .vpa.crds.needcreate = true |
  .vpa.recommender.image.registry = "release.daocloud.io" |
  .vpa.recommender.image.repository = "autoscaling/vpa-recommender" |
  .vpa.recommender.image.tag = "0.12.0" |
  .vpa.recommender.image.oldTag = "0.9.0" |
  .vpa.updater.image.registry = "release.daocloud.io" |
  .vpa.updater.image.repository = "autoscaling/vpa-updater" |
  .vpa.updater.image.tag = "0.12.0" |
  .vpa.updater.image.oldTag = "0.9.0" |
  .vpa.admissionController.enabled = true |
  .vpa.admissionController.image.registry = "release.daocloud.io" |
  .vpa.admissionController.image.repository = "autoscaling/vpa-admission-controller" |
  .vpa.admissionController.image.tag = "0.12.0" |
  .vpa.admissionController.image.oldTag = "0.9.0" |
  .vpa.admissionController.certGen.image.registry = "release.daocloud.io" |
  .vpa.admissionController.certGen.image.repository = "common-ci/common-ci-deployer" |
  .vpa.admissionController.certGen.image.tag = "v0.1.52" |
  .vpa.createVpa.image.registry = "release.daocloud.io" |
  .vpa.createVpa.image.repository = "common-ci/common-ci-deployer" |
  .vpa.createVpa.image.tag = "v0.1.52" |
  .vpa.metrics.image.registry = "release.daocloud.io" |
  .vpa.metrics.image.repository = "common-ci/common-ci-deployer" |
  .vpa.metrics.image.tag = "v0.1.52" |
  .vpa.metrics.image.tag = "v0.1.52" |
  .vpa.crdAvailable.image.registry = "release.daocloud.io" |
  .vpa.crdAvailable.image.repository = "common-ci/common-ci-deployer" |
  .vpa.crdAvailable.image.tag = "v0.1.52" |
  .vpa.admissionController.cleanupOnDelete.image.registry = "release.daocloud.io" |
  .vpa.admissionController.cleanupOnDelete.image.repository = "common-ci/common-ci-deployer" |
  .vpa.admissionController.cleanupOnDelete.image.tag = "v0.1.52"
' values.yaml

yq -i '
   .annotations["addon.kpanda.io/namespace"]="kube-system" |
   .annotations["addon.kpanda.io/release-name"]="vpa"
' Chart.yaml

if ! grep "keywords:" Chart.yaml &>/dev/null ; then
    echo "keywords:" >> Chart.yaml
    echo "  - vpa" >> Chart.yaml
    echo "  - autoscale" >> Chart.yaml
fi


mv ./_commans.tpl ./charts/vpa/templates
mv ./_helpers.tpl ./charts/vpa/templates
mv ./crds.yaml ./charts/vpa/templates
mv ./vpa-v1beta1-crd.yaml ./charts/vpa/crds
mv ./crd-available.yaml ./charts/vpa/templates/tests
mv ./create-vpa.yaml ./charts/vpa/templates/tests
mv ./metrics.yaml ./charts/vpa/templates/tests
