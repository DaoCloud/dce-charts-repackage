#!/bin/bash

CURRENT_FILENAME=$( basename "$0" )
CURRENT_DIR_PATH=$(cd `dirname $0` ; pwd )

KIND_KUBECONFIG=$1
VERSION=$3
CHART_DIR=$( cd ${CURRENT_DIR_PATH}/../../charts/llm-d-modelservice/llm-d-modelservice ; pwd )

[ -d "$CHART_DIR" ] || { echo "error, failed to find chart $CHART_DIR " ; exit 1 ; }
[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "CHART_DIR: $CHART_DIR"
echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

OCI_REGISTRY="oci://127.0.0.1:30080"
HELM_MUST_OPTION=" --plain-http --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice, prometheus CRD has been deployed , so you no need to =============
# !!!!!!!!! this chart is special, it does not contain any image, which make syncer-chart fail !!!!!!!!!

set -x

# deploy llm-d-modelservice
# shellcheck disable=SC2086
helm install llm-d-modelservice ${OCI_REGISTRY}/llm-d-modelservice --version ${VERSION}  ${HELM_MUST_OPTION} --namespace kube-system

if (($?==0)) ; then
 echo "succeeded to deploy $CHART_DIR"
 exit 0
else
 echo "error, failed to deploy $CHART_DIR"
 exit 1
fi