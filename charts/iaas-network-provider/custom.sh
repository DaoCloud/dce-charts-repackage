#! /bin/bash

set -euo pipefail

CHART_BUILD_DIR=${1}
[ -n "${CHART_BUILD_DIR}" ] || { echo "error, empty CHART_BUILD_DIR" ; exit 1 ; }
[ -d "${CHART_BUILD_DIR}" ] || { echo "error, CHART_BUILD_DIR not found: ${CHART_BUILD_DIR}" ; exit 1 ; }

cd "${CHART_BUILD_DIR}"

if ! which helm-docs &>/dev/null ; then
  echo " 'helm-docs' no found, try to install..."
  wget https://github.com/norwoodj/helm-docs/releases/download/v1.11.0/helm-docs_1.11.0_Linux_x86_64.tar.gz -O /tmp/helm-docs_1.11.0_Linux_x86_64.tar.gz
  tar -xzf /tmp/helm-docs_1.11.0_Linux_x86_64.tar.gz -C /tmp
  mv /tmp/helm-docs /usr/local/bin/helm-docs
fi

export CHART_VERSION=$(yq -r '.version' Chart.yaml)
yq -i '
  ."iaas-network-provider".image.registry="ghcr.m.daocloud.io" |
  ."iaas-network-provider".image.tag="'v${CHART_VERSION}'"
' values.yaml

yq -i '.keywords = ["kubernetes", "networking", "ipam", "iaas"]' Chart.yaml

helm-docs
