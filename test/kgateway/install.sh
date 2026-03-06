#!/bin/bash

CURRENT_DIR_PATH=$(cd "$(dirname "$0")" ; pwd )

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

if helm --kubeconfig ${KIND_KUBECONFIG} -n ${NAMESPACE} status ${RELEASE} >/dev/null 2>&1 ; then
  helm --kubeconfig ${KIND_KUBECONFIG} -n ${NAMESPACE} uninstall ${RELEASE}
fi

# install kgateway with gateway-api CRDs enabled
# shellcheck disable=SC2086
helm install ${RELEASE} chart-museum/kgateway ${HELM_MUST_OPTION} --namespace ${NAMESPACE} --create-namespace --set installK8sGatewayAPI=true

kubectl --kubeconfig ${KIND_KUBECONFIG} get ns ${NAMESPACE}
helm --kubeconfig ${KIND_KUBECONFIG} -n ${NAMESPACE} status ${RELEASE}
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

kubectl --kubeconfig ${KIND_KUBECONFIG} -n ${NAMESPACE} wait --for=condition=Available deployment/kgateway --timeout=5m
kubectl --kubeconfig ${KIND_KUBECONFIG} -n ${NAMESPACE} get deploy
kubectl --kubeconfig ${KIND_KUBECONFIG} -n ${NAMESPACE} get pods

exit 0
