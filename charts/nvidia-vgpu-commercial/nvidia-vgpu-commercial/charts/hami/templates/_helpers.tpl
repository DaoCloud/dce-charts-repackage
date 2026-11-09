{{/*
Expand the name of the chart.
*/}}
{{- define "hami-enterprise.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hami-enterprise.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "hami-enterprise.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
The app name for Scheduler
*/}}
{{- define "hami-enterprise.scheduler" -}}
{{- printf "%s-scheduler" ( include "hami-enterprise.fullname" . ) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The scheduler ServiceAccount username.
*/}}
{{- define "hami-enterprise.schedulerServiceAccountUsername" -}}
{{- printf "system:serviceaccount:%s:%s" (include "hami-enterprise.namespace" .) (include "hami-enterprise.scheduler" .) -}}
{{- end -}}

{{/*
The vNPU annotations protected on update.
*/}}
{{- define "hami-enterprise.vnpuProtectedAnnotationCELList" -}}
{{- $keys := list "huawei.com/vnpu-mode" -}}
{{- $deviceConfig := index .Values "device-config" -}}
{{- $customContent := "" -}}
{{- if $deviceConfig -}}
{{- $customContent = (index $deviceConfig "content") | default "" -}}
{{- end -}}
{{- if not $customContent -}}
{{- if .Files.Glob "files/device-config.yaml" -}}
{{- $customContent = .Files.Get "files/device-config.yaml" -}}
{{- end -}}
{{- end -}}
{{- if $customContent -}}
{{- $parsed := fromYaml $customContent -}}
{{- with $parsed.vnpus -}}
{{- range .configs -}}
{{- if .commonWord -}}
{{- $keys = append $keys (printf "hami.io/%s-devices-allocated" .commonWord) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- else -}}
{{- range (list "Ascend910A" "Ascend910B2" "Ascend910B3" "Ascend910B4-1" "Ascend910B4" "Ascend310P" "Ascend910C") -}}
{{- $keys = append $keys (printf "hami.io/%s-devices-allocated" .) -}}
{{- end -}}
{{- end -}}
{{- $keys | uniq | sortAlpha | toJson -}}
{{- end -}}

{{/*
The vNPU annotations reserved on create.
*/}}
{{- define "hami-enterprise.vnpuCreateReservedAnnotationCELList" -}}
{{- $keys := list -}}
{{- $deviceConfig := index .Values "device-config" -}}
{{- $customContent := "" -}}
{{- if $deviceConfig -}}
{{- $customContent = (index $deviceConfig "content") | default "" -}}
{{- end -}}
{{- if not $customContent -}}
{{- if .Files.Glob "files/device-config.yaml" -}}
{{- $customContent = .Files.Get "files/device-config.yaml" -}}
{{- end -}}
{{- end -}}
{{- if $customContent -}}
{{- $parsed := fromYaml $customContent -}}
{{- with $parsed.vnpus -}}
{{- range .configs -}}
{{- if .commonWord -}}
{{- $keys = append $keys (printf "hami.io/%s-devices-allocated" .commonWord) -}}
{{- $keys = append $keys (printf "hami.io/%s-devices-try-allocate" .commonWord) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- else -}}
{{- range (list "Ascend910A" "Ascend910B2" "Ascend910B3" "Ascend910B4-1" "Ascend910B4" "Ascend310P" "Ascend910C") -}}
{{- $keys = append $keys (printf "hami.io/%s-devices-allocated" .) -}}
{{- $keys = append $keys (printf "hami.io/%s-devices-try-allocate" .) -}}
{{- end -}}
{{- end -}}
{{- $keys | uniq | sortAlpha | toJson -}}
{{- end -}}

{{/*
The app name for DevicePlugin
*/}}
{{- define "hami-enterprise.device-plugin" -}}
{{- printf "%s-device-plugin" ( include "hami-enterprise.fullname" . ) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
  The app name for MockDevicePlugin
  */}}
{{- define "hami-enterprise.mock-device-plugin" -}}
{{- printf "%s-mock-device-plugin" ( include "hami-enterprise.fullname" . ) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The tls secret name for Scheduler
*/}}
{{- define "hami-enterprise.scheduler.tls" -}}
{{- printf "%s-scheduler-tls" ( include "hami-enterprise.fullname" . ) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The webhook name
*/}}
{{- define "hami-enterprise.scheduler.webhook" -}}
{{- printf "%s-webhook" ( include "hami-enterprise.fullname" . ) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hami-enterprise.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hami-enterprise.labels" -}}
helm.sh/chart: {{ include "hami-enterprise.chart" . }}
{{ include "hami-enterprise.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hami-enterprise.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hami-enterprise.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Existing Enterprise controllers need their immutable hami/hami selectors on upgrade.
*/}}
{{- define "hami-enterprise.workloadSelectorLabels" -}}
{{- if .Values.legacySelectorLabels -}}
app.kubernetes.io/name: hami
app.kubernetes.io/instance: hami
{{- else -}}
{{ include "hami-enterprise.selectorLabels" . }}
{{- end }}
{{- end }}

{{- define "hami-enterprise.schedulerSelectorLabels" -}}
{{ include "hami-enterprise.workloadSelectorLabels" . }}
{{- end }}

{{/*
Common labels for scheduler resources, including their selector identity.
*/}}
{{- define "hami-enterprise.schedulerLabels" -}}
helm.sh/chart: {{ include "hami-enterprise.chart" . }}
{{ include "hami-enterprise.schedulerSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "hami-enterprise.devicePluginSelectorLabels" -}}
{{ include "hami-enterprise.workloadSelectorLabels" . }}
{{- end }}

{{/*
Common labels for device-plugin resources, including their selector identity.
*/}}
{{- define "hami-enterprise.devicePluginLabels" -}}
helm.sh/chart: {{ include "hami-enterprise.chart" . }}
{{ include "hami-enterprise.devicePluginSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
    Resolve the tag for kubeScheduler.
*/}}
{{- define "resolvedKubeSchedulerTag" -}}
{{- if .Values.scheduler.kubeScheduler.image.tag }}
{{- .Values.scheduler.kubeScheduler.image.tag | trim -}}
{{- else if and .Values.platform.openshift .Values.platform.openshiftVersion }}
{{- printf "v%s" (.Values.platform.openshiftVersion | trimPrefix "v" | trim) -}}
{{- else }}
{{- include "strippedKubeVersion" . | trim -}}
{{- end }}
{{- end }}

{{/*
    Resolve the registry for kubeScheduler.
*/}}
{{- define "resolvedKubeSchedulerRegistry" -}}
{{- if and .Values.platform.openshift .Values.platform.openshiftVersion -}}
registry.redhat.io
{{- else -}}
{{- .Values.scheduler.kubeScheduler.image.registry -}}
{{- end -}}
{{- end -}}

{{/*
    Resolve the repository for kubeScheduler.
*/}}
{{- define "resolvedKubeSchedulerRepository" -}}
{{- if and .Values.platform.openshift .Values.platform.openshiftVersion -}}
openshift4/ose-hyperkube-rhel9
{{- else -}}
{{- .Values.scheduler.kubeScheduler.image.repository -}}
{{- end -}}
{{- end -}}

{{/*
    Return the stripped Kubernetes version string by removing extra parts after semantic version number.
    v1.31.1+k3s1 -> v1.31.1
    v1.30.8-eks-2d5f260 -> v1.30.8
    v1.31.1 -> v1.31.1
*/}}
{{- define "strippedKubeVersion" -}}
{{ regexReplaceAll "^(v[0-9]+\\.[0-9]+\\.[0-9]+)(.*)$" .Capabilities.KubeVersion.Version "$1" }}
{{- end -}}

{{/*
  Per-component image tag takes precedence over global.imageTag (trimmed non-empty imageRoot.tag wins).
*/}}
{{- define "hami.imageTagOrGlobal" -}}
{{- .imageRoot.tag | default (and .global .global.imageTag) | default "" | toString | trim -}}
{{- end -}}

{{- define "hami.image" -}}
{{- $tag := include "hami.imageTagOrGlobal" . -}}
{{- include "common.images.image" (dict "imageRoot" .imageRoot "global" .global "tag" $tag) -}}
{{- end -}}

{{- define "hami.scheduler.kubeScheduler.image" -}}
{{- $imageRoot := dict "registry" (include "resolvedKubeSchedulerRegistry" . | trim) "repository" (include "resolvedKubeSchedulerRepository" . | trim) "tag" (include "resolvedKubeSchedulerTag" . | trim) -}}
{{ include "common.images.image" (dict "imageRoot" $imageRoot "global" .Values.global) }}
{{- end -}}

{{- define "hami.scheduler.extender.image" -}}
{{ include "hami.image" (dict "imageRoot" .Values.scheduler.extender.image "global" .Values.global) }}
{{- end -}}

{{- define "hami.devicePlugin.image" -}}
{{ include "hami.image" (dict "imageRoot" .Values.devicePlugin.image "global" .Values.global) }}
{{- end -}}

{{- define "hami.mockDevicePlugin.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.mockDevicePlugin.image "global" .Values.global "tag" .Values.mockDevicePlugin.tag) }}
{{- end -}}

{{- define "hami.devicePlugin.monitor.image" -}}
{{ include "hami.image" (dict "imageRoot" .Values.devicePlugin.monitor.image "global" .Values.global) }}
{{- end -}}

{{- define "hami.scheduler.patch.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.scheduler.patch.image "global" .Values.global) }}
{{- end -}}

{{- define "hami.scheduler.patch.new.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.scheduler.patch.imageNew "global" .Values.global) }}
{{- end -}}

{{- define "hami.scheduler.extender.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.scheduler.extender.image) "global" .Values.global) }}
{{- end -}}

{{- define "hami.scheduler.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.scheduler.kubeScheduler.image .Values.scheduler.extender.image) "global" .Values.global) }}
{{- end -}}

{{- define "hami.devicePlugin.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.devicePlugin.image) "global" .Values.global) }}
{{- end -}}

{{- define "hami.scheduler.patch.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.scheduler.patch.image) "global" .Values.global) }}
{{- end -}}

{{- define "hami.scheduler.patch.new.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.scheduler.patch.imageNew) "global" .Values.global) }}
{{- end -}}

{{/*
Get Kubernetes minor version as integer
*/}}
{{- define "hami-enterprise.k8sMinorVersion" -}}
{{- regexReplaceAll "[^0-9]" .Capabilities.KubeVersion.Minor "" | int -}}
{{- end -}}

{{/*
Check if K8s version >= 1.22 (uses KubeSchedulerConfiguration)
*/}}
{{- define "hami-enterprise.useNewSchedulerConfig" -}}
{{- ge (include "hami-enterprise.k8sMinorVersion" . | int) 22 -}}
{{- end -}}

{{/*
Managed resources list for scheduler extender
Returns a YAML list that can be used directly or converted to JSON via fromYaml | toJson
*/}}
{{- define "hami-enterprise.scheduler.managedResources" -}}
{{- $resources := list -}}
{{/* Core NVIDIA resources */}}
{{- $resources = append $resources (dict "name" .Values.resourceName "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.resourceMem "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.resourceCores "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.resourceMemPercentage "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.resourcePriority "ignoredByScheduler" true) -}}
{{/* MLU resources */}}
{{- $resources = append $resources (dict "name" .Values.mluResourceName "ignoredByScheduler" true) -}}
{{/* HCU resources */}}
{{- $resources = append $resources (dict "name" .Values.hcuResourceName "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.hcuResourceMem "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.hcuResourceCores "ignoredByScheduler" true) -}}
{{/* Metax resources */}}
{{- $resources = append $resources (dict "name" "metax-tech.com/gpu" "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.metaxResourceName "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.metaxResourceCore "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.metaxResourceMem "ignoredByScheduler" true) -}}
{{/* Alibaba PPU resources */}}
{{- if .Values.devices.alibaba.enabled -}}
{{- range .Values.devices.alibaba.customresources -}}
{{- $resources = append $resources (dict "name" . "ignoredByScheduler" true) -}}
{{- end -}}
{{- end -}}
{{/* Ascend resources */}}
{{- if .Values.devices.ascend.enabled -}}
{{- range .Values.devices.ascend.customresources -}}
{{- $resources = append $resources (dict "name" . "ignoredByScheduler" true) -}}
{{- end -}}
{{- end -}}
{{/* Mthreads resources */}}
{{- if .Values.devices.mthreads.enabled -}}
{{- range .Values.devices.mthreads.customresources -}}
{{- $resources = append $resources (dict "name" . "ignoredByScheduler" true) -}}
{{- end -}}
{{- end -}}
{{/* Enflame resources */}}
{{- if .Values.devices.enflame.enabled -}}
{{- range .Values.devices.enflame.customresources -}}
{{- $resources = append $resources (dict "name" . "ignoredByScheduler" true) -}}
{{- end -}}
{{- end -}}
{{/* Kunlun resources */}}
{{- if .Values.devices.kunlun.enabled -}}
{{- range .Values.devices.kunlun.customresources -}}
{{- $resources = append $resources (dict "name" . "ignoredByScheduler" true) -}}
{{- end -}}
{{- end -}}
{{/* AWS Neuron resources */}}
{{- range .Values.devices.awsneuron.customresources -}}
{{- $resources = append $resources (dict "name" . "ignoredByScheduler" true) -}}
{{- end -}}
{{/* Iluvatar resources */}}
{{- if .Values.devices.iluvatar.enabled -}}
{{- range .Values.devices.iluvatar.customresources -}}
{{- $resources = append $resources (dict "name" . "ignoredByScheduler" true) -}}
{{- end -}}
{{- end -}}
{{/* Vastai resources */}}
{{- if .Values.devices.vastai.enabled -}}
{{- range .Values.devices.vastai.customresources -}}
{{- $resources = append $resources (dict "name" . "ignoredByScheduler" true) -}}
{{- end -}}
{{- end -}}
{{/* Biren resources */}}
{{- if .Values.devices.biren.enabled -}}
{{- range .Values.devices.biren.customresources -}}
{{- $resources = append $resources (dict "name" . "ignoredByScheduler" true) -}}
{{- end -}}
{{- end -}}
{{/* AMD resources */}}
{{- range .Values.devices.amd.customresources -}}
{{- $resources = append $resources (dict "name" . "ignoredByScheduler" true) -}}
{{- end -}}
{{- toYaml $resources -}}
{{- end -}}
