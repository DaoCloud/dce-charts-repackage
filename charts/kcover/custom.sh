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
  .keywords = (["kcover"] + (.keywords // []) | unique)
' Chart.yaml

yq e -i '
  .kcover.global.imageRegistry = "ghcr.m.daocloud.io" |
  .kcover.agent.image.registry = "ghcr.m.daocloud.io" |
  .kcover.agent.image.tag = strenv(APP_VERSION) |
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
