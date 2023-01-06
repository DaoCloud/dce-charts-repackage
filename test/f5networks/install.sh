#!/bin/bash

CURRENT_FILENAME=$( basename $0 )
CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

CHART_DIR=$1
KIND_KUBECONFIG=$2

[ -d "$CHART_DIR" ] || { echo "error, failed to find chart $CHART_DIR " ; exit 1 ; }
[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "CHART_DIR $CHART_DIR"
echo "KIND_KUBECONFIG $KIND_KUBECONFIG"

HELM_MUST_OPTION=" --timeout 10m0s  --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice , prometheus CRD has been deployed , so you no need to =============

set -x

helm install f5networks ${CHART_DIR}  ${HELM_MUST_OPTION} \
  --namespace kube-public \
  --set f5-bigip-ctlr.args.bigip_url=https://172.17.8.10:10443 \
  --set f5-bigip-ctlr.args.bigip_partition="kubernetes" \
  --set f5-bigip-ctlr.args.pool_member_type=nodeport \
  --set f5-ipam-controller.args.ip_range='"{\"welanipam\":\"10.0.2.100-10.0.2.200\"}"' \
  --set f5-ipam-controller.pvc.storageClassName="local-path" \
  --set cis-secret.username="admin" \
  --set cis-secret.password="admin"


if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, faild to deploy $CHART_DIR"
  exit 1
fi
