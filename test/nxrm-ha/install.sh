#!/bin/bash

CURRENT_FILENAME=$( basename $0 )
CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

KIND_KUBECONFIG=$1

[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

helm repo update chart-museum  --kubeconfig ${KIND_KUBECONFIG}
HELM_MUST_OPTION=" --timeout 30m0s --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice , prometheus CRD has been deployed , so you no need to =============

set -x

# deploy nxrm-ha
# github action allocated CPU and Memory are insufficient to start nxrm-ha
helm install nxrm-ha chart-museum/nxrm-ha ${HELM_MUST_OPTION} \
  --namespace nxrm-ha --create-namespace --set nxrm-ha.statefulset.replicaCount=1 \
  --set nxrm-ha.statefulset.initContainers[0].resources.limits.cpu="0m" \
  --set nxrm-ha.statefulset.initContainers[0].resources.limits.memory="0Gi" \
  --set nxrm-ha.statefulset.initContainers[0].resources.requests.cpu="0m" \
  --set nxrm-ha.statefulset.initContainers[0].resources.requests.memory="0Gi" \
  --set nxrm-ha.statefulset.container.resources.limits.cpu="0m" \
  --set nxrm-ha.statefulset.container.resources.limits.memory="0Gi" \
  --set nxrm-ha.statefulset.container.resources.requests.cpu="0m" \
  --set nxrm-ha.statefulset.container.resources.requests.memory="0Gi" \
  --set nxrm-ha.statefulset.requestLogContainer.resources.limits.cpu="0m" \
  --set nxrm-ha.statefulset.requestLogContainer.resources.limits.memory="0Gi" \
  --set nxrm-ha.statefulset.requestLogContainer.resources.requests.cpu="0m" \
  --set nxrm-ha.statefulset.requestLogContainer.resources.requests.memory="0Gi" \
  --set nxrm-ha.statefulset.auditLogContainer.resources.limits.cpu="0m" \
  --set nxrm-ha.statefulset.auditLogContainer.resources.limits.memory="0Gi" \
  --set nxrm-ha.statefulset.auditLogContainer.resources.requests.cpu="0m" \
  --set nxrm-ha.statefulset.auditLogContainer.resources.requests.memory="0Gi" \
  --set nxrm-ha.statefulset.taskLogContainer.resources.limits.cpu="0m" \
  --set nxrm-ha.statefulset.taskLogContainer.resources.limits.memory="0Gi" \
  --set nxrm-ha.statefulset.taskLogContainer.resources.requests.cpu="0m" \
  --set nxrm-ha.statefulset.taskLogContainer.resources.requests.memory="0Gi" \
  --set nxrm-ha.secret.dbSecret.enabled=true \
  --set nxrm-ha.secret.nexusAdminSecret.enabled=true

helm test nxrm-ha -n nxrm-ha --kubeconfig ${KIND_KUBECONFIG}

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, faild to deploy $CHART_DIR"
    kubectl --kubeconfig ${KIND_KUBECONFIG} get pod -o wide -A
  exit 1
fi
