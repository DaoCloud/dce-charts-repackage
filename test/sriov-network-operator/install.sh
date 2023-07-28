#!/bin/bash

CURRENT_FILENAME=$( basename "$0" )
CURRENT_DIR_PATH=$(cd `dirname $0` ; pwd )

KIND_KUBECONFIG=$1

[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

helm repo update chart-museum  --kubeconfig ${KIND_KUBECONFIG}
HELM_MUST_OPTION=" --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice , prometheus CRD has been deployed , so you no need to =============

set -x

kubectl label nodes $(kubectl get nodes -o jsonpath="{range  .items[1]}{@.metadata.name}" --kubeconfig ${KIND_KUBECONFIG}) node-role.kubernetes.io/worker="" --kubeconfig ${KIND_KUBECONFIG}
helm install sriov-network-operator chart-museum/sriov-network-operator ${HELM_MUST_OPTION} \
        --create-namespace \
        --namespace sriov-network-operator \
        --set sriovNetworkNodePolicy.pfNames="{eth0}"

sleep 30

kubectl get SriovNetworkNodePolicy -n sriov-network-operator default-nodepolicy -o yaml --kubeconfig ${KIND_KUBECONFIG}