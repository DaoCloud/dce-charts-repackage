#!/bin/bash

# 获取脚本所在目录
script_path=$(cd "$(dirname "$0")"; pwd)

# 加载 config
source "${script_path}/config"

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd "$CHART_DIRECTORY"
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

set -x
set -o errexit
set -o nounset
set -o pipefail

os=$(uname)
echo "$os"

echo "custom.sh"

# 调用 custom-sub.sh 处理子 chart（传递绝对路径）
bash "${script_path}/custom-sub.sh" "$(pwd)"

#=================== 商业版特有配置（父 chart values.yaml）===================
# 资源名 + devicePlugin nodeSelector
yq -i '
  .hami.resourceName = "nvidia.com/vgpu" |
  .hami.devicePlugin.nvidiaNodeSelector = {"nvidia.com/vgpu.deploy.device-plugin": "true"}
' values.yaml

# kube-scheduler 镜像
yq -i '
  .hami.scheduler.kubeScheduler.image.registry = "k8s-gcr.m.daocloud.io" |
  .hami.scheduler.kubeScheduler.image.repository = "kubernetes/kube-scheduler" |
  .hami.scheduler.kubeScheduler.image.tag = "v1.28.0"
' values.yaml

# extender 镜像 registry（原 ghcr.io）
yq -i '.hami.scheduler.extender.image.registry = "ghcr.m.daocloud.io"' values.yaml

# devicePlugin 与 monitor 镜像 registry（原 ghcr.io）
yq -i '
  .hami.devicePlugin.image.registry = "ghcr.m.daocloud.io" |
  .hami.devicePlugin.monitor.image.registry = "ghcr.m.daocloud.io"
' values.yaml

# webhook patch 镜像
yq -i '
  .hami.scheduler.patch.image.registry = "docker.m.daocloud.io" |
  .hami.scheduler.patch.image.repository = "jettech/kube-webhook-certgen" |
  .hami.scheduler.patch.image.tag = "v1.5.2"
' values.yaml

# webhook patch 备用镜像（imageNew）
yq -i '
  .hami.scheduler.patch.imageNew.registry = "k8s.m.daocloud.io" |
  .hami.scheduler.patch.imageNew.repository = "ingress-nginx/kube-webhook-certgen" |
  .hami.scheduler.patch.imageNew.tag = "v1.6.9"
' values.yaml

# serviceMonitor 默认关闭
yq -i '.hami.scheduler.serviceMonitor.enable=false' values.yaml

yq -i '.hami.mockDevicePlugin.image.registry = "docker.m.daocloud.io"' values.yaml

#=================== resources 默认值（父 chart） ===================
yq -i '
  .hami.scheduler.kubeScheduler.resources.limits.cpu = "500m" |
  .hami.scheduler.kubeScheduler.resources.limits.memory = "720Mi" |
  .hami.scheduler.kubeScheduler.resources.requests.cpu = "100m" |
  .hami.scheduler.kubeScheduler.resources.requests.memory = "128Mi"
' values.yaml

yq -i '
  .hami.scheduler.extender.resources.limits.cpu = "500m" |
  .hami.scheduler.extender.resources.limits.memory = "720Mi" |
  .hami.scheduler.extender.resources.requests.cpu = "100m" |
  .hami.scheduler.extender.resources.requests.memory = "128Mi"
' values.yaml

yq -i '
  .hami.devicePlugin.resources.limits.cpu = "500m" |
  .hami.devicePlugin.resources.limits.memory = "720Mi" |
  .hami.devicePlugin.resources.requests.cpu = "100m" |
  .hami.devicePlugin.resources.requests.memory = "128Mi"
' values.yaml

yq -i '
  .hami.devicePlugin.monitor.resources.limits.cpu = "500m" |
  .hami.devicePlugin.monitor.resources.limits.memory = "720Mi" |
  .hami.devicePlugin.monitor.resources.requests.cpu = "100m" |
  .hami.devicePlugin.monitor.resources.requests.memory = "128Mi"
' values.yaml

#=================== vdcu (Hygon) 默认值（父 chart） ===================
yq -i '
  .hami.devices.vdcu.enabled = false |
  .hami.devices.vdcu.labelNode.image = "'"${VDCU_LABEL_NODE_IMAGE}"'" |
  .hami.devices.vdcu.devicePlugin.image = "'"${VDCU_DEVICE_PLUGIN_IMAGE}"'" |
  .hami.devices.vdcu.admissionWebhook.image = "'"${VDCU_ADMISSION_WEBHOOK_IMAGE}"'" |
  .hami.devices.vdcu.scheduler.image = "'"${VDCU_SCHEDULER_IMAGE}"'" |
  .hami.devices.vdcu.exporter.image = "'"${VDCU_EXPORTER_IMAGE}"'" |
  .hami.devices.vdcu.exporter.version = "'"${VDCU_EXPORTER_VERSION}"'" |
  .hami.devices.vdcu.exporter.port = '"${VDCU_EXPORTER_PORT}"' |
  .hami.devices.vdcu.cleanupHook.image = "'"${VDCU_CLEANUP_HOOK_IMAGE}"'"
' values.yaml

# dcu-exporter 卷挂载默认值（kubeletPath / extraHostVolumes / extraVolumeMounts）
yq -i '
  .hami.devices.vdcu.exporter.kubeletPath = "/var/lib/kubelet" |
  .hami.devices.vdcu.exporter.extraHostVolumes = [
    {"name":"kfd","hostPath":"/dev/kfd"},
    {"name":"mkfd","hostPath":"/dev/mkfd"},
    {"name":"dri","hostPath":"/dev/dri"},
    {"name":"hostname","hostPath":"/etc/hostname"},
    {"name":"vdev","hostPath":"/etc/vdev"},
    {"name":"hyhal","hostPath":"/opt/hyhal"}
  ] |
  .hami.devices.vdcu.exporter.extraVolumeMounts = [
    {"name":"kfd","readOnly":true,"mountPath":"/dev/kfd"},
    {"name":"mkfd","readOnly":true,"mountPath":"/dev/mkfd"},
    {"name":"dri","readOnly":true,"mountPath":"/dev/dri"},
    {"name":"hostname","readOnly":true,"mountPath":"/etc/hostname"},
    {"name":"vdev","readOnly":true,"mountPath":"/etc/vdev"},
    {"name":"hyhal","readOnly":true,"mountPath":"/opt/hyhal"}
  ]
' values.yaml

#=================== Chart.yaml 定制 ===================
# Chart.yaml 已由 build.sh 生成（name/version/dependencies 都已正确设置）
# 这里只添加 icon 和清空 maintainers

# 设置 icon（父 chart）
yq -i '
    .icon="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNTAwIiBoZWlnaHQ9IjE4NDEiIHZpZXdCb3g9IjM1LjE4OCAzMS41MTIgMzUxLjQ2IDI1OC43ODUiPjx0aXRsZT5nZW5lcmF0ZWQgYnkgcHN0b2VkaXQgdmVyc2lvbjozLjQ0IGZyb20gTlZCYWRnZV8yRC5lcHM8L3RpdGxlPjxwYXRoIGQ9Ik0zODQuMTk1IDI4Mi4xMDljMCAzLjc3MS0yLjc2OSA2LjMwMi02LjA0NyA2LjMwMnYtLjAyM2MtMy4zNzEuMDIzLTYuMDg5LTIuNTA4LTYuMDg5LTYuMjc4IDAtMy43NjkgMi43MTgtNi4yOTMgNi4wODktNi4yOTMgMy4yNzktLjAwMSA2LjA0NyAyLjUyMyA2LjA0NyA2LjI5MnptMi40NTMgMGMwLTUuMTc2LTQuMDItOC4xOC04LjUtOC4xOC00LjUxMSAwLTguNTMxIDMuMDA0LTguNTMxIDguMTggMCA1LjE3MiA0LjAyMSA4LjE4OCA4LjUzMSA4LjE4OCA0LjQ4IDAgOC41LTMuMDE2IDguNS04LjE4OG0tOS45MS42OTJoLjkxbDIuMTA5IDMuNzAzaDIuMzE1bC0yLjMzNi0zLjg1OWMxLjIwNy0uMDg2IDIuMi0uNjYgMi4yLTIuMjg1IDAtMi4wMi0xLjM5My0yLjY2OC0zLjc1LTIuNjY4aC0zLjQxMXY4LjgxMmgxLjk2MWwuMDAyLTMuNzAzbTAtMS40OTJ2LTIuMTIxaDEuMzY0Yy43NDIgMCAxLjc1My4wNiAxLjc1My45NjUgMCAuOTg0LS41MjMgMS4xNTYtMS4zOTggMS4xNTZoLTEuNzE5TTMyOS40MDYgMjM3LjAyN2wxMC41OTggMjguOTkySDMxOC40OGwxMC45MjYtMjguOTkyem0tMTEuMzUtMTEuMjg5bC0yNC40MjMgNjEuODhoMTcuMjQ1bDMuODYzLTEwLjkzNWgyOC45MDNsMy42NTYgMTAuOTM1aDE4LjcyMmwtMjQuNjA1LTYxLjg4OC0yMy4zNjEuMDA4em0tNDkuMDMzIDYxLjkwM2gxNy40OTd2LTYxLjkyMmwtMTcuNS0uMDA0LjAwMyA2MS45MjZ6bS0xMjEuNDY3LTYxLjkyNmwtMTQuNTk4IDQ5LjA3OC0xMy45ODQtNDkuMDc0LTE4Ljg3OS0uMDA0IDE5Ljk3MiA2MS45MjZoMjUuMjA3bDIwLjEzMy02MS45MjZoLTE3Ljg1MXptNzAuNzI1IDEzLjQ4NGg3LjUyMWMxMC45MDkgMCAxNy45NjYgNC44OTggMTcuOTY2IDE3LjYwOSAwIDEyLjcxMy03LjA1NyAxNy42MTItMTcuOTY2IDE3LjYxMmgtNy41MjF2LTM1LjIyMXptLTE3LjM1LTEzLjQ4NHY2MS45MjZoMjguMzY1YzE1LjExMyAwIDIwLjA0OS0yLjUxMiAyNS4zODUtOC4xNDcgMy43NjktMy45NTcgNi4yMDctMTIuNjQyIDYuMjA3LTIyLjEzNCAwLTguNzA3LTIuMDYzLTE2LjQ2OS01LjY2LTIxLjMwNS02LjQ4LTguNjQ4LTE1LjgxNi0xMC4zNC0yOS43NS0xMC4zNGgtMjQuNTQ3em0tMTY1Ljc0My0uMDg2djYyLjAxMmgxNy42NDV2LTQ3LjA4NmwxMy42NzIuMDA0YzQuNTI3IDAgNy43NTQgMS4xMjkgOS45MzQgMy40NTcgMi43NjUgMi45NDUgMy44OTQgNy42OTkgMy44OTQgMTYuMzk2djI3LjIyOWgxNy4wOTh2LTM0LjI2MmMwLTI0LjQ1My0xNS41ODYtMjcuNzUtMzAuODM2LTI3Ljc1SDM1LjE4OHptMTM3LjU4My4wODZsLjAwNyA2MS45MjZoMTcuNDg5di02MS45MjZoLTE3LjQ5NnoiLz48cGF0aCBkPSJNODIuMjExIDEwMi40MTRzMjIuNTA0LTMzLjIwMyA2Ny40MzctMzYuNjM4VjUzLjczYy00OS43NjkgMy45OTctOTIuODY3IDQ2LjE0OS05Mi44NjcgNDYuMTQ5czI0LjQxIDcwLjU2NCA5Mi44NjcgNzcuMDI2di0xMi44MDRjLTUwLjIzNy02LjMyLTY3LjQzNy02MS42ODctNjcuNDM3LTYxLjY4N3ptNjcuNDM3IDM2LjIyM3YxMS43MjdjLTM3Ljk2OC02Ljc3LTQ4LjUwNy00Ni4yMzctNDguNTA3LTQ2LjIzN3MxOC4yMy0yMC4xOTUgNDguNTA3LTIzLjQ3djEyLjg2N2MtLjAyMyAwLS4wMzktLjAwNy0uMDU4LS4wMDctMTUuODkxLTEuOTA3LTI4LjMwNSAxMi45MzgtMjguMzA1IDEyLjkzOHM2Ljk1OCAyNC45OSAyOC4zNjMgMzIuMTgybTAtMTA3LjEyNVY1My43M2MxLjQ2MS0uMTEyIDIuOTIyLS4yMDcgNC4zOTEtLjI1NyA1Ni41ODItMS45MDcgOTMuNDQ5IDQ2LjQwNiA5My40NDkgNDYuNDA2cy00Mi4zNDMgNTEuNDg4LTg2LjQ1NyA1MS40ODhjLTQuMDQzIDAtNy44MjgtLjM3NS0xMS4zODMtMS4wMDV2MTMuNzM5YTc1LjA0IDc1LjA0IDAgMCAwIDkuNDgxLjYxMmM0MS4wNTEgMCA3MC43MzgtMjAuOTY1IDk5LjQ4NC00NS43NzggNC43NjYgMy44MTcgMjQuMjc4IDEzLjEwMyAyOC4yODkgMTcuMTY3LTI3LjMzMiAyMi44ODQtOTEuMDMxIDQxLjMzLTEyNy4xNDQgNDEuMzMtMy40ODEgMC02LjgyNC0uMjExLTEwLjExLS41Mjh2MTkuMzA2SDMwNS42OFYzMS41MTJIMTQ5LjY0OHptMCA0OS4xNDRWNjUuNzc3YzEuNDQ2LS4xMDEgMi45MDMtLjE3OSA0LjM5MS0uMjI2IDQwLjY4OC0xLjI3OCA2Ny4zODIgMzQuOTY1IDY3LjM4MiAzNC45NjVzLTI4LjgzMiA0MC4wNDItNTkuNzQ2IDQwLjA0MmMtNC40NDkgMC04LjQzOC0uNzE1LTEyLjAyOC0xLjkyMlY5My41MjNjMTUuODQgMS45MTQgMTkuMDI4IDguOTExIDI4LjU1MSAyNC43ODZsMjEuMTgxLTE3Ljg1OXMtMTUuNDYxLTIwLjI3Ny00MS41MjQtMjAuMjc3Yy0yLjgzNC0uMDAxLTUuNTQ1LjE5OC04LjIwNy40ODMiIGZpbGw9IiM3N2I5MDAiLz48L3N2Zz4="
' Chart.yaml

# 设置 icon（子 chart）
yq -i '
    .icon="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNTAwIiBoZWlnaHQ9IjE4NDEiIHZpZXdCb3g9IjM1LjE4OCAzMS41MTIgMzUxLjQ2IDI1OC43ODUiPjx0aXRsZT5nZW5lcmF0ZWQgYnkgcHN0b2VkaXQgdmVyc2lvbjozLjQ0IGZyb20gTlZCYWRnZV8yRC5lcHM8L3RpdGxlPjxwYXRoIGQ9Ik0zODQuMTk1IDI4Mi4xMDljMCAzLjc3MS0yLjc2OSA2LjMwMi02LjA0NyA2LjMwMnYtLjAyM2MtMy4zNzEuMDIzLTYuMDg5LTIuNTA4LTYuMDg5LTYuMjc4IDAtMy43NjkgMi43MTgtNi4yOTMgNi4wODktNi4yOTMgMy4yNzktLjAwMSA2LjA0NyAyLjUyMyA2LjA0NyA2LjI5MnptMi40NTMgMGMwLTUuMTc2LTQuMDItOC4xOC04LjUtOC4xOC00LjUxMSAwLTguNTMxIDMuMDA0LTguNTMxIDguMTggMCA1LjE3MiA0LjAyMSA4LjE4OCA4LjUzMSA4LjE4OCA0LjQ4IDAgOC41LTMuMDE2IDguNS04LjE4OG0tOS45MS42OTJoLjkxbDIuMTA5IDMuNzAzaDIuMzE1bC0yLjMzNi0zLjg1OWMxLjIwNy0uMDg2IDIuMi0uNjYgMi4yLTIuMjg1IDAtMi4wMi0xLjM5My0yLjY2OC0zLjc1LTIuNjY4aC0zLjQxMXY4LjgxMmgxLjk2MWwuMDAyLTMuNzAzbTAtMS40OTJ2LTIuMTIxaDEuMzY0Yy43NDIgMCAxLjc1My4wNiAxLjc1My45NjUgMCAuOTg0LS41MjMgMS4xNTYtMS4zOTggMS4xNTZoLTEuNzE5TTMyOS40MDYgMjM3LjAyN2wxMC41OTggMjguOTkySDMxOC40OGwxMC45MjYtMjguOTkyem0tMTEuMzUtMTEuMjg5bC0yNC40MjMgNjEuODhoMTcuMjQ1bDMuODYzLTEwLjkzNWgyOC45MDNsMy42NTYgMTAuOTM1aDE4LjcyMmwtMjQuNjA1LTYxLjg4OC0yMy4zNjEuMDA4em0tNDkuMDMzIDYxLjkwM2gxNy40OTd2LTYxLjkyMmwtMTcuNS0uMDA0LjAwMyA2MS45MjZ6bS0xMjEuNDY3LTYxLjkyNmwtMTQuNTk4IDQ5LjA3OC0xMy45ODQtNDkuMDc0LTE4Ljg3OS0uMDA0IDE5Ljk3MiA2MS45MjZoMjUuMjA3bDIwLjEzMy02MS45MjZoLTE3Ljg1MXptNzAuNzI1IDEzLjQ4NGg3LjUyMWMxMC45MDkgMCAxNy45NjYgNC44OTggMTcuOTY2IDE3LjYwOSAwIDEyLjcxMy03LjA1NyAxNy42MTItMTcuOTY2IDE3LjYxMmgtNy41MjF2LTM1LjIyMXptLTE3LjM1LTEzLjQ4NHY2MS45MjZoMjguMzY1YzE1LjExMyAwIDIwLjA0OS0yLjUxMiAyNS4zODUtOC4xNDcgMy43NjktMy45NTcgNi4yMDctMTIuNjQyIDYuMjA3LTIyLjEzNCAwLTguNzA3LTIuMDYzLTE2LjQ2OS01LjY2LTIxLjMwNS02LjQ4LTguNjQ4LTE1LjgxNi0xMC4zNC0yOS43NS0xMC4zNGgtMjQuNTQ3em0tMTY1Ljc0My0uMDg2djYyLjAxMmgxNy42NDV2LTQ3LjA4NmwxMy42NzIuMDA0YzQuNTI3IDAgNy43NTQgMS4xMjkgOS45MzQgMy40NTcgMi43NjUgMi45NDUgMy44OTQgNy42OTkgMy44OTQgMTYuMzk2djI3LjIyOWgxNy4wOTh2LTM0LjI2MmMwLTI0LjQ1My0xNS41ODYtMjcuNzUtMzAuODM2LTI3Ljc1SDM1LjE4OHptMTM3LjU4My4wODZsLjAwNyA2MS45MjZoMTcuNDg5di02MS45MjZoLTE3LjQ5NnoiLz48cGF0aCBkPSJNODIuMjExIDEwMi40MTRzMjIuNTA0LTMzLjIwMyA2Ny40MzctMzYuNjM4VjUzLjczYy00OS43NjkgMy45OTctOTIuODY3IDQ2LjE0OS05Mi44NjcgNDYuMTQ5czI0LjQxIDcwLjU2NCA5Mi44NjcgNzcuMDI2di0xMi44MDRjLTUwLjIzNy02LjMyLTY3LjQzNy02MS42ODctNjcuNDM3LTYxLjY4N3ptNjcuNDM3IDM2LjIyM3YxMS43MjdjLTM3Ljk2OC02Ljc3LTQ4LjUwNy00Ni4yMzctNDguNTA3LTQ2LjIzN3MxOC4yMy0yMC4xOTUgNDguNTA3LTIzLjQ3djEyLjg2N2MtLjAyMyAwLS4wMzktLjAwNy0uMDU4LS4wMDctMTUuODkxLTEuOTA3LTI4LjMwNSAxMi45MzgtMjguMzA1IDEyLjkzOHM2Ljk1OCAyNC45OSAyOC4zNjMgMzIuMTgybTAtMTA3LjEyNVY1My43M2MxLjQ2MS0uMTEyIDIuOTIyLS4yMDcgNC4zOTEtLjI1NyA1Ni41ODItMS45MDcgOTMuNDQ5IDQ2LjQwNiA5My40NDkgNDYuNDA2cy00Mi4zNDMgNTEuNDg4LTg2LjQ1NyA1MS40ODhjLTQuMDQzIDAtNy44MjgtLjM3NS0xMS4zODMtMS4wMDV2MTMuNzM5YTc1LjA0IDc1LjA0IDAgMCAwIDkuNDgxLjYxMmM0MS4wNTEgMCA3MC43MzgtMjAuOTY1IDk5LjQ4NC00NS43NzggNC43NjYgMy44MTcgMjQuMjc4IDEzLjEwMyAyOC4yODkgMTcuMTY3LTI3LjMzMiAyMi44ODQtOTEuMDMxIDQxLjMzLTEyNy4xNDQgNDEuMzMtMy40ODEgMC02LjgyNC0uMjExLTEwLjExLS41Mjh2MTkuMzA2SDMwNS42OFYzMS41MTJIMTQ5LjY0OHptMCA0OS4xNDRWNjUuNzc3YzEuNDQ2LS4xMDEgMi45MDMtLjE3OSA0LjM5MS0uMjI2IDQwLjY4OC0xLjI3OCA2Ny4zODIgMzQuOTY1IDY3LjM4MiAzNC45NjVzLTI4LjgzMiA0MC4wNDItNTkuNzQ2IDQwLjA0MmMtNC40NDkgMC04LjQzOC0uNzE1LTEyLjAyOC0xLjkyMlY5My41MjNjMTUuODQgMS45MTQgMTkuMDI4IDguOTExIDI4LjU1MSAyNC43ODZsMjEuMTgxLTE3Ljg1OXMtMTUuNDYxLTIwLjI3Ny00MS41MjQtMjAuMjc3Yy0yLjgzNC0uMDAxLTUuNTQ1LjE5OC04LjIwNy40ODMiIGZpbGw9IiM3N2I5MDAiLz48L3N2Zz4="
' charts/hami/Chart.yaml

# 清空 maintainers
yq -i '.maintainers=[]' charts/hami/Chart.yaml

yq -i '
    .maintainers=[]
' Chart.yaml