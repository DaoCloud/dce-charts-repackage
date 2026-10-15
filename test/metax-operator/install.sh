#!/bin/bash

CURRENT_FILENAME=$( basename "$0" )
CURRENT_DIR_PATH=$(cd "$(dirname "$0")" || exit; pwd)

KIND_KUBECONFIG=$1
CHART_VERSION=$3

[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }
[ -n "$CHART_VERSION" ] || { echo "error, failed to find chart version $CHART_VERSION " ; exit 1 ; }

echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"
echo "CHART_VERSION: $CHART_VERSION"

helm repo update chart-museum  --kubeconfig ${KIND_KUBECONFIG}
# the chart version is a semver pre-release (e.g. 0.15.2-1), so it must be pinned with --version
HELM_MUST_OPTION=" --version ${CHART_VERSION} --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============

set -x

helm install metax-operator chart-museum/metax-operator  ${HELM_MUST_OPTION} --namespace default

if (($?==0)) ; then
  echo "succeeded to deploy metax-operator"
  exit 0
else
  echo "error, faild to deploy metax-operator"
  exit 1
fi
