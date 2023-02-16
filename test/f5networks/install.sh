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

kubectl get storageclass  --kubeconfig ${KIND_KUBECONFIG}
kubectl get POD -A -o wide   --kubeconfig ${KIND_KUBECONFIG}

KIND_STROAGECLASS=` kubectl get storageclass | grep -v "NAME" | awk '{print $1}' `
[ -n "${KIND_STROAGECLASS}" ] || { echo "error, failed to find any storageclass " ; exit 1 ; }


helm install f5networks chart-museum/f5networks  ${HELM_MUST_OPTION} \
  --namespace kube-public \
  --set f5-bigip-ctlr.args.bigip_url=https://172.17.8.10:10443 \
  --set f5-bigip-ctlr.args.bigip_partition="kubernetes" \
  --set f5-bigip-ctlr.args.pool_member_type=nodeport \
  --set f5-ipam-controller.args.ip_range='"{\"welanipam\":\"10.0.2.100-10.0.2.200\"}"' \
  --set f5-ipam-controller.pvc.storageClassName="${KIND_STROAGECLASS}" \
  --set cis-secret.username="admin" \
  --set cis-secret.password="admin"


if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, faild to deploy $CHART_DIR"
  exit 1
fi
