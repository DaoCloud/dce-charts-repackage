#!/bin/bash
set -euo pipefail

KIND_KUBECONFIG=${1:?missing kubeconfig}
CHART_VERSION=${3:?missing chart version}
[ -f "$KIND_KUBECONFIG" ] || { echo "error, kubeconfig not found: $KIND_KUBECONFIG"; exit 1; }

# LWS 0.8.0 requires Kubernetes >= 1.26.
# Helm installs the CRDs from the bundled child chart.
helm repo update chart-museum --kubeconfig "$KIND_KUBECONFIG"
helm install lws chart-museum/lws \
    --version "$CHART_VERSION" \
    --namespace lws-system --create-namespace \
    --timeout 10m0s --wait --debug --kubeconfig "$KIND_KUBECONFIG"

kubectl --kubeconfig "$KIND_KUBECONFIG" wait \
    --for=condition=Established --timeout=60s \
    crd/leaderworkersets.leaderworkerset.x-k8s.io
kubectl --kubeconfig "$KIND_KUBECONFIG" rollout status \
    deployment/lws-controller-manager --namespace lws-system --timeout=5m
