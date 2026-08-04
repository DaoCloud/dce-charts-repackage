#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

KIND_KUBECONFIG=${1:-}
CHART_VERSION=${3:-}
CHART_REF=chart-museum/dynamo-platform
NAMESPACE=dynamo-system

[ -f "${KIND_KUBECONFIG}" ] || { echo "error, failed to find kubeconfig ${KIND_KUBECONFIG}"; exit 1; }
[ -n "${CHART_VERSION}" ] || { echo "error, failed to find chart version (3rd arg)"; exit 1; }

echo "KIND_KUBECONFIG: ${KIND_KUBECONFIG}"
echo "CHART_REF: ${CHART_REF}"
echo "CHART_VERSION: ${CHART_VERSION}"

helm repo update chart-museum --kubeconfig "${KIND_KUBECONFIG}"

if helm install dynamo-platform "${CHART_REF}" \
  --version "${CHART_VERSION}" \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  --timeout 10m0s \
  --wait \
  --debug \
  --set dynamo-platform.global.nats.install=true \
  --kubeconfig "${KIND_KUBECONFIG}"; then
  echo "succeeded to deploy ${CHART_REF}"
  exit 0
fi

echo "error, failed to deploy ${CHART_REF}"
kubectl get all --namespace "${NAMESPACE}" --kubeconfig "${KIND_KUBECONFIG}" || true
kubectl get events --namespace "${NAMESPACE}" --sort-by=.lastTimestamp --kubeconfig "${KIND_KUBECONFIG}" || true
exit 1
