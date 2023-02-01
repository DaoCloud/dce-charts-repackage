#!/bin/bash

CURRENT_FILENAME=$( basename "$0" )
CURRENT_DIR_PATH=$(cd "$CURRENT_FILENAME" || exit; pwd)

KIND_KUBECONFIG=$1

[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

helm repo update chart-museum  --kubeconfig ${KIND_KUBECONFIG}
HELM_MUST_OPTION=" --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice , prometheus CRD has been deployed , so you no need to =============

# for default ipv4 ippool
Ipv4Subnet="172.50.0.0/16"
Ipv4GW="172.50.0.1"
# available IP resource
Ipv4Range="172.50.0.10-172.50.0.200"
# for default ipv6 ippool
Ipv6Subnet="fd05::/112"
Ipv6GW="fd05::1"
# available IP resource
Ipv6Range="fd05::10-fd05::200"

set -x

# deploy the spiderpool
helm install spiderpool chart-museum/spiderpool  ${HELM_MUST_OPTION} \
  --namespace kube-system \
  --set spiderpool.spiderpoolController.tls.method=auto \
  --set spiderpool.feature.enableSpiderSubnet=true \
  --set spiderpool.feature.enableIPv4=true --set spiderpool.feature.enableIPv6=true \
  --set spiderpool.clusterDefaultPool.installIPv4IPPool=true  --set spiderpool.clusterDefaultPool.installIPv6IPPool=true  \
  --set spiderpool.clusterDefaultPool.ipv4Subnet=${Ipv4Subnet} --set spiderpool.clusterDefaultPool.ipv4IPRanges={${Ipv4Range}} --set spiderpool.clusterDefaultPool.ipv4Gateway=${Ipv4GW}\
  --set spiderpool.clusterDefaultPool.ipv6Subnet=${Ipv6Subnet} --set spiderpool.clusterDefaultPool.ipv6IPRanges={${Ipv6Range}} --set spiderpool.clusterDefaultPool.ipv6Gateway=${Ipv6GW}

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, faild to deploy $CHART_DIR"
    kubectl --kubeconfig ${KIND_KUBECONFIG} get pod -o wide -A

  exit 1
fi
