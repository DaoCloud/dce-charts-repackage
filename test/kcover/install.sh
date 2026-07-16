#!/bin/bash

set -Eeuo pipefail

CURRENT_DIR_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)
KIND_KUBECONFIG=${1:-}
CHART_VERSION=${3:-}
NAMESPACE=kcover-system
RELEASE=kcover

[ -f "${KIND_KUBECONFIG}" ] || { echo "error, failed to find kubeconfig ${KIND_KUBECONFIG}"; exit 1; }
[ -n "${CHART_VERSION}" ] || { echo "error, failed to find chart version"; exit 1; }

diagnostics() {
  local rc=${1:-1}

  trap - ERR
  set +e

  echo "kcover installation diagnostics"
  helm --kubeconfig "${KIND_KUBECONFIG}" -n "${NAMESPACE}" status "${RELEASE}"
  kubectl --kubeconfig "${KIND_KUBECONFIG}" -n "${NAMESPACE}" get all -o wide
  kubectl --kubeconfig "${KIND_KUBECONFIG}" -n "${NAMESPACE}" get events --sort-by=.lastTimestamp

  exit "${rc}"
}
trap 'diagnostics "$?"' ERR

echo "CURRENT_DIR_PATH: ${CURRENT_DIR_PATH}"
echo "KIND_KUBECONFIG: ${KIND_KUBECONFIG}"
echo "CHART_VERSION: ${CHART_VERSION}"
echo "helm version: $(helm version)"

helm repo update chart-museum --kubeconfig "${KIND_KUBECONFIG}"

if helm --kubeconfig "${KIND_KUBECONFIG}" -n "${NAMESPACE}" status "${RELEASE}" >/dev/null 2>&1; then
  helm --kubeconfig "${KIND_KUBECONFIG}" -n "${NAMESPACE}" uninstall "${RELEASE}"
fi

helm install "${RELEASE}" chart-museum/kcover \
  --version "${CHART_VERSION}" \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  --set kcover.agent.flavor=base \
  --timeout 10m0s \
  --wait \
  --debug \
  --kubeconfig "${KIND_KUBECONFIG}"

kubectl --kubeconfig "${KIND_KUBECONFIG}" -n "${NAMESPACE}" \
  rollout status deployment/kcover-controller --timeout=5m
kubectl --kubeconfig "${KIND_KUBECONFIG}" -n "${NAMESPACE}" \
  rollout status daemonset/kcover-agent --timeout=5m
helm --kubeconfig "${KIND_KUBECONFIG}" -n "${NAMESPACE}" status "${RELEASE}"

trap - ERR
echo "succeeded to deploy kcover"
