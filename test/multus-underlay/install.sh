#!/bin/bash

CURRENT_FILENAME=$( basename $0 )
CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

KIND_KUBECONFIG=$1
KIND_NAME=$2

[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }
[ -n "${KIND_NAME}" ] || { echo "error, failed to find kind_name $KIND_NAME " ; exit 1 ; }

echo "KIND_KUBECONFIG $KIND_KUBECONFIG"
echo "KIND_NAME: ${KIND_NAME}"

# deploy the multus
if ! which jq &>/dev/null ; then
    echo " 'jq' no found, try to install..."
    curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o /usr/bin/jq
    chmod +x /usr/bin/jq
fi

helm repo update chart-museum  --kubeconfig ${KIND_KUBECONFIG}
helm pull chart-museum/multus-underlay --untar --untardir /tmp
cat /tmp/multus-underlay/values.schema.json | jq '.properties.multus.properties.config.properties.cni_conf.properties.clusterNetwork.enum += ["kindnet"]' | tee /tmp/multus-underlay/values.schema.json

HELM_MUST_OPTION=" --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} \
--namespace kube-public \
--set multus.config.cni_conf.clusterNetwork=kindnet \
--set sriov.manifests.enable=true \
--set sriov.sriov_crd.resourceName=intel.com/mlnx_sriov_rdma \
--set overlay_subnet.service_subnet.ipv6=fed0::1/64  "

#==================== add your deploy code bellow =============
#==================== notice , prometheus CRD has been deployed , so you no need to =============

set -x

HELM_IMAGES_LIST=` helm template test /tmp/multus-underlay  ${HELM_MUST_OPTION} | grep " image: " | tr -d '"'| awk '{print $2}' `

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

helm install multus /tmp/multus-underlay  ${HELM_MUST_OPTION}

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
else
  echo "error, faild to deploy $CHART_DIR"
  exit 1
fi

kubectl wait --for=condition=ready -l app=multus --timeout=300s pod -n kube-public --kubeconfig ${KIND_KUBECONFIG}

KIND_NODES=` docker ps | egrep " kindest/node.* $KIND_NAME-(control|worker)"  | awk '{print $1}' `
for NODE in ${KIND_NODES} ; do
  docker exec ${NODE} rm /etc/cni/net.d/00-multus.conf
  docker exec ${NODE} rm -rf /etc/cni/net.d/multus.d
  docker exec ${NODE} ls /etc/cni/net.d/
done


kubectl get po -n kube-public --kubeconfig ${KIND_KUBECONFIG}
kubectl get network-attachment-definitions.k8s.cni.cncf.io -A --kubeconfig ${KIND_KUBECONFIG}
