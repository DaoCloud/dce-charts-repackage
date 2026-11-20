#!/bin/bash

CHART_DIRECTORY=${1:-}
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd "$CHART_DIRECTORY"
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================
#===============================

set -o errexit
set -o pipefail
set -o nounset

#==============================
CHILD_CHART_DIR="./charts/llm-d-router-gateway"
HTTP_ROUTE_TEMPLATE="${CHILD_CHART_DIR}/templates/httproute.yaml"

[ -f "${CHILD_CHART_DIR}/values.yaml" ] || {
  echo "custom shell: error, missing child values.yaml at ${CHILD_CHART_DIR}/values.yaml"
  exit 1
}
[ -f "${HTTP_ROUTE_TEMPLATE}" ] || {
  echo "custom shell: error, missing HTTPRoute template at ${HTTP_ROUTE_TEMPLATE}"
  exit 1
}

yq eval -i '
  .llm-d-router-gateway.router.modelServers.matchLabels.app = "inferx" |
  .llm-d-router-gateway.router.epp.resources = {
    "requests": {
      "cpu": "1",
      "memory": "1Gi"
    },
    "limits": {
      "cpu": "1",
      "memory": "1Gi"
    }
  } |
  (.llm-d-router-gateway.router.epp.image | select(.registry == "ghcr.io/llm-d" and (.repository | test("^llm-d/") | not))) |= (
    .registry = "ghcr.m.daocloud.io" |
    .repository = "llm-d/" + .repository
  ) |
  (.llm-d-router-gateway.router.epp.image.registry | select(. == "ghcr.io/llm-d")) = "ghcr.m.daocloud.io" |
  (.llm-d-router-gateway.router.latencyPredictor.trainingServer.image.registry | select(. == "ghcr.io/llm-d")) = "ghcr.m.daocloud.io/llm-d" |
  (.llm-d-router-gateway.router.latencyPredictor.predictionServers.image.registry | select(. == "ghcr.io/llm-d")) = "ghcr.m.daocloud.io/llm-d"
' values.yaml

yq eval -i '
  .router.modelServers.matchLabels.app = "inferx" |
  .router.epp.resources = {
    "requests": {
      "cpu": "1",
      "memory": "1Gi"
    },
    "limits": {
      "cpu": "1",
      "memory": "1Gi"
    }
  } |
  (.router.epp.image | select(.registry == "ghcr.io/llm-d" and (.repository | test("^llm-d/") | not))) |= (
    .registry = "ghcr.m.daocloud.io" |
    .repository = "llm-d/" + .repository
  ) |
  (.router.epp.image.registry | select(. == "ghcr.io/llm-d")) = "ghcr.m.daocloud.io" |
  (.router.latencyPredictor.trainingServer.image.registry | select(. == "ghcr.io/llm-d")) = "ghcr.m.daocloud.io/llm-d" |
  (.router.latencyPredictor.predictionServers.image.registry | select(. == "ghcr.io/llm-d")) = "ghcr.m.daocloud.io/llm-d"
' "${CHILD_CHART_DIR}/values.yaml"

# HTTPRoute: set an explicit backend weight for the InferencePool reference
tmp_http_route_template=$(mktemp)
awk '
  pending_weight {
    if ($0 ~ /^      weight:/) {
      print "      weight: 1"
      pending_weight = 0
      next
    }
    print "      weight: 1"
    pending_weight = 0
  }
  {
    print
    if ($0 == "      name: {{ .Release.Name }}") {
      pending_weight = 1
      patched++
    }
  }
  END {
    if (pending_weight) {
      print "      weight: 1"
    }
    if (patched != 1) {
      exit 42
    }
  }
' "${HTTP_ROUTE_TEMPLATE}" > "${tmp_http_route_template}" || {
  rm -f "${tmp_http_route_template}"
  echo "custom shell: error, failed to add backend weight in ${HTTP_ROUTE_TEMPLATE}"
  exit 1
}
mv "${tmp_http_route_template}" "${HTTP_ROUTE_TEMPLATE}"

yq eval -i '.keywords |= ((. // []) + ["inference"] | unique)' Chart.yaml
