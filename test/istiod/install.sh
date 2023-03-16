#!/bin/bash

CURRENT_FILENAME=$( basename "$0" )
CURRENT_DIR_PATH=$(cd `dirname $0` ; pwd )

KIND_KUBECONFIG=$1

[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

helm repo update chart-museum  --kubeconfig ${KIND_KUBECONFIG}
HELM_MUST_OPTION=" --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice, prometheus CRD has been deployed , so you no need to =============

set -x

# deploy istiod
# shellcheck disable=SC2086
helm install istiod chart-museum/istiod ${HELM_MUST_OPTION} --namespace istio-system --create-namespace \
     --set istiod.telemetry.enabled=false \
     --set global.omitSidecarInjectorConfigMap=true

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, failed to deploy $CHART_DIR"
  exit 1
fi