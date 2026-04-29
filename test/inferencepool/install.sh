#!/bin/bash

CURRENT_FILENAME=$( basename "$0" )
CURRENT_DIR_PATH=$(cd `dirname $0` ; pwd )

KIND_KUBECONFIG=$1
CHART_VERSION=$3

[ -f "$KIND_KUBECONFIG" ] || {
  echo "error, failed to find kubeconfig $KIND_KUBECONFIG "
  exit 1
}
[ -n "$CHART_VERSION" ] || {
  echo "error, failed to find chart version $CHART_VERSION "
  exit 1
}

echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"
echo "CHART_VERSION: $CHART_VERSION"

helm repo update chart-museum --kubeconfig ${KIND_KUBECONFIG}
HELM_MUST_OPTION=" --version ${CHART_VERSION} --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice , prometheus CRD has been deployed , so you no need to =============

set -x

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api-inference-extension/releases/download/${CHART_VERSION}/manifests.yaml \
  --kubeconfig ${KIND_KUBECONFIG}

helm install inferencepool chart-museum/inferencepool ${HELM_MUST_OPTION} --set \
  inferencepool.inferencePool.modelServers\.matchLabels.app=vllm-llama3-8b-instruct \
  --namespace inferencepool-system --create-namespace

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
else
  echo "error, failed to deploy $CHART_DIR"
  exit 1
fi

#==================== test with sidecar enabled =============
SIDECAR_NAMESPACE=inferencepool-sidecar-system
SIDECAR_RELEASE=inferencepool-sidecar
SIDECAR_IMAGE_NAME="llm-d-uds-tokenizer"

helm install ${SIDECAR_RELEASE} chart-museum/inferencepool ${HELM_MUST_OPTION} \
  --set inferencepool.inferencePool.modelServers\.matchLabels.app=vllm-llama3-8b-instruct \
  --set inferencepool.inferenceExtension.sidecar.enabled=true \
  --set inferencepool.inferenceExtension.sidecar.name=${SIDECAR_IMAGE_NAME} \
  --namespace ${SIDECAR_NAMESPACE} --create-namespace

if (($?==0)) ; then
  echo "succeeded to deploy ${SIDECAR_RELEASE}"
else
  echo "error, failed to deploy ${SIDECAR_RELEASE}"
  exit 1
fi

# verify sidecar image exists in the deployment
SIDECAR_DEPLOY_PODS=$(kubectl get pods -n ${SIDECAR_NAMESPACE} --kubeconfig ${KIND_KUBECONFIG} -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | head -1)
if [ -z "$SIDECAR_DEPLOY_PODS" ]; then
  echo "error, no pods found in ${SIDECAR_NAMESPACE}"
  exit 1
fi

echo "checking sidecar image in pod: ${SIDECAR_DEPLOY_PODS}"
SIDECAR_IMAGE=$(kubectl get pod ${SIDECAR_DEPLOY_PODS} -n ${SIDECAR_NAMESPACE} --kubeconfig ${KIND_KUBECONFIG} \
  -o=jsonpath='{range .spec.containers[*]}{.name}{"="}{.image}{"\n"}{end}' | grep ${SIDECAR_IMAGE_NAME})

if echo "${SIDECAR_IMAGE}" | grep -q "${SIDECAR_IMAGE_NAME}"; then
  echo "sidecar image verified: ${SIDECAR_IMAGE}"
else
  echo "error, sidecar image ${SIDECAR_IMAGE_NAME} not found in pod containers"
  echo "containers:"
  kubectl get pod ${SIDECAR_DEPLOY_PODS} -n ${SIDECAR_NAMESPACE} --kubeconfig ${KIND_KUBECONFIG} \
    -o=jsonpath='{range .spec.containers[*]}{.name}{"="}{.image}{"\n"}{end}'
  exit 1
fi