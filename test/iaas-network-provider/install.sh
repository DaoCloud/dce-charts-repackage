#!/bin/bash

CURRENT_DIR_PATH=$(cd "$(dirname "$0")" ; pwd )

HELM_TEST_VALUES="\
  --set iaas-network-provider.replicaCount=0 \
  --set iaas-network-provider.config.iaasProvider.endpoint=https://iaas.example.com \
  --set iaas-network-provider.config.iaasProvider.region=test-region \
  --set iaas-network-provider.config.iaasProvider.projectID=test-project \
  --set iaas-network-provider.config.iaasProvider.ecsEndpoint=https://ecs.example.com \
  --set iaas-network-provider.config.iaasProvider.vpcEndpoint=https://vpc.example.com \
  --set iaas-network-provider.config.iaasProvider.auth.mode=token \
  --set iaas-network-provider.config.iaasProvider.auth.token.username=test-user \
  --set iaas-network-provider.config.iaasProvider.auth.token.password=test-pass \
  --set iaas-network-provider.config.iaasProvider.auth.token.iamDomain=test-domain \
  --set iaas-network-provider.config.iaasProvider.auth.token.agencyName=test-agency"

if [ "${BASH_SOURCE[0]}" != "$0" ] ; then
  return 0
fi

KIND_KUBECONFIG=$1
CHART_VERSION=$3
CHART_DIR=$( cd "${CURRENT_DIR_PATH}/../../charts/iaas-network-provider/iaas-network-provider" ; pwd )

[ -d "$CHART_DIR" ] || { echo "error, failed to find chart $CHART_DIR " ; exit 1 ; }
[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }
[ -n "$CHART_VERSION" ] || { echo "error, failed to find chart version $CHART_VERSION " ; exit 1 ; }

echo "CHART_DIR: $CHART_DIR"
echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"
echo "CHART_VERSION: $CHART_VERSION"

helm repo update chart-museum --kubeconfig "${KIND_KUBECONFIG}"
HELM_MUST_OPTION=" --version ${CHART_VERSION} --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

set -e
set -x

NAMESPACE=iaas-network-provider-system
RELEASE=iaas-network-provider

if helm --kubeconfig "${KIND_KUBECONFIG}" -n "${NAMESPACE}" status "${RELEASE}" >/dev/null 2>&1 ; then
  helm --kubeconfig "${KIND_KUBECONFIG}" -n "${NAMESPACE}" uninstall "${RELEASE}"
fi

# The provider requires real cloud credentials and endpoints to start. For chart
# E2E, render all required configuration and set replicas to 0 so the release can
# be installed without contacting an external IaaS API.
# shellcheck disable=SC2086
helm install "${RELEASE}" chart-museum/iaas-network-provider ${HELM_MUST_OPTION} \
  --namespace "${NAMESPACE}" --create-namespace \
  ${HELM_TEST_VALUES}

kubectl --kubeconfig "${KIND_KUBECONFIG}" get ns "${NAMESPACE}"
helm --kubeconfig "${KIND_KUBECONFIG}" -n "${NAMESPACE}" status "${RELEASE}"
kubectl --kubeconfig "${KIND_KUBECONFIG}" -n "${NAMESPACE}" get serviceaccount "${RELEASE}"
kubectl --kubeconfig "${KIND_KUBECONFIG}" -n "${NAMESPACE}" get configmap "${RELEASE}"
kubectl --kubeconfig "${KIND_KUBECONFIG}" -n "${NAMESPACE}" get service "${RELEASE}"
kubectl --kubeconfig "${KIND_KUBECONFIG}" -n "${NAMESPACE}" get deployment "${RELEASE}"

REPLICAS=$(kubectl --kubeconfig "${KIND_KUBECONFIG}" -n "${NAMESPACE}" get deployment "${RELEASE}" -o jsonpath='{.spec.replicas}')
[ "${REPLICAS}" = "0" ] || { echo "error, expected deployment replicas to be 0, got ${REPLICAS}" ; exit 1 ; }

exit 0
