#!/bin/bash

CURRENT_FILENAME=$( basename $0 )
CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

KIND_KUBECONFIG=$1

[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

helm repo update chart-museum  --kubeconfig ${KIND_KUBECONFIG}
HELM_MUST_OPTION=" --timeout 30m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice , prometheus CRD has been deployed , so you no need to =============

set -x

# deploy nexus-repository-manager
helm install nexus-repository-manager chart-museum/nexus-repository-manager ${HELM_MUST_OPTION} --namespace nexus-repository-manager --create-namespace --set nexus-repository-manager.persistence.enabled=false --set nexus-repository-manager.nexus.resources.requests.cpu=0 --set nexus-repository-manager.nexus.resources.requests.memory="0Gi" --set nexus-repository-manager.nexus.resources.limits.cpu=0 --set nexus-repository-manager.nexus.resources.limits.memory="0Gi"

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, faild to deploy $CHART_DIR"
    kubectl --kubeconfig ${KIND_KUBECONFIG} get pod -o wide -A
  exit 1
fi
