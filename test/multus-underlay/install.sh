#!/bin/bash

CURRENT_FILENAME=$( basename $0 )
CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

CHART_DIR=$1
KIND_KUBECONFIG=$2
KIND_NAME=$3

[ -d "$CHART_DIR" ] || { echo "error, failed to find chart $CHART_DIR " ; exit 1 ; }
[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }
[ -n "${KIND_NAME}" ] || { echo "error, failed to find kind_name $KIND_NAME " ; exit 1 ; }

echo "CHART_DIR $CHART_DIR"
echo "KIND_KUBECONFIG $KIND_KUBECONFIG"
echo "KIND_NAME: ${KIND_NAME}"

HELM_MUST_OPTION=" --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} \
--namespace kube-public \
--set sriov.manifests.enable=true \
--set sriov.sriov_crd.resourceName=intel.com/mlnx_sriov_rdma \
--set overlay_subnet.service_subnet.ipv6=fed0::1/64  "

#==================== add your deploy code bellow =============
#==================== notice , prometheus CRD has been deployed , so you no need to =============

set -x

HELM_IMAGES_LIST=` helm template test ${CHART_DIR}  ${HELM_MUST_OPTION} | grep " image: " | tr -d '"'| awk '{print $2}' `

[ -z "${HELM_IMAGES_LIST}" ] && echo "can't found image of multus-underlay" && exit 1
LOCAL_IMAGE_LIST=`docker images | awk '{printf("%s:%s\n",$1,$2)}'`

for IMAGE in ${HELM_IMAGES_LIST}; do
  found=false
  for LOCAL_IMAGE in ${LOCAL_IMAGE_LIST}; do
    if [ "${IMAGE}" == "${LOCAL_IMAGE}" ]; then
      found=true
      break
    fi
  done
  if [ "${found}" == "false" ] ; then
    echo "===> docker pull ${IMAGE}..."
    docker pull ${IMAGE}
  fi
  echo "===> load image ${IMAGE} to kind..."
  kind load docker-image ${IMAGE} --name ${KIND_NAME}
done

# deploy the multus
helm install multus ${CHART_DIR}  ${HELM_MUST_OPTION}

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
else
  echo "error, faild to deploy $CHART_DIR"
  exit 1
fi

kubectl wait --for=condition=ready -l app=multus --timeout=300s pod -n kube-public --kubeconfig ${KIND_KUBECONFIG}

KIND_NODE=`docker ps | grep 'control-plane' | awk '{print $1}'`
EXIST=`docker exec ${KIND_NODE} ls /opt/cni/bin `

kubectl get po -n kube-public --kubeconfig ${KIND_KUBECONFIG}
kubectl get network-attachment-definitions.k8s.cni.cncf.io -A --kubeconfig ${KIND_KUBECONFIG}
