#!/bin/bash

CURRENT_FILENAME=$( basename "$0" )
CURRENT_DIR_PATH=$(cd "$CURRENT_FILENAME" || exit; pwd)

KIND_KUBECONFIG=$1

[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

helm repo update chart-museum  --kubeconfig ${KIND_KUBECONFIG}
HELM_MUST_OPTION=" --timeout 10m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
set -x

# install nvidia-vgpu need node having Nvidia GPU card, so skip install
exit 0

# Label GPU nodes for the wrapper chart's scheduler and device plugin selectors.
kubectl label nodes --all nvidia.com/gpu.deploy.container-toolkit=true nvidia.com/vgpu.deploy.device-plugin=true --overwrite --kubeconfig ${KIND_KUBECONFIG}

# Deploy nvidia-vgpu. HAMi 2.11 GPU settings use hami.devices.nvidia.*.
helm install nvidia-vgpu chart-museum/nvidia-vgpu  ${HELM_MUST_OPTION}

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, faild to deploy $CHART_DIR"
    kubectl --kubeconfig ${KIND_KUBECONFIG} get pod -o wide -A

  exit 1
fi
