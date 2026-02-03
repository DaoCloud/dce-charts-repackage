#!/bin/bash

CURRENT_FILENAME=$( basename $0 )
CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

KIND_KUBECONFIG=$1

[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"
echo "helm version: " "$(helm version)"
helm repo update chart-museum  --kubeconfig ${KIND_KUBECONFIG}
HELM_MUST_OPTION=" --timeout 5m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============

set -x

helm install dataset chart-museum/dataset  ${HELM_MUST_OPTION}  --create-namespace --namespace dataset-system

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, failed to deploy $CHART_DIR"
  kubectl get all -n dataset-system --kubeconfig ${KIND_KUBECONFIG}
  exit 1
fi
