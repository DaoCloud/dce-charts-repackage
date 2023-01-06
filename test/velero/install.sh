#!/bin/bash

CURRENT_FILENAME=$( basename $0 )
CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

CHART_DIR=$1
KIND_KUBECONFIG=$2

[ -d "$CHART_DIR" ] || { echo "error, failed to find chart $CHART_DIR " ; exit 1 ; }
[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "CHART_DIR: $CHART_DIR"
echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

HELM_MUST_OPTION=" --timeout 5m0s --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice , prometheus CRD has been deployed , so you no need to =============

set -x

# deploy vpa
helm install velero ${CHART_DIR}  ${HELM_MUST_OPTION}  --namespace velero --create-namespace \
  --set velero.configuration.backupStorageLocation.name=default \
  --set velero.configuration.backupStorageLocation.provider=aws \
  --set velero.configuration.backupStorageLocation.bucket=velero \
  --set velero.configuration.volumeSnapshotLocation.name=default \
  --set velero.configuration.volumeSnapshotLocation.provider=aws \
  --set velero.configuration.provider=aws

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, faild to deploy $CHART_DIR"
  exit 1
fi
