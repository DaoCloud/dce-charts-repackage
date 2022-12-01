#!/bin/bash

CURRENT_FILENAME=$( basename $0 )
CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

CHART_DIR=$1
KIND_KUBECONFIG=$2

[ -d "$CHART_DIR" ] || { echo "error, failed to find chart $CHART_DIR " ; exit 1 ; }
[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }
[ -n "$E2E_KIND_CLUSTER_NAME" ] || { echo "error, no specify kind cluster name"; exit 1 ; }

echo "CHART_DIR: $CHART_DIR"
echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

HELM_MUST_OPTION=" --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

if [ "${RUN_ON_LOCAL}" = "false" ]; then
  HELM_MUST_OPTION+=" --set metallb.speaker.image.repository=quay.io/metallb/speaker \
  --set metallb.controller.image.repository=quay.io/metallb/controller "
fi

#==================== add your deploy code bellow =============
#==================== notice , prometheus CRD has been deployed , so you no need to =============
HELM_IMAGES_LIST=` helm template test ${CHART_DIR}  ${HELM_MUST_OPTION} | grep " image: " | tr -d '"'| awk '{print $2}' `
if [ -z "${HELM_IMAGES_LIST}" ] ; then
  echo "warning, failed to find image from chart template for metallb"
else
  echo "found image from metallb chart template: ${HELM_IMAGES_LIST}"
  for IMAGE in ${HELM_IMAGES_LIST} ; do
      EXIST=` docker images | awk '{printf("%s:%s\n",$1,$2)}' | grep "${IMAGE}" `
      if [ -z "${EXIST}" ] ; then
        echo "docker pull ${IMAGE} to local"
        docker pull ${IMAGE}
      fi
    echo "load local image ${IMAGE} for metallb"
    kind load docker-image ${IMAGE}  --name ${E2E_KIND_CLUSTER_NAME}
  done
fi

set -x

# deploy the metallb
helm install metallb ${CHART_DIR}  ${HELM_MUST_OPTION}   --namespace kube-system \
  --set instances.enabled=true \
  --set instances.arp.nodeSelectors='{Node1,Node2}' \
  --set instances.ipAddressPools.addresses="{192.168.1.0/24,172.16.20.1-172.16.20.100,fd00:81::172:81:0:110-fd00:81::172:81:0:120}" \
  --set metallb.prometheus.podMonitor.enabled=true \
  --set metallb.prometheus.prometheusRule.enabled=true \
  --set metallb.prometheus.serviceAccount=insight-agent-kube-prometh-operator \
  --set metallb.prometheus.namespace=insight-system


if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, faild to deploy $CHART_DIR"
  exit 1
fi
