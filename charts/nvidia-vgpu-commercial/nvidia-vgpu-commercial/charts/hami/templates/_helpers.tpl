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
Whether HAMi-core is disabled for whole-GPU containers, as a quoted bool.
Defaults to true; a plain `default true` pipe would swallow an explicit false.
*/}}
{{- define "hami-enterprise.disableHAMiCoreForWholeGPU" -}}
{{- if or (not (hasKey .Values.devicePlugin.monitor "disableHAMiCoreForWholeGPU")) .Values.devicePlugin.monitor.disableHAMiCoreForWholeGPU -}}"true"{{- else -}}"false"{{- end -}}
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
Resolve the scheduler tag while preserving the Enterprise OpenShift image contract.
*/}}
{{- define "resolvedKubeSchedulerTag" -}}
{{- if .Values.scheduler.kubeScheduler.image.tag }}
{{- .Values.scheduler.kubeScheduler.image.tag | trim -}}
{{- else if and .Values.platform.openshift .Values.platform.openshiftVersion }}
{{- printf "v%s" (.Values.platform.openshiftVersion | trim | trimPrefix "v") -}}
{{- else }}
{{- $minor := regexReplaceAll "[^0-9]" .Capabilities.KubeVersion.Minor "" | int -}}
{{- $imageMinor := sub $minor (mod $minor 2) -}}
{{- $compatibility := .Values.scheduler.kubeScheduler.compatibility | default dict -}}
{{- $offlineTag := index $compatibility (printf "kube_gte_1%02d" $imageMinor) -}}
{{- if and (eq .Capabilities.KubeVersion.Major "1") $offlineTag -}}
{{- $offlineTag | trim -}}
{{- else -}}
{{- include "strippedKubeVersion" . | trim -}}
{{- end -}}
{{- end }}
{{- end }}

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

{{- define "hami.scheduler.patch.new.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.scheduler.patch.imageNew "global" .Values.global) }}
{{- end -}}

{{- define "hami.scheduler.extender.imagePullSecrets" -}}
{{- $images := list .Values.scheduler.extender.image -}}
{{- if .Values.scheduler.kubeScheduler.enabled -}}
{{- $images = append $images .Values.scheduler.kubeScheduler.image -}}
{{- end -}}
{{ include "common.images.pullSecrets" (dict "images" $images "global" .Values.global) }}
{{- end -}}

{{- define "hami.devicePlugin.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.devicePlugin.image) "global" .Values.global) }}
{{- end -}}

{{- define "hami.remotegpu.server.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.devices.remotegpu.server.image) "global" .Values.global) }}
{{- end -}}

{{/*
With an auto-detected driver root, the device plugin loads NVML from the driver
injected by the NVIDIA Container Toolkit. The host root is mounted only when a
CDI device list strategy needs to walk the host driver layout. The strategy can
also be overridden through extraArgs or extraEnvs, so check those too.
*/}}
{{- define "hami.devicePlugin.autoDriverRootHostMount" -}}
{{- $strategies := list (toString .Values.devicePlugin.deviceListStrategy) -}}
{{- $takeNext := false -}}
{{- range .Values.devicePlugin.extraArgs -}}
{{- $arg := toString . -}}
{{- if $takeNext -}}
{{- $strategies = append $strategies $arg -}}
{{- end -}}
{{- $takeNext = regexMatch "^--?device-list-strategy$" $arg -}}
{{- if regexMatch "^--?device-list-strategy=" $arg -}}
{{- $strategies = append $strategies $arg -}}
{{- end -}}
{{- end -}}
{{- range .Values.devicePlugin.extraEnvs -}}
{{- if eq (toString .name) "DEVICE_LIST_STRATEGY" -}}
{{- $strategies = append $strategies (toString .value) -}}
{{- end -}}
{{- end -}}
{{- if and (eq .Values.devicePlugin.nvidiaDriverRoot "auto") (contains "cdi-" (join "," $strategies)) -}}
true
{{- end -}}
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
{{- $resources = append $resources (dict "name" .Values.devices.nvidia.resourceCountName "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.devices.nvidia.resourceMemoryName "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.devices.nvidia.resourceCoreName "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.devices.nvidia.resourceMemoryPercentageName "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.devices.nvidia.resourcePriorityName "ignoredByScheduler" true) -}}
{{/* MLU resources */}}
{{- $resources = append $resources (dict "name" .Values.devices.cambricon.resourceCountName "ignoredByScheduler" true) -}}
{{/* HCU resources */}}
{{- $resources = append $resources (dict "name" .Values.devices.hygon.resourceCountName "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.devices.hygon.resourceMemoryName "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.devices.hygon.resourceCoreName "ignoredByScheduler" true) -}}
{{/* Metax resources */}}
{{- $resources = append $resources (dict "name" .Values.devices.metax.resourceCountName "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.devices.metax.resourceVCountName "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.devices.metax.resourceVCoreName "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.devices.metax.resourceVMemoryName "ignoredByScheduler" true) -}}
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
{{- $standardResources := list .Values.devices.enflame.resourceNameDRSGCU .Values.devices.enflame.resourceNameGCUMemory .Values.devices.enflame.resourceNameGCUCore .Values.devices.enflame.resourceNameGCU -}}
{{- range (concat $standardResources (.Values.devices.enflame.customresources | default (list)) | uniq) -}}
{{- $resources = append $resources (dict "name" . "ignoredByScheduler" true) -}}
{{- end -}}
{{- end -}}
{{/* Kunlun resources */}}
{{- if .Values.devices.kunlun.enabled -}}
{{- $standardResources := list .Values.devices.kunlun.resourceCountName .Values.devices.kunlun.resourceVCountName .Values.devices.kunlun.resourceVMemoryName -}}
{{- range (concat $standardResources (.Values.devices.kunlun.customresources | default (list)) | uniq) -}}
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
{{- $standardResources := list .Values.devices.vastai.resourceCountName -}}
{{- range (concat $standardResources (.Values.devices.vastai.customresources | default (list)) | uniq) -}}
{{- $resources = append $resources (dict "name" . "ignoredByScheduler" true) -}}
{{- end -}}
{{- end -}}
{{/* Biren resources */}}
{{- if .Values.devices.biren.enabled -}}
{{- $standardResources := list .Values.devices.biren.resourceCountName -}}
{{- range (concat $standardResources (.Values.devices.biren.customresources | default (list)) | uniq) -}}
{{- $resources = append $resources (dict "name" . "ignoredByScheduler" true) -}}
{{- end -}}
{{- end -}}
{{/* AMD resources */}}
{{- $resources = append $resources (dict "name" .Values.devices.amd.resourceMemoryPercentageName "ignoredByScheduler" true) -}}
{{- range .Values.devices.amd.customresources -}}
{{- $resources = append $resources (dict "name" . "ignoredByScheduler" true) -}}
{{- end -}}
{{/* Remote GPU (lupine) resources. A client pod requests these on a node that
     owns no GPU, so ignoredByScheduler is what keeps that node a candidate:
     kube-scheduler skips the node-fit check and leaves placement to the
     extender, which still gets called because the resource is listed here.
     Both names come straight from the values the device config uses, so
     renaming a resource cannot leave it off this list and silently reinstate
     the node-fit check that rejects every GPU-less node. */}}
{{- if .Values.devices.remotegpu.enabled -}}
{{- $resources = append $resources (dict "name" .Values.devices.remotegpu.resourceCountName "ignoredByScheduler" true) -}}
{{- $resources = append $resources (dict "name" .Values.devices.remotegpu.resourceMemoryName "ignoredByScheduler" true) -}}
{{- end -}}
{{- if .Values.devices.alibaba.enabled -}}
{{- range .Values.devices.alibaba.customresources -}}
{{- $resources = append $resources (dict "name" . "ignoredByScheduler" true) -}}
{{- end -}}
{{- end -}}
{{- toYaml $resources -}}
{{- end -}}

{{/* Resolve the Ascend default mode while accepting the released legacy core flag. */}}
{{- define "hami-enterprise.ascendVnpuMode" -}}
{{- $ascend := .Values.devices.ascend -}}
{{- if and (hasKey $ascend "hamiVnpuCore") (not (kindIs "bool" $ascend.hamiVnpuCore)) -}}
  {{- fail "devices.ascend.hamiVnpuCore must be a boolean; use devices.ascend.hamiVnpuMode instead" -}}
{{- end -}}
{{- $mode := "" -}}
{{- if ne $ascend.hamiVnpuMode nil -}}
  {{- if not (kindIs "string" $ascend.hamiVnpuMode) -}}
    {{- fail "devices.ascend.hamiVnpuMode must be a string: template, hami-core (or hamiCore), or enpu" -}}
  {{- end -}}
  {{- $mode = lower (trim $ascend.hamiVnpuMode) -}}
{{- end -}}
{{- if eq $mode "" -}}
  {{- $mode = ternary "hami-core" "template" ($ascend.hamiVnpuCore | default false) -}}
{{- else if eq $mode "hamicore" -}}
  {{- $mode = "hami-core" -}}
{{- end -}}
{{- if not (has $mode (list "template" "hami-core" "enpu")) -}}
  {{- fail (printf "devices.ascend.hamiVnpuMode must be template, hami-core (or hamiCore), or enpu, got %q" $ascend.hamiVnpuMode) -}}
{{- end -}}
{{- $mode -}}
{{- end -}}

{{- define "hami-enterprise.validateValues" -}}
{{/* Refit carries a ServiceAccount token, so its client always verifies TLS. */}}
{{- with .Values.devicePlugin.numaRefit -}}
{{- if .enabled -}}
{{- if .tlsInsecure -}}
{{- fail "devicePlugin.numaRefit.tlsInsecure must be false for authenticated refit requests" -}}
{{- end -}}
{{- if not (or .caFile .caSecret) -}}
{{- fail "devicePlugin.numaRefit requires caFile or caSecret to verify the scheduler TLS certificate" -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if or (hasKey .Values "dra") (hasKey .Values "hami-dra") -}}
{{- fail "DRA integration is not supported by HAMi Enterprise; remove dra and hami-dra values" -}}
{{- end -}}
{{/* Reject obsolete paths by presence, including explicit zero, false and empty values. */}}
{{- $removedFields := dict
  "resourceName" "devices.nvidia.resourceCountName"
  "resourceMem" "devices.nvidia.resourceMemoryName"
  "resourceMemPercentage" "devices.nvidia.resourceMemoryPercentageName"
  "resourceCores" "devices.nvidia.resourceCoreName"
  "resourcePriority" "devices.nvidia.resourcePriorityName"
  "mluResourceName" "devices.cambricon.resourceCountName"
  "mluResourceMem" "devices.cambricon.resourceMemoryName"
  "mluResourceCores" "devices.cambricon.resourceCoreName"
  "dcuResourceName" "devices.hygon.resourceCountName"
  "dcuResourceMem" "devices.hygon.resourceMemoryName"
  "dcuResourceCores" "devices.hygon.resourceCoreName"
  "hcuResourceName" "devices.hygon.resourceCountName"
  "hcuResourceMem" "devices.hygon.resourceMemoryName"
  "hcuResourceCores" "devices.hygon.resourceCoreName"
  "metaxResourceName" "devices.metax.resourceVCountName"
  "metaxResourceCore" "devices.metax.resourceVCoreName"
  "metaxResourceMem" "devices.metax.resourceVMemoryName"
  "metaxsGPUTopologyAware" "devices.metax.sgpuTopologyAware"
  "enflameResourceNameDRSGCU" "devices.enflame.resourceNameDRSGCU"
  "enflameResourceNameGCUMemory" "devices.enflame.resourceNameGCUMemory"
  "enflameResourceNameGCUCore" "devices.enflame.resourceNameGCUCore"
  "kunlunResourceName" "devices.kunlun.resourceCountName"
  "kunlunResourceVCountName" "devices.kunlun.resourceVCountName"
  "kunlunResourceVMemoryName" "devices.kunlun.resourceVMemoryName"
  "vastaiResourceName" "devices.vastai.resourceCountName"
  "birenResourceName" "devices.biren.resourceCountName"
  "devicePlugin.deviceSplitCount" "devices.nvidia.deviceSplitCount"
  "devicePlugin.deviceMemoryScaling" "devices.nvidia.deviceMemoryScaling"
  "devicePlugin.deviceCoreScaling" "devices.nvidia.deviceCoreScaling"
  "devicePlugin.preConfiguredDeviceMemory" "devices.nvidia.preConfiguredDeviceMemory"
  "devicePlugin.enableNumaTopology" "devices.nvidia.enableNumaTopology"
  "devicePlugin.runtimeClassName" "devices.nvidia.runtimeClassName"
  "devicePlugin.createRuntimeClass" "devices.nvidia.createRuntimeClass"
  "devices.ascend.enpu" "devices.ascend.hamiVnpuMode (template, hami-core, or enpu)"
  "scheduler.patch.image" "scheduler.patch.imageNew"
-}}
{{- $errors := list -}}
{{- range $old, $new := $removedFields -}}
  {{- $value := $.Values -}}
  {{- $present := true -}}
  {{- range $part := splitList "." $old -}}
    {{- if not (and (kindIs "map" $value) (hasKey $value $part)) -}}
      {{- $present = false -}}
      {{- break -}}
    {{- end -}}
    {{- $value = index $value $part -}}
  {{- end -}}
  {{- if $present -}}
    {{- $errors = append $errors (printf "%s has been removed; use %s instead" $old $new) -}}
  {{- end -}}
{{- end -}}
{{- if $errors -}}
  {{- fail (printf "Removed configuration fields:\n%s" (join "\n" $errors)) -}}
{{- end -}}
{{/* Validate values even when device-config.content overrides the generated config. */}}
{{- $_ := include "hami-enterprise.ascendVnpuMode" . -}}
{{- $count := .Values.devices.ascend.deviceSplitCount -}}
{{- $integer := int64 $count -}}
{{- $numeric := has (kindOf $count) (list "int" "int64" "float64") -}}
{{- if not (and $numeric (gt $integer 0) (eq (float64 $count) (float64 $integer))) -}}
  {{- fail "devices.ascend.deviceSplitCount must be a positive integer" -}}
{{- end -}}
{{- end -}}

{{- define "hami-enterprise.schedulerServiceAccountUsername" -}}
{{- printf "system:serviceaccount:%s:%s" (include "hami-enterprise.namespace" .) (include "hami-enterprise.scheduler" .) -}}
{{- end -}}

{{/* Resolve the same configuration precedence as device-configmap.yaml. */}}
{{- define "hami-enterprise.vnpuCommonWords" -}}
{{- $configs := .Values.devices.ascend.configs -}}
{{- $content := "" -}}
{{- with (index .Values "device-config") -}}
{{- $content = (index . "content") | default "" -}}
{{- end -}}
{{- if and (not $content) (.Files.Glob "files/device-config.yaml") -}}
{{- $content = .Files.Get "files/device-config.yaml" -}}
{{- end -}}
{{- if $content -}}
{{- $configs = list -}}
{{- $parsed := fromYaml $content -}}
{{- with $parsed.vnpus -}}
{{- $configs = .configs | default (list) -}}
{{- end -}}
{{- end -}}
{{- $words := list -}}
{{- range $configs -}}
{{- if .commonWord -}}
{{- $words = append $words .commonWord -}}
{{- end -}}
{{- end -}}
{{- $words | uniq | sortAlpha | toJson -}}
{{- end -}}

{{/* The vNPU annotations protected on update. */}}
{{- define "hami-enterprise.vnpuProtectedAnnotationCELList" -}}
{{- $keys := list "huawei.com/vnpu-mode" -}}
{{- range (include "hami-enterprise.vnpuCommonWords" . | fromJsonArray) -}}
{{- $keys = append $keys (printf "hami.io/%s-devices-allocated" .) -}}
{{- end -}}
{{- $keys | toJson -}}
{{- end -}}

{{/* The vNPU annotations reserved on create. */}}
{{- define "hami-enterprise.vnpuCreateReservedAnnotationCELList" -}}
{{- $keys := list -}}
{{- range (include "hami-enterprise.vnpuCommonWords" . | fromJsonArray) -}}
{{- $keys = append $keys (printf "hami.io/%s-devices-allocated" .) -}}
{{- $keys = append $keys (printf "hami.io/%s-devices-try-allocate" .) -}}
{{- end -}}
{{- $keys | toJson -}}
{{- end -}}

{{/*
The app name for DevicePlugin
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

{{- define "hami.scheduler.patch.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.scheduler.patch.image "global" .Values.global) }}
{{- end -}}


{{- define "hami.scheduler.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.scheduler.kubeScheduler.image .Values.scheduler.extender.image) "global" .Values.global) }}
{{- end -}}


{{- define "hami.scheduler.patch.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.scheduler.patch.image) "global" .Values.global) }}
{{- end -}}

{{/* Keep the adjustment flag, validating webhook, and CA patch permissions on one deployment condition. */}}
{{- define "hami-enterprise.vnpuAdmissionGuardEnabled" -}}
{{- if and .Values.scheduler.admissionWebhook.enabled .Values.devices.ascend.enabled (semverCompare ">=1.30.0-0" .Capabilities.KubeVersion.Version) -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{/* Conditional admission avoids intercepting bootstrap Pods before certificates exist. */}}
{{- define "hami-enterprise.allocationValidationEnabled" -}}
{{- if and .Values.scheduler.admissionWebhook.enabled (semverCompare ">=1.30.0-0" .Capabilities.KubeVersion.Version) -}}true{{- else -}}false{{- end -}}
{{- end -}}
