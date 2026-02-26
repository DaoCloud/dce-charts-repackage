#! /bin/bash

set -euo pipefail

if ! which helm-docs &>/dev/null ; then
    echo " 'helm-docs' no found, try to install..."
    wget https://github.com/norwoodj/helm-docs/releases/download/v1.11.0/helm-docs_1.11.0_Linux_x86_64.tar.gz -O /tmp/helm-docs_1.11.0_Linux_x86_64.tar.gz &&
     tar -xzf /tmp/helm-docs_1.11.0_Linux_x86_64.tar.gz -C /tmp &&
     mv /tmp/helm-docs /usr/local/bin/helm-docs
fi

CHART_BUILD_DIR=${1}
[ -n "${CHART_BUILD_DIR}" ] || { echo "error, empty CHART_BUILD_DIR" ; exit 1 ; }
[ -d "${CHART_BUILD_DIR}" ] || { echo "error, CHART_BUILD_DIR not found: ${CHART_BUILD_DIR}" ; exit 1 ; }

CURRENT_DIR_PATH=$(cd $(dirname "$0"); pwd)
PROJECT_ROOT_PATH=$( cd ${CURRENT_DIR_PATH}/../.. && pwd )

GATEWAY_API_CHART_SRC=${PROJECT_ROOT_PATH}/charts/gateway-api/gateway-api
[ -d "${GATEWAY_API_CHART_SRC}" ] || { echo "error, failed to find gateway-api chart: ${GATEWAY_API_CHART_SRC}" ; exit 1 ; }

mkdir -p "${CHART_BUILD_DIR}/charts"

rm -rf "${CHART_BUILD_DIR}/charts/gateway-api"
cp -R "${GATEWAY_API_CHART_SRC}" "${CHART_BUILD_DIR}/charts/gateway-api"

KGATEWAY_CRDS_OCI_REF="oci://cr.kgateway.dev/kgateway-dev/charts/kgateway-crds"
KGATEWAY_VERSION=$(yq -r '.dependencies[] | select(.name == "kgateway") | .version' "${CHART_BUILD_DIR}/Chart.yaml" 2>/dev/null || true)

if [ -z "${KGATEWAY_VERSION}" ] ; then
    KGATEWAY_VERSION=$(yq -r '.version' "${CHART_BUILD_DIR}/charts/kgateway/Chart.yaml" 2>/dev/null || true)
fi

rm -rf "${CHART_BUILD_DIR}/charts/kgateway-crds"
if [ -n "${KGATEWAY_VERSION}" ] ; then
    helm pull "${KGATEWAY_CRDS_OCI_REF}" --untar --untardir "${CHART_BUILD_DIR}/charts" --version "${KGATEWAY_VERSION}"
else
    helm pull "${KGATEWAY_CRDS_OCI_REF}" --untar --untardir "${CHART_BUILD_DIR}/charts"
fi

cd "${CHART_BUILD_DIR}"

GATEWAY_API_VERSION=$(yq -r '.version' "${CHART_BUILD_DIR}/charts/gateway-api/Chart.yaml")
KGATEWAY_CRDS_VERSION=$(yq -r '.version' "${CHART_BUILD_DIR}/charts/kgateway-crds/Chart.yaml")
KGATEWAY_CHILD_VERSION=$(yq -r '.version' "${CHART_BUILD_DIR}/charts/kgateway/Chart.yaml")

yq -i '.dependencies = [
  {"name": "gateway-api", "version": strenv(GATEWAY_API_VERSION), "repository": "file://charts/gateway-api", "condition": "installGatewayApiCrd"},
  {"name": "kgateway-crds", "version": strenv(KGATEWAY_CRDS_VERSION), "repository": "file://charts/kgateway-crds"},
  {"name": "kgateway", "version": strenv(KGATEWAY_CHILD_VERSION), "repository": "file://charts/kgateway"}
]' Chart.yaml

yq -i '.keywords = ["kubernetes", "networking", "api-gateway"]' Chart.yaml

export CHART_VERSION=$(yq -r '.version' Chart.yaml)
yq -i '
    .kgateway.image.tag=strenv(CHART_VERSION) |
    .kgateway.resources.requests.cpu="256mi" |
    .kgateway.resources.requests.memory="400Mi" |
    .kgateway.resources.limits.cpu="512mi" |
    .kgateway.resources.limits.memory="800Mi" |
    .installK8sGatewayAPI=false
' values.yaml

helm-docs
exit 0
