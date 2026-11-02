#!/bin/bash
set -euo pipefail

KIND_KUBECONFIG=${1:?missing kubeconfig}
CHART_VERSION=${3:?missing chart version}
[ -f "$KIND_KUBECONFIG" ] || { echo "error, kubeconfig not found: $KIND_KUBECONFIG"; exit 1; }

NAMESPACE=topograph
RELEASE=topograph

# The default "test" provider replays simulated topology and needs no cloud credentials.
# node-data-broker only serves real providers and crashes with "test", as in upstream kind-kwok values.
helm repo update chart-museum --kubeconfig "$KIND_KUBECONFIG"
helm install "$RELEASE" chart-museum/topograph \
    --version "$CHART_VERSION" \
    --namespace "$NAMESPACE" --create-namespace \
    --set topograph.nodeDataBroker.enabled=false \
    --timeout 10m0s --wait --debug --kubeconfig "$KIND_KUBECONFIG"

kubectl --kubeconfig "$KIND_KUBECONFIG" rollout status \
    deployment/"$RELEASE" --namespace "$NAMESPACE" --timeout=5m
helm --kubeconfig "$KIND_KUBECONFIG" -n "$NAMESPACE" test "$RELEASE" --timeout 5m
