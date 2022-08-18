#!/bin/bash

CURRENT_FILENAME=$( basename $0 )
CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

CHART_DIR=$1
KIND_KUBECONFIG=$2

[ -d "$CHART_DIR" ] || { echo "error, failed to find chart $CHART_DIR " ; exit 1 ; }
[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "CHART_DIR $CHART_DIR"
echo "KIND_KUBECONFIG $KIND_KUBECONFIG"

HELM_MUST_OPTION=" --atomic --timeout 5m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============

# for default ipv4 ippool
Ipv4Subnet="172.50.0.0/16"
# available IP resource
Ipv4Range="172.250.0.10-172.50.0.200"
# for default ipv6 ippool
Ipv6Subnet="fd05::/112"
# available IP resource
Ipv6Range="fd05::10-fd05::200"

# deploy the spiderpool
helm install spiderpool ${CHART_DIR}  ${HELM_MUST_OPTION} \
  --namespace kube-system \
  --set spiderpoolController.tls.method=provided \
  --set ipFamily.enableIPv4=true --set ipFamily.enableIPv6=true \
  --set clusterDefaultPool.installIPv4IPPool=true  --set clusterDefaultPool.installIPv6IPPool=true  \
  --set clusterDefaultPool.ipv4Subnet=${Ipv4Subnet} --set clusterDefaultPool.ipv4IPRanges={${Ipv4Range}} \
  --set clusterDefaultPool.ipv6Subnet=${Ipv6Subnet} --set clusterDefaultPool.ipv6IPRanges={${Ipv6Range}}

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, faild to deploy $CHART_DIR"
  exit 1
fi
