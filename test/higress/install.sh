#!/bin/bash

CURRENT_FILENAME=$(basename "$0")
CURRENT_DIR_PATH=$(cd "$(dirname "$0")" && pwd)

KIND_KUBECONFIG=$1
KIND_CLUSTER_NAME=${2:-}
CHART_VERSION=$3

[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG"; exit 1; }
[ -n "$CHART_VERSION" ] || { echo "error, failed to find chart version (3rd arg)"; exit 1; }

echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"
echo "KIND_CLUSTER_NAME: $KIND_CLUSTER_NAME"
echo "CHART_VERSION: $CHART_VERSION"

helm repo update chart-museum --kubeconfig "${KIND_KUBECONFIG}"

HELM_MUST_OPTION=" --version ${CHART_VERSION} --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

RELEASE_NAME=${RELEASE_NAME:-higress}
NAMESPACE=${NAMESPACE:-higress-system}

# ===== offline / relocation support =====
# If you already relocated images into a private registry, set GLOBAL_HUB to it.
# Example:
#   GLOBAL_HUB=my-registry.company.com
GLOBAL_HUB=${GLOBAL_HUB:-}

# ===== optional toggles for e2e testing =====
# Turn these on if you want to validate those components:
#   ENABLE_O11Y=true ENABLE_CERTMANAGER=true ENABLE_REDIS=true
ENABLE_O11Y=${ENABLE_O11Y:-false}
ENABLE_CERTMANAGER=${ENABLE_CERTMANAGER:-false}
ENABLE_REDIS=${ENABLE_REDIS:-false}

set -x

if ! kubectl --kubeconfig "${KIND_KUBECONFIG}" get ns "${NAMESPACE}" >/dev/null 2>&1; then
  kubectl --kubeconfig "${KIND_KUBECONFIG}" create ns "${NAMESPACE}"
fi

HELM_SET_ARGS=""
if [ -n "${GLOBAL_HUB}" ]; then
  HELM_SET_ARGS+=" --set global.hub=${GLOBAL_HUB} "
fi

if [ "${ENABLE_O11Y}" = "true" ]; then
  HELM_SET_ARGS+=" --set higress.higress-core.global.o11y.enabled=true "
  HELM_SET_ARGS+=" --set higress.higress-console.global.o11y.enabled=true "
fi

if [ "${ENABLE_CERTMANAGER}" = "true" ]; then
  HELM_SET_ARGS+=" --set higress.higress-console.certmanager.enabled=true "
fi

if [ "${ENABLE_REDIS}" = "true" ]; then
  HELM_SET_ARGS+=" --set higress.higress-core.global.enableRedis=true "
fi

helm upgrade --install "${RELEASE_NAME}" chart-museum/higress ${HELM_MUST_OPTION} --namespace "${NAMESPACE}" ${HELM_SET_ARGS}

if (($?==0)); then
  kubectl --kubeconfig "${KIND_KUBECONFIG}" get pod -n "${NAMESPACE}" -o wide
  exit 0
else
  echo "error, failed to deploy higress"
  kubectl --kubeconfig "${KIND_KUBECONFIG}" get pod -n "${NAMESPACE}" -o wide
  kubectl --kubeconfig "${KIND_KUBECONFIG}" get events -n "${NAMESPACE}" --sort-by=.lastTimestamp | tail -n 50 || true
  exit 1
fi