#!/bin/bash

set -x
set -o errexit
set -o nounset
set -o pipefail

CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)
cd $CURRENT_DIR_PATH

# The operator image, published with the chart by DaoCloud/harbor-operator-lts.
IMAGE_REGISTRY=ghcr.m.daocloud.io
IMAGE_REPOSITORY=daocloud/harbor-operator-lts/harbor-operator
# Kangaroo deploys Harbor from release.daocloud.io/goharbor (online) or the offline registry.
HARBOR_REGISTRY=release.daocloud.io

rm -rf harbor-operator
helm pull "${REPO_URL}" --version "${VERSION}" --untar
ls -lh

# Kangaroo deploys the minio, redis and postgres operators itself. Helm loads every chart under
# charts/ even without a dependency entry, so drop the bundled sub-charts as well.
rm -rf harbor-operator/charts harbor-operator/Chart.lock
yq -i 'del(.dependencies)' harbor-operator/Chart.yaml

cp .relok8s-images.yaml ./harbor-operator/
for version in ${HARBOR_VERSIONS}; do
  for component in core nginx chartmuseum jobservice registryctl distribution portal trivy; do
    echo "- \"{{ .harbor.registry }}/{{ .harbor.${component}.repository }}:{{ .harbor.relok8sPlaceholder }}${version}\"" >> ./harbor-operator/.relok8s-images.yaml
  done
done

# sed -i.bak works with both GNU and BSD sed.
VALUES=harbor-operator/values.yaml
# image.registry / image.repository: the chart only has image.repository.
sed -i.bak -E "1,10s#^  repository: .*#  registry: ${IMAGE_REGISTRY}\\
  repository: ${IMAGE_REPOSITORY}#" ${VALUES}
grep -q "^  registry: ${IMAGE_REGISTRY}$" ${VALUES}
sed -i.bak "s/installCRDs: false/installCRDs: true/g" ${VALUES}
rm -f ${VALUES}.bak

# Harbor images: the operator does not read these values; they exist so that relok8s lists the
# Harbor images of every version in HARBOR_VERSIONS for offline packages.
echo "
harbor:
  registry: ${HARBOR_REGISTRY}
  versions: [$(echo ${HARBOR_VERSIONS} | sed 's/ /, /g')]
  # keep empty: lets relok8s resolve the per-version tags in .relok8s-images.yaml
  relok8sPlaceholder: \"\"
  core:
    repository: goharbor/harbor-core
  nginx:
     repository: goharbor/nginx-photon
  chartmuseum:
     repository: goharbor/chartmuseum-photon
  jobservice:
     repository: goharbor/harbor-jobservice
  registryctl:
     repository: goharbor/harbor-registryctl
  distribution:
     repository: goharbor/registry-photon
  portal:
     repository: goharbor/harbor-portal
  trivy:
     repository: goharbor/trivy-adapter-photon
" >> ${VALUES}

# Prefix the image with image.registry.
DEPLOYMENT=harbor-operator/templates/deployment.yaml
sed -i.bak "s/'{{.Values.image.repository}}:{{.Values.image.tag|default .Chart.AppVersion}}'/\"{{ .Values.image.registry }}\/{{.Values.image.repository}}:{{.Values.image.tag|default .Chart.AppVersion}}\"/g" ${DEPLOYMENT}
rm -f ${DEPLOYMENT}.bak
grep -q '{{ .Values.image.registry }}/' ${DEPLOYMENT}

rm -rf harbor-operator/README.md harbor-operator/README.md.gotmpl
cp ./parent/values.schema.json ./harbor-operator/values.schema.json

yq -i '
   .keywords = ["harbor-operator"] |
   .annotations["addon.kpanda.io/namespace"]="kangaroo-system" |
   .annotations["addon.kpanda.io/release-name"]="harbor-operator"
' harbor-operator/Chart.yaml
