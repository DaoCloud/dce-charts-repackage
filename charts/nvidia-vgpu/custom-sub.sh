#! /bin/bash
CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================
#===============================

set -x
set -o errexit
set -o nounset
set -o pipefail

os=$(uname)
echo $os

echo "custom-sub.sh"

# 1) 资源名改为 vgpu
yq -i '.resourceName="nvidia.com/vgpu"' charts/hami/values.yaml


# 2) kube-scheduler 镜像信息（registry/repository/tag）
yq -i '
  .scheduler.kubeScheduler.image.registry = "k8s-gcr.m.daocloud.io" |
  .scheduler.kubeScheduler.image.repository = "kubernetes/kube-scheduler" |
  .scheduler.kubeScheduler.image.tag = "v1.28.0"
' charts/hami/values.yaml

# 3) extender 镜像 registry（仓库名保持不变）
yq -i '.scheduler.extender.image.registry = "docker.m.daocloud.io"' charts/hami/values.yaml

# 4) devicePlugin 与 monitor 镜像 registry
yq -i '
  .devicePlugin.image.registry = "docker.m.daocloud.io" |
  .devicePlugin.monitor.image.registry = "docker.m.daocloud.io"
' charts/hami/values.yaml

# 5) webhook patch 镜像（registry/repository/tag）
yq -i '
  .scheduler.patch.image.registry = "docker.m.daocloud.io" |
  .scheduler.patch.image.repository = "jettech/kube-webhook-certgen" |
  .scheduler.patch.image.tag = "v1.5.2"
' charts/hami/values.yaml

# 6) webhook patch 备用镜像 imageNew（registry/repository/tag）
yq -i '
  .scheduler.patch.imageNew.registry = "docker.m.daocloud.io" |
  .scheduler.patch.imageNew.repository = "liangjw/kube-webhook-certgen" |
  .scheduler.patch.imageNew.tag = "v1.1.1"
' charts/hami/values.yaml

#    同时为各处 resources 填充默认值（与之前保持一致）
yq -i '
  .scheduler.kubeScheduler.resources.limits.cpu = "500m" |
  .scheduler.kubeScheduler.resources.limits.memory = "720Mi" |
  .scheduler.kubeScheduler.resources.requests.cpu = "100m" |
  .scheduler.kubeScheduler.resources.requests.memory = "128Mi"
' charts/hami/values.yaml

yq -i '
  .scheduler.extender.resources.limits.cpu = "500m" |
  .scheduler.extender.resources.limits.memory = "720Mi" |
  .scheduler.extender.resources.requests.cpu = "100m" |
  .scheduler.extender.resources.requests.memory = "128Mi"
' charts/hami/values.yaml

yq -i '
  .devicePlugin.resources.limits.cpu = "500m" |
  .devicePlugin.resources.limits.memory = "720Mi" |
  .devicePlugin.resources.requests.cpu = "100m" |
  .devicePlugin.resources.requests.memory = "128Mi"
' charts/hami/values.yaml

yq -i '
  .devicePlugin.vgpuMonitor.resources.limits.cpu = "500m" |
  .devicePlugin.vgpuMonitor.resources.limits.memory = "720Mi" |
  .devicePlugin.vgpuMonitor.resources.requests.cpu = "100m" |
  .devicePlugin.vgpuMonitor.resources.requests.memory = "128Mi"
' charts/hami/values.yaml

yq -i '
  .devicePlugin.monitor.resources.limits.cpu = "500m" |
  .devicePlugin.monitor.resources.limits.memory = "720Mi" |
  .devicePlugin.monitor.resources.requests.cpu = "100m" |
  .devicePlugin.monitor.resources.requests.memory = "128Mi"
' charts/hami/values.yaml
