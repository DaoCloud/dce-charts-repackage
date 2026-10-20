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

# switch image registries to the daocloud mirrors
yq e -i '
  (.. | select(tag == "!!map" and .registry == "ghcr.io") | .registry) = "ghcr.m.daocloud.io" |
  (.. | select(tag == "!!map" and .registry == "docker.io") | .registry) = "docker.m.daocloud.io" |
  (.. | select(tag == "!!map" and .registry == "quay.io") | .registry) = "quay.m.daocloud.io" |
  (.. | select(tag == "!!map" and .registry == "docker.elastic.co") | .registry) = "elastic.m.daocloud.io" |
  .unifabric.controller.image.tag = strenv(APP_VERSION) |
  .unifabric.agent.image.tag = strenv(APP_VERSION) |
  .unifabric.grafanaInstance.image.tag = strenv(APP_VERSION) |
  .unifabric.grafanaDashboard.enabled = false |
  .unifabric.nodeMetrics.serviceMonitor.labels."operator.insight.io/managed-by" = "insight" |
  .unifabric.controller.serviceMonitor.labels."operator.insight.io/managed-by" = "insight" |
  .unifabric.ebpfFlowEventCollector.serviceMonitor.labels."operator.insight.io/managed-by" = "insight"
' values.yaml

# expose the external Elasticsearch endpoints as a fillable list in the UI form
yq e -o=json -i '
  .properties.unifabric.properties.ebpfFlowEventCollector.properties.elasticsearch.properties.endpoints.items = {"type": "string"}
' values.schema.json

# ClickHouse is not used, drop it from the UI form
yq e -o=json -i 'del(.properties.unifabric.properties.ebpfFlowEventCollector.properties.clickhouse)' values.schema.json
