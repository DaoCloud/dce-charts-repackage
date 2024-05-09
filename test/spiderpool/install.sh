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
  --set spiderpool.global.imageRegistryOverride=ghcr.io \
  --set spiderpool.spiderpoolController.tls.method=auto \
  --set spiderpool.ipam.enableSpiderSubnet=true \
  --set spiderpool.multus.multusCNI.defaultCNIName=kindnet \
  --set spiderpool.sriov.install=true \
  --set rdma.rdmaSharedDevicePlugin.install=true \
  --set plugins.installCNI=true --set plugins.installRdmaCNI=true --set plugins.installOvsCNI=true \
  --set spiderpool.ipam.enableIPv4=true --set spiderpool.ipam.enableIPv6=true \
  --set spiderpool.clusterDefaultPool.installIPv4IPPool=true  --set spiderpool.clusterDefaultPool.installIPv6IPPool=true  \
  --set spiderpool.clusterDefaultPool.ipv4Subnet=${Ipv4Subnet} --set spiderpool.clusterDefaultPool.ipv4IPRanges={${Ipv4Range}} --set spiderpool.clusterDefaultPool.ipv4Gateway=${Ipv4GW}\
  --set spiderpool.clusterDefaultPool.ipv6Subnet=${Ipv6Subnet} --set spiderpool.clusterDefaultPool.ipv6IPRanges={${Ipv6Range}} --set spiderpool.clusterDefaultPool.ipv6Gateway=${Ipv6GW}

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  kubectl --kubeconfig ${KIND_KUBECONFIG} get pod -o wide -A
  kubectl get spidercoordinator default -o yaml --kubeconfig ${KIND_KUBECONFIG}
  kubectl get smc -A -o yaml --kubeconfig ${KIND_KUBECONFIG}
  exit 0
else
  echo "error, faild to deploy $CHART_DIR"
    kubectl --kubeconfig ${KIND_KUBECONFIG} get pod -o wide -A
  exit 1
fi
