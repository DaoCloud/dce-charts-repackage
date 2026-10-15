#!/bin/bash

set -euo pipefail

CHART_DIRECTORY=${1:-}
[ -n "${CHART_DIRECTORY}" ] || { echo "custom shell: error, empty CHART_DIRECTORY"; exit 1; }
[ -d "${CHART_DIRECTORY}" ] || { echo "custom shell: error, missing CHART_DIRECTORY ${CHART_DIRECTORY}"; exit 1; }

cd "${CHART_DIRECTORY}"
echo "custom shell: CHART_DIRECTORY ${CHART_DIRECTORY}"

export APP_VERSION
APP_VERSION=$(yq e '.appVersion' Chart.yaml)
[ -n "${APP_VERSION}" ] && [ "${APP_VERSION}" != "null" ] \
  || { echo "custom shell: error, missing appVersion in Chart.yaml"; exit 1; }

yq e -i '
  .annotations |= ((. // {}) + {
    "addon.kpanda.io/release-name": "unifabric",
    "addon.kpanda.io/namespace": "unifabric-system"
  }) |
  .keywords = (["unifabric", "rdma", "lldp", "topology"] + (.keywords // []) | unique)
' Chart.yaml

# the upstream schema is nested under "unifabric", so local $ref pointers must follow
sed -i 's|"#/definitions/|"#/properties/unifabric/definitions/|g' values.schema.json

# switch image registries to the daocloud mirrors
yq e -i '
  (.. | select(tag == "!!map" and .registry == "ghcr.io") | .registry) = "ghcr.m.daocloud.io" |
  (.. | select(tag == "!!map" and .registry == "docker.io") | .registry) = "docker.m.daocloud.io" |
  (.. | select(tag == "!!map" and .registry == "quay.io") | .registry) = "quay.m.daocloud.io" |
  (.. | select(tag == "!!map" and .registry == "docker.elastic.co") | .registry) = "elastic.m.daocloud.io" |
  .unifabric.controller.image.tag = strenv(APP_VERSION) |
  .unifabric.agent.image.tag = strenv(APP_VERSION) |
  .unifabric.grafanaInstance.image.tag = strenv(APP_VERSION)
' values.yaml
