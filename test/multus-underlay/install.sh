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

# deploy the spiderpool
helm install multus ${CHART_DIR}  ${HELM_MUST_OPTION} \
  --namespace kube-system \
  --set sriov.manifests.enanle=true \
  --set underlay_crds.sriov.resourceName=intel.com/mlnx_sriov_rdma \
  --set underlay_crds.service_subnet.ipv6=fed0::1/64 \
  --set underlay_crds.sriov.sriov_standalone.enable=true \
  --set underlay_crds.sriov.sriov_overlay.enable=true

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"

else
  echo "error, faild to deploy $CHART_DIR"
  exit 1
fi

kubectl wait --for=condition=ready -l app=multus --timeout=300s pod -n kube-system --kubeconfig ${KIND_KUBECONFIG}

# check veth-bin exsit
KIND_NODE=`docker ps | grep 'control-plane' | awk '{print $1}'`
EXIST=`docker exec ${KIND_NODE} ls /opt/cni/bin | grep "veth" `
if [ -z "${EXIST}" ] ; then
  echo "veth not to installed successfully"
  exit 1
else
  echo "ls /opt/cni/bin: "
  docker exec ${KIND_NODE} ls /opt/cni/bin
  exit 0
fi

kubectl get po -n kube-system --kubeconfig ${KIND_KUBECONFIG}
kubectl get network-attachment-definitions.k8s.cni.cncf.io -A --kubeconfig ${KIND_KUBECONFIG}
