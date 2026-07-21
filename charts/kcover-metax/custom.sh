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
    "addon.kpanda.io/release-name": "kcover",
    "addon.kpanda.io/namespace": "kcover-system"
  }) |
  .name = "kcover-metax" |
  .keywords = (["kcover", "kcover-metax"] + (.keywords // []) | unique)
' Chart.yaml

yq e -i '
  .kcover.global.imageRegistry = "ghcr.m.daocloud.io" |
  .kcover.agent.image.registry = "ghcr.m.daocloud.io" |
  .kcover.agent.flavor = "metax" |
  .kcover.agent.image.repository = "baizeai/kcover-agent-metax" |
  .kcover.agent.image.tag = strenv(APP_VERSION) |
  .kcover.agent.nodeSelector = {"kubernetes.io/arch": "amd64"} |
  .kcover.controller.image.registry = "ghcr.m.daocloud.io" |
  .kcover.controller.image.tag = strenv(APP_VERSION) |
  .kcover.agent.resources = {
    "limits": {"cpu": "1", "memory": "1Gi"},
    "requests": {"cpu": "100m", "memory": "256Mi"}
  } |
  .kcover.controller.resources = {
    "limits": {"cpu": "1", "memory": "1Gi"},
    "requests": {"cpu": "100m", "memory": "256Mi"}
  }
' values.yaml

yq e -o=json -i '.properties.kcover.properties.agent.properties.flavor.default = "metax" | .properties.kcover.properties.agent.properties.flavor.enum = ["metax"]' values.schema.json
jq -c . values.schema.json > values.schema.json.tmp && mv values.schema.json.tmp values.schema.json

yq e -i '
  .agent.flavor = "metax" |
  .agent.image.registry = "ghcr.m.daocloud.io" |
  .agent.image.repository = "baizeai/kcover-agent-metax" |
  .agent.image.tag = strenv(APP_VERSION) |
  .agent.nodeSelector = {"kubernetes.io/arch": "amd64"}
' charts/kcover/values.yaml

yq e -o=json -i '.properties.agent.properties.flavor.default = "metax" | .properties.agent.properties.flavor.enum = ["metax"]' charts/kcover/values.schema.json
jq -c . charts/kcover/values.schema.json > charts/kcover/values.schema.json.tmp && mv charts/kcover/values.schema.json.tmp charts/kcover/values.schema.json
sed -i.bak -e 's/# Agent deployment flavor. Supported values: base, metax./# Agent deployment flavor for this MetaX chart. Only metax is supported./' -e '/# base uses the generic multi-arch agent image; metax uses the MetaX-specific agent image/d' -e '/# and enables MetaX-only host mounts./d' values.yaml charts/kcover/values.yaml
rm -f values.yaml.bak charts/kcover/values.yaml.bak
