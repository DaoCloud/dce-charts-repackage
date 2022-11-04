#!/bin/bash

CURRENT_FILENAME=$( basename $0 )
CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

CHART_DIR=$1
KIND_KUBECONFIG=$2

[ -d "$CHART_DIR" ] || { echo "error, failed to find chart $CHART_DIR " ; exit 1 ; }
[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "CHART_DIR: $CHART_DIR"
echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

HELM_MUST_OPTION=" --timeout 10m0s --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
set -x

# nmstate can't install in kind, so we use following wat to verify helm install

# if image is exist
IMAGES=`helm template test . | grep quay | awk -F ':' '{print $2}' | tr -d ' '`
for IMAGE in IMAGES; do
  echo ${IMAGE}
  docker pull ${IMAGE}
done

# try deploy the nmstate but --dry-run
helm install nmstate ${CHART_DIR}  ${HELM_MUST_OPTION}  -n kube-system --dry-run \

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, faild to deploy $CHART_DIR"
  exit 1
fi
