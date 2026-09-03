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
ROUTER_CHART_DIR="${CHILD_CHART_DIR}/charts/router"
ROUTER_DEPLOYMENT_TEMPLATE="${ROUTER_CHART_DIR}/templates/_deployment.yaml"
ROUTER_LEADER_ELECTION_TEMPLATE="${ROUTER_CHART_DIR}/templates/_leader-election-rbac.yaml"

[ -f "${CHILD_CHART_DIR}/values.yaml" ] || {
  echo "custom shell: error, missing child values.yaml at ${CHILD_CHART_DIR}/values.yaml"
  exit 1
}
[ -f "${ROUTER_CHART_DIR}/values.yaml" ] || {
  echo "custom shell: error, missing router values.yaml at ${ROUTER_CHART_DIR}/values.yaml"
  exit 1
}
[ -f "${ROUTER_DEPLOYMENT_TEMPLATE}" ] || {
  echo "custom shell: error, missing router deployment template at ${ROUTER_DEPLOYMENT_TEMPLATE}"
  exit 1
}
[ -f "${ROUTER_LEADER_ELECTION_TEMPLATE}" ] || {
  echo "custom shell: error, missing router leader election template at ${ROUTER_LEADER_ELECTION_TEMPLATE}"
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
  .llm-d-router-gateway.router.epp.ha.enableLeaderElection = false |
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
  .router.epp.ha.enableLeaderElection = false |
  (.router.epp.image | select(.registry == "ghcr.io/llm-d" and (.repository | test("^llm-d/") | not))) |= (
    .registry = "ghcr.m.daocloud.io" |
    .repository = "llm-d/" + .repository
  ) |
  (.router.epp.image.registry | select(. == "ghcr.io/llm-d")) = "ghcr.m.daocloud.io" |
  (.router.latencyPredictor.trainingServer.image.registry | select(. == "ghcr.io/llm-d")) = "ghcr.m.daocloud.io/llm-d" |
  (.router.latencyPredictor.predictionServers.image.registry | select(. == "ghcr.io/llm-d")) = "ghcr.m.daocloud.io/llm-d"
' "${CHILD_CHART_DIR}/values.yaml"

if [ "$(uname)" = "Darwin" ]; then
  SED_INPLACE=(-i '')
else
  SED_INPLACE=(-i)
fi

# deployment strategy: make spec.strategy fully configurable from values
tmp_deployment_template=$(mktemp)
awk '
  /^  strategy:$/ && !patched {
    print "  strategy:"
    print "    {{- with .Values.router.epp.deploymentStrategy }}"
    print "    {{- toYaml . | nindent 4 }}"
    print "    {{- else }}"
    print "    # The current recommended EPP deployment pattern is to have a single active replica. This ensures"
    print "    # optimal performance of the stateful operations such prefix cache aware scorer."
    print "    # The Recreate strategy the old replica is killed immediately, and allow the new replica(s) to"
    print "    # quickly take over. This is particularly important in the high availability set up with leader"
    print "    # election, as the rolling update strategy would prevent the old leader being killed because"
    print "    # otherwise the maxUnavailable would be 100%."
    print "    #"
    print "    # With replicas > 1 this also means the Deployment never reports Available=True,"
    print "    # because standby replicas stay NotReady by design. Set router.epp.deploymentStrategy"
    print "    # if that blocks your tooling; see \"Multi-replica EPP and Helm --wait\" in the chart README."
    print "    type: Recreate"
    print "    {{- end }}"
    skipping = 1
    patched = 1
    next
  }
  skipping && /^  selector:$/ {
    skipping = 0
  }
  !skipping {
    print
  }
  END {
    if (!patched) {
      exit 42
    }
  }
' "${ROUTER_DEPLOYMENT_TEMPLATE}" > "${tmp_deployment_template}" || {
  rm -f "${tmp_deployment_template}"
  echo "custom shell: error, failed to patch router deployment strategy in ${ROUTER_DEPLOYMENT_TEMPLATE}"
  exit 1
}
mv "${tmp_deployment_template}" "${ROUTER_DEPLOYMENT_TEMPLATE}"

if ! grep -q '{{- with .Values.router.epp.deploymentStrategy }}' "${ROUTER_DEPLOYMENT_TEMPLATE}"; then
  echo "custom shell: error, failed to patch router deployment strategy in ${ROUTER_DEPLOYMENT_TEMPLATE}"
  exit 1
fi

# leader election: make --ha-enable-leader-election configurable from values instead of replica count
sed "${SED_INPLACE[@]}" \
  's/if and (gt (\.Values\.router\.epp\.replicas | int) 1) (not \$gkePB.enabled)/if and (.Values.router.epp.ha.enableLeaderElection | default false) (not $gkePB.enabled)/g' \
  "${ROUTER_DEPLOYMENT_TEMPLATE}"

sed "${SED_INPLACE[@]}" \
  's/if gt (\.Values\.router\.epp\.replicas | int) 1/if (.Values.router.epp.ha.enableLeaderElection | default false)/g' \
  "${ROUTER_LEADER_ELECTION_TEMPLATE}"

yq eval -i '.keywords |= ((. // []) + ["inference"] | unique)' Chart.yaml
