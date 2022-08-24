#!/bin/bash

CURRENT_FILENAME=$( basename $0 )
CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

CHART_DIR=$1
KIND_KUBECONFIG=$2

[ -d "$CHART_DIR" ] || { echo "error, failed to find chart $CHART_DIR " ; exit 1 ; }
[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "CHART_DIR $CHART_DIR"
echo "KIND_KUBECONFIG $KIND_KUBECONFIG"

HELM_MUST_OPTION=" --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice , prometheus CRD has been deployed , so you no need to =============

set -x

# deploy the multus
helm install multus ${CHART_DIR}  ${HELM_MUST_OPTION} \
  --namespace kube-system \
  --set multus.image.repository=ghcr.io/k8snetworkplumbingwg/multus-cni

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
else
  echo "error, faild to deploy $CHART_DIR"
  exit 1
fi

kubectl wait --for=condition=ready -l app=multus --timeout=300s pod -n kube-system --kubeconfig ${KIND_KUBECONFIG}
kubectl get po -n kube-system --kubeconfig ${KIND_KUBECONFIG}
