#!/bin/bash

CURRENT_FILENAME=$( basename "$0" )
CURRENT_DIR_PATH=$(cd `dirname $0` ; pwd )

KIND_KUBECONFIG=$1
CHART_DIR=$( cd ${CURRENT_DIR_PATH}/../../charts/kgateway/kgateway ; pwd )

[ -d "$CHART_DIR" ] || { echo "error, failed to find chart $CHART_DIR " ; exit 1 ; }
[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "CHART_DIR: $CHART_DIR"
echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

helm repo update chart-museum  --kubeconfig ${KIND_KUBECONFIG}
HELM_MUST_OPTION=" --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

set -e
set -x

NAMESPACE=kgateway-system
RELEASE=kgateway

# install kgateway with optional gateway-api CRDs enabled
# shellcheck disable=SC2086
helm install ${RELEASE} chart-museum/kgateway ${HELM_MUST_OPTION} --namespace ${NAMESPACE} --create-namespace --set installGatewayApiCrd=true

# Basic checks
kubectl --kubeconfig ${KIND_KUBECONFIG} get ns ${NAMESPACE}
helm --kubeconfig ${KIND_KUBECONFIG} -n ${NAMESPACE} status ${RELEASE}

# Validate CRDs
REQUIRED_CRDS=(
  gatewayclasses.gateway.networking.k8s.io
  gateways.gateway.networking.k8s.io
  httproutes.gateway.networking.k8s.io
  referencegrants.gateway.networking.k8s.io
  gatewayextensions.gateway.kgateway.dev
  backends.gateway.kgateway.dev
  backendconfigpolicies.gateway.kgateway.dev
  directresponses.gateway.kgateway.dev
  trafficpolicies.gateway.kgateway.dev
  httplistenerpolicies.gateway.kgateway.dev
  listenerpolicies.gateway.kgateway.dev
  gatewayparameters.gateway.kgateway.dev
)

for CRD in "${REQUIRED_CRDS[@]}" ; do
  kubectl --kubeconfig ${KIND_KUBECONFIG} get crd ${CRD} || { echo "error, missing CRD: ${CRD}" ; exit 1 ; }
done

exit 0
