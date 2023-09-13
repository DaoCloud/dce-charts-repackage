#!/bin/bash

CURRENT_FILENAME=$( basename "$0" )
CURRENT_DIR_PATH=$(cd `dirname $0` ; pwd )

KIND_KUBECONFIG=$1
CHART_DIR=$( cd ${CURRENT_DIR_PATH}/../../charts/gpu-operator/gpu-operator ; pwd )

[ -d "$CHART_DIR" ] || { echo "error, failed to find chart $CHART_DIR " ; exit 1 ; }
[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "CHART_DIR: $CHART_DIR"
echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

HELM_MUST_OPTION=" --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice, prometheus CRD has been deployed , so you no need to =============
# !!!!!!!!! this chart is special, it does not contain any image, which make syncer-chart fail !!!!!!!!!

set -x

# deploy cert-manager
# shellcheck disable=SC2086
helm upgrade -i gpu-operator -n gpu-operator --create-namespace "${CHART_DIR}" ${HELM_MUST_OPTION}

exit 0