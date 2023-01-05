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
  sed  -i '' 's?{{ .Values.admissionController.image.repository }}:{{ .Values.admissionController.image.tag?{{ .Values.admissionController.image.registry }}/{{ .Values.admissionController.image.repository }}:{{ .Values.admissionController.image.tag?'   charts/vpa/templates/admission-controller-deployment.yaml
  sed  -i '' 's?{{ .Values.recommender.image.repository }}:{{ .Values.recommender.image.tag?{{ .Values.recommender.image.registry }}/{{ .Values.recommender.image.repository }}:{{ .Values.recommender.image.tag?'  charts/vpa/templates/recommender-deployment.yaml
  sed  -i '' 's?{{ .Values.updater.image.repository }}:{{ .Values.updater.image.tag?{{ .Values.updater.image.registry }}/{{ .Values.updater.image.repository }}:{{ .Values.updater.image.tag?'   charts/vpa/templates/updater-deployment.yaml
  sed  -i '' 's?quay.io/reactiveops/ci-images:v11-alpine?release.daocloud.io/common-ci/common-ci-deployer:v0.1.52?'  charts/vpa/templates/tests/crd-available.yaml
  sed  -i '' 's?quay.io/reactiveops/ci-images:v11-alpine?release.daocloud.io/common-ci/common-ci-deployer:v0.1.52?'  charts/vpa/templates/tests/create-vpa.yaml
  sed  -i '' 's?quay.io/reactiveops/ci-images:v11-alpine?release.daocloud.io/common-ci/common-ci-deployer:v0.1.52?'  charts/vpa/templates/tests/metrics.yaml
else
  sed  -i  's?apk --update add openssl??'  charts/vpa/templates/admission-controller-certgen.yaml
  sed  -i  's?{{ .Values.admissionController.certGen.image.repository }}:{{ .Values.admissionController.certGen.image.tag?{{ .Values.admissionController.certGen.image.registry }}/{{ .Values.admissionController.certGen.image.repository }}:{{ .Values.admissionController.certGen.image.tag?'   charts/vpa/templates/admission-controller-certgen.yaml
  sed  -i  's?{{ .Values.admissionController.cleanupOnDelete.image.repository }}:{{ .Values.admissionController.cleanupOnDelete.image.tag?{{ .Values.admissionController.cleanupOnDelete.image.registry }}/{{ .Values.admissionController.cleanupOnDelete.image.repository }}:{{ .Values.admissionController.cleanupOnDelete.image.tag?'   charts/vpa/templates/admission-controller-cleanup.yaml
  sed  -i  's?{{ .Values.admissionController.image.repository }}:{{ .Values.admissionController.image.tag?{{ .Values.admissionController.image.registry }}/{{ .Values.admissionController.image.repository }}:{{ .Values.admissionController.image.tag?'   charts/vpa/templates/admission-controller-deployment.yaml
  sed  -i  's?{{ .Values.recommender.image.repository }}:{{ .Values.recommender.image.tag?{{ .Values.recommender.image.registry }}/{{ .Values.recommender.image.repository }}:{{ .Values.recommender.image.tag?'  charts/vpa/templates/recommender-deployment.yaml
  sed  -i  's?{{ .Values.updater.image.repository }}:{{ .Values.updater.image.tag?{{ .Values.updater.image.registry }}/{{ .Values.updater.image.repository }}:{{ .Values.updater.image.tag?' charts/vpa/templates/updater-deployment.yaml
  sed  -i  's?quay.io/reactiveops/ci-images:v11-alpine?release.daocloud.io/common-ci/common-ci-deployer:v0.1.52?'  charts/vpa/templates/tests/crd-available.yaml
  sed  -i  's?quay.io/reactiveops/ci-images:v11-alpine?release.daocloud.io/common-ci/common-ci-deployer:v0.1.52?'  charts/vpa/templates/tests/create-vpa.yaml
  sed  -i  's?quay.io/reactiveops/ci-images:v11-alpine?release.daocloud.io/common-ci/common-ci-deployer:v0.1.52?'  charts/vpa/templates/tests/metrics.yaml
fi

yq -i '
  .vpa.recommender.image.registry = "k8s.gcr.io" |
  .vpa.recommender.image.repository = "autoscaling/vpa-recommender" |
  .vpa.recommender.image.tag = "0.12.0" |
  .vpa.updater.image.registry = "k8s.gcr.io" |
  .vpa.updater.image.repository = "autoscaling/vpa-updater" |
  .vpa.updater.image.tag = "0.12.0" |
  .vpa.admissionController.enabled = true |
  .vpa.admissionController.image.registry = "k8s.gcr.io" |
  .vpa.admissionController.image.repository = "autoscaling/vpa-admission-controller" |
  .vpa.admissionController.image.tag = "0.12.0" |
  .vpa.admissionController.certGen.image.registry = "release.daocloud.io" |
  .vpa.admissionController.certGen.image.repository = "common-ci/common-ci-deployer" |
  .vpa.admissionController.certGen.image.tag = "v0.1.52" |
  .vpa.admissionController.cleanupOnDelete.image.registry = "release.daocloud.io" |
  .vpa.admissionController.cleanupOnDelete.image.repository = "common-ci/common-ci-deployer" |
  .vpa.admissionController.cleanupOnDelete.image.tag = "v0.1.52"
' values.yaml
