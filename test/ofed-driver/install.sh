#!/bin/bash

CURRENT_FILENAME=$( basename "$0" )
CURRENT_DIR_PATH=$(cd `dirname $0` ; pwd )

KIND_KUBECONFIG=$1
CHART_VERSION=$3

[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }
[ -n "$CHART_VERSION" ] || { echo "error, failed to find chart version $CHART_VERSION " ; exit 1 ; }

echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"
echo "CHART_VERSION: $CHART_VERSION"

helm repo update chart-museum  --kubeconfig ${KIND_KUBECONFIG}
HELM_MUST_OPTION=" --version ${CHART_VERSION} --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice , prometheus CRD has been deployed , so you no need to =============

set -x

# deploy ofed-driver
helm install ofed-driver chart-museum/ofed-driver ${HELM_MUST_OPTION}  --namespace ofed-driver --create-namespace
if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, faild to deploy $CHART_DIR"
    kubectl --kubeconfig ${KIND_KUBECONFIG} get pod -o wide -A
  exit 1
fi