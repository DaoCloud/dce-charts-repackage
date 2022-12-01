#!/bin/bash

CURRENT_FILENAME=$( basename "$0" )
CURRENT_DIR_PATH=$(cd "$CURRENT_FILENAME" || exit; pwd)

CHART_DIR=$1
KIND_KUBECONFIG=$2

[ -d "$CHART_DIR" ] || { echo "error, failed to find chart $CHART_DIR " ; exit 1 ; }
[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }
[ -n "$E2E_KIND_CLUSTER_NAME" ] || {echo "error, no specify kind cluster name"; exit 1 ; }

echo "CHART_DIR: $CHART_DIR"
echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

HELM_MUST_OPTION=" --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice, prometheus CRD has been deployed , so you no need to =============

set -x

if [ "${RUN_ON_LOCAL}" = "false" ]; then
  HELM_MUST_OPTION+=" --set cert-manager.image.repository=quay.io/jetstack/cert-manager-controller \
  --set cert-manager.webhook.image.repository=quay.io/jetstack/cert-manager-webhook \
  --set cert-manager.cainjector.image.repository=quay.io/jetstack/cert-manager-cainjector \
  --set cert-manager.startupapicheck.image.repository=quay.io/jetstack/cert-manager-ctl "
fi

#==================== add your deploy code bellow =============
#==================== notice , prometheus CRD has been deployed , so you no need to =============
HELM_IMAGES_LIST=` helm template test ${CHART_DIR} ${HELM_MUST_OPTION} | grep " image: " | tr -d '"'| awk '{print $2}' `
if [ -z "${HELM_IMAGES_LIST}" ] ; then
  echo "warning, failed to find image from chart template for cert-manager"
else
  echo "found image from cert-manager chart template: ${HELM_IMAGES_LIST}"
  for IMAGE in ${HELM_IMAGES_LIST} ; do
      EXIST=` docker images | awk '{printf("%s:%s\n",$1,$2)}' | grep "${IMAGE}" `
      if [ -z "${EXIST}" ] ; then
        echo "docker pull ${IMAGE} to local"
        docker pull ${IMAGE}
      fi
    echo "load local image ${IMAGE} for cert-manager"
    kind load docker-image ${IMAGE}  --name ${E2E_KIND_CLUSTER_NAME}
  done
fi


# deploy cert-manager
# shellcheck disable=SC2086
helm install cert-manager "${CHART_DIR}" ${HELM_MUST_OPTION} --namespace kube-system


if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, failed to deploy $CHART_DIR"
  exit 1
fi
