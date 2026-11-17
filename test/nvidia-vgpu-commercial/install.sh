#!/bin/bash
set -euo pipefail

# The CI kind cluster lacks GPUs. Check the packaged chart without deploying it.
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
chart="$script_dir/../../charts/nvidia-vgpu-commercial/nvidia-vgpu-commercial"

helm lint "$chart"
helm template nvidia-vgpu-commercial "$chart" --kube-version 1.34.0 >/dev/null
helm template nvidia-vgpu-commercial "$chart" --kube-version 1.34.0 --is-upgrade \
    --set hami.devices.vdcu.enabled=true \
    --set hami.scheduler.serviceMonitor.enable=true >/dev/null
