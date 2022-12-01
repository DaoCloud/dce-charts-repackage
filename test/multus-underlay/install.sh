#!/bin/bash

CURRENT_FILENAME=$( basename $0 )
CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

CHART_DIR=$1
KIND_KUBECONFIG=$2

[ -d "$CHART_DIR" ] || { echo "error, failed to find chart $CHART_DIR " ; exit 1 ; }
[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }
[ -n "$E2E_KIND_CLUSTER_NAME" ] || { echo "error, no specify kind cluster name"; exit 1 ; }

echo "CHART_DIR $CHART_DIR"
echo "KIND_KUBECONFIG $KIND_KUBECONFIG"

HELM_MUST_OPTION=" --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice , prometheus CRD has been deployed , so you no need to =============

set -x

if [ "${RUN_ON_LOCAL}" = "false" ]; then
  HELM_MUST_OPTION+=" --set multus.image.repository=ghcr.io/k8snetworkplumbingwg/multus-cni \
  --set sriov.images.sriovCni.repository=ghcr.io/k8snetworkplumbingwg/sriov-cni \
  --set sriov.images.sriovDevicePlugin.repository=ghcr.io/k8snetworkplumbingwg/sriov-network-device-plugin \
  --set meta-plugins.image.repository=ghcr.io/spidernet-io/cni-plugins/meta-plugins"
fi

IMAGE_LIST=` helm template test ${CHART_DIR}  ${HELM_MUST_OPTION} | grep " image: " | tr -d '"'| awk '{print $2}' `
if [ -z "${IMAGE_LIST}" ] ; then
  echo "warning, failed to find image from chart template for multus-underlay"
else
  echo "found image from multus-underlay chart template: ${IMAGE_LIST}"
  for IMAGE in ${IMAGE_LIST} ; do
      EXIST=` docker images | awk '{printf("%s:%s\n",$1,$2)}' | grep "${IMAGE}" `
      if [ -z "${EXIST}" ] ; then
        echo "docker pull ${IMAGE} to local"
        docker pull ${IMAGE}
      fi
    echo "load local image ${IMAGE} for multus-underlay"
    kind load docker-image ${IMAGE}  --name ${E2E_KIND_CLUSTER_NAME}
  done
fi

helm install multus ${CHART_DIR}  ${HELM_MUST_OPTION} \
  --namespace kube-system \
  --set multus.config.cni_conf.clusterNetwork=kindnet \
  --set sriov.manifests.enable=true \
  --set sriov.sriov_crd.resourceName=intel.com/mlnx_sriov_rdma \
  --set overlay_subnet.service_subnet.ipv6=fed0::1/64

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"

else
  echo "error, faild to deploy $CHART_DIR"
  exit 1
fi

kubectl wait --for=condition=ready -l app=multus --timeout=300s pod -n kube-system --kubeconfig ${KIND_KUBECONFIG}

KIND_NODE=`docker ps | grep 'control-plane' | awk '{print $1}'`
EXIST=`docker exec ${KIND_NODE} ls /opt/cni/bin `

kubectl get po -n kube-system --kubeconfig ${KIND_KUBECONFIG}
kubectl get network-attachment-definitions.k8s.cni.cncf.io -A --kubeconfig ${KIND_KUBECONFIG}
