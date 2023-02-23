#!/bin/bash

CURRENT_FILENAME=$( basename "$0" )
CURRENT_DIR_PATH=$(cd `dirname $0` ; pwd )

KIND_KUBECONFIG=$1

[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

helm repo update chart-museum  --kubeconfig ${KIND_KUBECONFIG}
HELM_MUST_OPTION=" --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice , prometheus CRD has been deployed , so you no need to =============

set -x

# install submariner-k8s-broker first
export BROKER_NS=submariner-k8s-broker
helm install submariner-k8s-broker  ${CURRENT_DIR_PATH}/../../charts/submariner-k8s-broker/submariner-k8s-broker ${HELM_MUST_OPTION}   --namespace ${BROKER_NS} --create-namespace

# prepare env
export SUBMARINER_NS=submariner-operator
#export SUBMARINER_PSK=$(LC_CTYPE=C tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 64 | head -n 1)
export SUBMARINER_PSK=8SzC7vuA9cvADtds7BVQ263DBEuC3OP1pDhmD3ujOGHvdcogbsssHfR6ZCwhhFNS
kubectl -n "${BROKER_NS}" get secrets --kubeconfig ${KIND_KUBECONFIG}
export SUBMARINER_BROKER_CA=$(kubectl -n "${BROKER_NS}" get secrets --kubeconfig ${KIND_KUBECONFIG} -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='${BROKER_NS}-client')].data['ca\.crt']}")
export SUBMARINER_BROKER_TOKEN=$(kubectl -n "${BROKER_NS}" get secrets --kubeconfig ${KIND_KUBECONFIG} \
    -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='${BROKER_NS}-client')].data.token}" \
  | base64 --decode)
export SUBMARINER_BROKER_URL=$(kubectl -n default get endpoints kubernetes --kubeconfig ${KIND_KUBECONFIG} \
    -o jsonpath="{.subsets[0].addresses[0].ip}:{.subsets[0].ports[?(@.name=='https')].port}")
export CLUSTER_ID=cluster-broker
export CLUSTER_CIDR="10.244.0.0/16"
export SERVICE_CIDR="10.69.0.0/16"

# install submariner-operator
kubectl label nodes $(kubectl get nodes -o jsonpath="{range  .items[0]}{@.metadata.name}" --kubeconfig ${KIND_KUBECONFIG}) submariner.io/gateway=true --kubeconfig ${KIND_KUBECONFIG}
helm install submariner-operator chart-museum/submariner-operator ${HELM_MUST_OPTION} \
        --create-namespace \
        --namespace "${SUBMARINER_NS}" \
        --set submariner-operator.ipsec.psk="${SUBMARINER_PSK}" \
        --set submariner-operator.broker.server="${SUBMARINER_BROKER_URL}" \
        --set submariner-operator.broker.token="${SUBMARINER_BROKER_TOKEN}" \
        --set submariner-operator.broker.namespace="${BROKER_NS}" \
        --set submariner-operator.broker.ca="${SUBMARINER_BROKER_CA}" \
        --set submariner-operator.broker.globalnet=true \
        --set submariner-operator.submariner.serviceDiscovery=true \
        --set submariner-operator.submariner.cableDriver=libreswan \
        --set submariner-operator.submariner.clusterId="${CLUSTER_ID}" \
        --set submariner-operator.submariner.clusterCidr="${CLUSTER_CIDR}" \
        --set submariner-operator.submariner.serviceCidr="${SERVICE_CIDR}" \
        --set submariner-operator.submariner.globalCidr="244.0.0.0/24" \
        --set submariner.natEnabled=false \
        --set submariner-operator.serviceAccounts.globalnet.create=true \
        --set submariner-operator.serviceAccounts.lighthouseAgent.create=true \
        --set submariner-operator.serviceAccounts.lighthouseCoreDns.create=true

# wait pod ready
app_list=(
  submariner-gateway
  submariner-lighthouse-agent
  submariner-lighthouse-coredns
  submariner-routeagent
)

sleep 20

res=0
for app in ${app_list[@]}; do
  kubectl wait --for=condition=ready -l app=${app} --timeout=300s pod -n ${SUBMARINER_NS} --kubeconfig ${KIND_KUBECONFIG} || res=1
done

if ((res==0)) ; then
  echo "succeeded to deploy submariner"
  exit 0
else
  echo "error, failed to deploy submariner"
  exit ${res}
fi

