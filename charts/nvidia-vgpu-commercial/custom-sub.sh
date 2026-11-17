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

echo "custom-sub.sh - 处理子 chart charts/hami/values.yaml"

#=================== DCE 定制配置 ===================
# 1) 资源名改为 nvidia.com/vgpu
yq -i '.devices.nvidia.resourceCountName="nvidia.com/vgpu"' charts/hami/values.yaml

# 1.1) 设置 nvidiaNodeSelector
yq -i '.devicePlugin.nvidiaNodeSelector = {"nvidia.com/vgpu.deploy.device-plugin": "true"}' charts/hami/values.yaml

# 2) kube-scheduler 镜像仓库
yq -i '
  .scheduler.kubeScheduler.image.registry = "k8s-gcr.m.daocloud.io" |
  .scheduler.kubeScheduler.image.repository = "kubernetes/kube-scheduler"
' charts/hami/values.yaml

# relok8s requires a values reference for each tag it relocates.
yq -i '.scheduler.kubeScheduler.compatibility = {
  "kube_gte_118": "v1.18.20",
  "kube_gte_120": "v1.20.0",
  "kube_gte_122": "v1.22.0",
  "kube_gte_124": "v1.24.0",
  "kube_gte_126": "v1.26.0",
  "kube_gte_128": "v1.28.0",
  "kube_gte_130": "v1.30.0",
  "kube_gte_132": "v1.32.0",
  "kube_gte_134": "v1.34.0"
}' charts/hami/values.yaml
yq -i '.hami.scheduler.kubeScheduler.compatibility = load("charts/hami/values.yaml").scheduler.kubeScheduler.compatibility' values.yaml

# Select one offline image for each pair of Kubernetes minors. Explicit tags
# and OpenShift retain precedence, and newer clusters use the upstream tag.
SCHEDULER_HELPERS=charts/hami/templates/_helpers.tpl
tmp_helpers=$(mktemp)
awk '
  /^{{- include "strippedKubeVersion" . \| trim -}}$/ {
    if (in_scheduler_tag) {
      print "{{- $minor := regexReplaceAll \"[^0-9]\" .Capabilities.KubeVersion.Minor \"\" | int -}}"
      print "{{- $imageMinor := sub $minor (mod $minor 2) -}}"
      print "{{- $compatibility := .Values.scheduler.kubeScheduler.compatibility | default dict -}}"
      print "{{- $offlineTag := index $compatibility (printf \"kube_gte_1%02d\" $imageMinor) -}}"
      print "{{- if and (eq .Capabilities.KubeVersion.Major \"1\") $offlineTag -}}"
      print "{{- $offlineTag | trim -}}"
      print "{{- else -}}"
      print
      print "{{- end -}}"
      in_scheduler_tag = 0
      next
    }
  }
  /^{{- define "resolvedKubeSchedulerTag" -}}$/ { in_scheduler_tag = 1 }
  { print }
' "$SCHEDULER_HELPERS" > "$tmp_helpers"
mv "$tmp_helpers" "$SCHEDULER_HELPERS"

# 3) extender 镜像 registry（原 ghcr.io，仓库名保持不变）
yq -i '.scheduler.extender.image.registry = "ghcr.m.daocloud.io"' charts/hami/values.yaml

# 4) devicePlugin 与 monitor 镜像 registry（原 ghcr.io）
yq -i '
  .devicePlugin.image.registry = "ghcr.m.daocloud.io" |
  .devicePlugin.monitor.image.registry = "ghcr.m.daocloud.io"
' charts/hami/values.yaml

yq -i '
  .mockDevicePlugin.image.registry = "docker.m.daocloud.io" |
  .mockDevicePlugin.image.tag |= (split("@") | .[0])
' charts/hami/values.yaml

# 6) webhook patch 镜像 imageNew（registry/repository/tag）
yq -i '
  .scheduler.patch.imageNew.registry = "k8s.m.daocloud.io" |
  .scheduler.patch.imageNew.repository = "ingress-nginx/kube-webhook-certgen" |
  .scheduler.patch.imageNew.tag = "v1.6.9"
' charts/hami/values.yaml

#=================== resources 默认值 ===================
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
  .devicePlugin.monitor.resources.limits.cpu = "500m" |
  .devicePlugin.monitor.resources.limits.memory = "720Mi" |
  .devicePlugin.monitor.resources.requests.cpu = "100m" |
  .devicePlugin.monitor.resources.requests.memory = "128Mi"
' charts/hami/values.yaml

#=================== 添加 edition 标签到 scheduler deployment ===================
SCHEDULER_DEPLOYMENT="charts/hami/templates/scheduler/deployment.yaml"
echo "为 scheduler deployment 添加 gpu.kpanda.io/hami-edition: commercial 标签"

if [ "$os" = "Darwin" ]; then
  # macOS sed 需要 -i ''
  sed -i '' '/^    app.kubernetes.io\/component: hami-scheduler$/a\
    gpu.kpanda.io/hami-edition: commercial
' "$SCHEDULER_DEPLOYMENT"
else
  # Linux sed
  sed -i '/^    app.kubernetes.io\/component: hami-scheduler$/a\    gpu.kpanda.io/hami-edition: commercial' "$SCHEDULER_DEPLOYMENT"
fi

#=================== ServiceMonitor 默认关闭 ===================
yq -i '.scheduler.serviceMonitor.enable=false' charts/hami/values.yaml

#=================== 添加 vdcu (Hygon) 模板 ===================
echo "添加 vdcu 模板"
cp ../parent/charts/hami/templates/k8s-dcu-label-node.yaml charts/hami/templates/device-plugin/k8s-dcu-label-node.yaml
cp ../parent/charts/hami/templates/k8s-dcu-plugin-hami.yaml charts/hami/templates/device-plugin/k8s-dcu-plugin-hami.yaml
cp ../parent/charts/hami/templates/vdcu-admission-webhook.yaml charts/hami/templates/device-plugin/vdcu-admission-webhook.yaml
cp ../parent/charts/hami/templates/vdcu-scheduler.yaml charts/hami/templates/device-plugin/vdcu-scheduler.yaml
cp ../parent/charts/hami/templates/dcu-exporter.yaml charts/hami/templates/device-plugin/dcu-exporter.yaml

# 注入 vdcu 镜像默认值
yq -i '
  .devices.vdcu.enabled = false |
  .devices.vdcu.labelNode.image = "'"${VDCU_LABEL_NODE_IMAGE}"'" |
  .devices.vdcu.devicePlugin.image = "'"${VDCU_DEVICE_PLUGIN_IMAGE}"'" |
  .devices.vdcu.admissionWebhook.image = "'"${VDCU_ADMISSION_WEBHOOK_IMAGE}"'" |
  .devices.vdcu.scheduler.image = "'"${VDCU_SCHEDULER_IMAGE}"'" |
  .devices.vdcu.exporter.image = "'"${VDCU_EXPORTER_IMAGE}"'" |
  .devices.vdcu.exporter.version = "'"${VDCU_EXPORTER_VERSION}"'" |
  .devices.vdcu.exporter.port = '"${VDCU_EXPORTER_PORT}"' |
  .devices.vdcu.cleanupHook.image = "'"${VDCU_CLEANUP_HOOK_IMAGE}"'"
' charts/hami/values.yaml

# 注入 dcu-exporter 卷挂载默认值（kubeletPath / extraHostVolumes / extraVolumeMounts）
yq -i '
  .devices.vdcu.exporter.kubeletPath = "/var/lib/kubelet" |
  .devices.vdcu.exporter.extraHostVolumes = [
    {"name":"kfd","hostPath":"/dev/kfd"},
    {"name":"mkfd","hostPath":"/dev/mkfd"},
    {"name":"dri","hostPath":"/dev/dri"},
    {"name":"hostname","hostPath":"/etc/hostname"},
    {"name":"vdev","hostPath":"/etc/vdev"},
    {"name":"hyhal","hostPath":"/opt/hyhal"}
  ] |
  .devices.vdcu.exporter.extraVolumeMounts = [
    {"name":"kfd","readOnly":true,"mountPath":"/dev/kfd"},
    {"name":"mkfd","readOnly":true,"mountPath":"/dev/mkfd"},
    {"name":"dri","readOnly":true,"mountPath":"/dev/dri"},
    {"name":"hostname","readOnly":true,"mountPath":"/etc/hostname"},
    {"name":"vdev","readOnly":true,"mountPath":"/etc/vdev"},
    {"name":"hyhal","readOnly":true,"mountPath":"/opt/hyhal"}
  ]
' charts/hami/values.yaml

#=================== 添加 ServiceMonitor 模板 ===================
echo "添加 ServiceMonitor 模板"
cp ../parent/charts/hami/templates/vgpu-servicemonitor-device-plugin.yaml charts/hami/templates/device-plugin/dce-servicemonitor.yaml
cp ../parent/charts/hami/templates/vgpu-servicemonitor.yaml charts/hami/templates/scheduler/dce-servicemonitor.yaml

echo "custom-sub.sh 完成"
