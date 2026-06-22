{{/*
Expand the name of the chart.
*/}}
{{- define "metax-operator.name" -}}
{{- default .Chart.Name .Values.controller.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "metax-operator.fullname" -}}
{{- if .Values.controller.fullnameOverride }}
{{- .Values.controller.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.controller.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "metax-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "metax-operator.labels" -}}
helm.sh/chart: {{ include "metax-operator.chart" . }}
{{ include "metax-operator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "metax-operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "metax-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: "metax-operator"
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "metax-operator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "metax-operator.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
{{- define "metax-operator.roleName" -}}
{{ include "metax-operator.serviceAccountName" .}}-role
{{- end }}
{{- define "metax-operator.roleBindingName" -}}
{{ include "metax-operator.serviceAccountName" .}}-rolebinding
{{- end }}


{{- define "controller.name" -}}
{{- default "operator-controller" ((.Values.controller).image).name }}
{{- end }}
{{- define "controller.version" -}}
{{- default .Chart.Version ((.Values.controller).image).version }}
{{- end }}
{{- define "controller.pullPolicy" -}}
{{- default .Values.pullPolicy ((.Values.controller).image).pullPolicy }}
{{- end }}
{{- define "controller.registry" -}}
{{- default .Values.registry ((.Values.controller).image).registry }}
{{- end }}


{{- define "driver.name" -}}
{{- default "driver-manager" ((.Values.driver).image).name }}
{{- end }}
{{- define "driver.version" -}}
{{- default .Chart.Version ((.Values.driver).image).version }}
{{- end }}
{{- define "driver.registry" -}}
{{- default .Values.registry ((.Values.driver).image).registry }}
{{- end }}

{{- define "topoMaster.name" -}}
{{- default "topo-master" ((.Values.topoDiscovery.master).image).name }}
{{- end }}
{{- define "topoMaster.version" -}}
{{- default .Chart.Version ((.Values.topoDiscovery.master).image).version }}
{{- end }}
{{- define "topoMaster.registry" -}}
{{- default .Values.registry ((.Values.topoDiscovery.master).image).registry }}
{{- end }}

{{- define "scheduler.name" -}}
{{- default "gpu-scheduler" ((.Values.gpuScheduler.scheduler).image).name }}
{{- end }}
{{- define "scheduler.version" -}}
{{- default .Chart.Version ((.Values.gpuScheduler.scheduler).image).version }}
{{- end }}
{{- define "scheduler.registry" -}}
{{- default .Values.registry ((.Values.gpuScheduler.scheduler).image).registry }}
{{- end }}
{{- define "scheduler.pullPolicy" -}}
{{- default .Values.pullPolicy ((.Values.gpuScheduler.scheduler).image).pullPolicy }}
{{- end }}

{{- define "kubeScheduler.name" -}}
{{- default "kube-scheduler" ((.Values.gpuScheduler.kubeScheduler).image).name }}
{{- end }}
{{- define "kubeScheduler.version" -}}
{{- default (include "clusterKubeVersion" .) ((.Values.gpuScheduler.kubeScheduler).image).version }}
{{- end }}
{{- define "kubeScheduler.registry" -}}
{{- default .Values.registry ((.Values.gpuScheduler.kubeScheduler).image).registry }}
{{- end }}
{{- define "kubeScheduler.pullPolicy" -}}
{{- default .Values.pullPolicy ((.Values.gpuScheduler.kubeScheduler).image).pullPolicy }}
{{- end }}

{{- define "gpuAware.name" -}}
{{- default "gpu-aware" ((.Values.gpuScheduler.gpuAware).image).name }}
{{- end }}
{{- define "gpuAware.version" -}}
{{- default .Chart.Version ((.Values.gpuScheduler.gpuAware).image).version }}
{{- end }}
{{- define "gpuAware.registry" -}}
{{- default .Values.registry ((.Values.gpuScheduler.gpuAware).image).registry }}
{{- end }}
{{- define "gpuAware.pullPolicy" -}}
{{- default .Values.pullPolicy ((.Values.gpuScheduler.gpuAware).image).pullPolicy }}
{{- end }}

{{- define "clusterKubeVersion" -}}
{{ regexReplaceAll "^(v[0-9]+\\.[0-9]+\\.[0-9]+)(.*)$" .Capabilities.KubeVersion.Version "$1" | trim -}}
{{- end -}}

{{- define "podTemplateSpec" -}}
{{- if or .Values.podTemplateSpecFile .Values.podTemplateSpec }}
podTemplateSpec:
{{- if .Values.podTemplateSpecFile }}
{{- .Values.podTemplateSpecFile | fromYaml | toYaml | nindent 2 }}
{{- else }}
{{- .Values.podTemplateSpec | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "gpuLabel.podTemplateSpec" -}}
{{- if or .Values.gpuLabel.podTemplateSpecFile .Values.gpuLabel.podTemplateSpec }}
podTemplateSpec:
{{- if .Values.gpuLabel.podTemplateSpecFile }}
{{- .Values.gpuLabel.podTemplateSpecFile | fromYaml | toYaml | nindent 2 }}
{{- else }}
{{- .Values.gpuLabel.podTemplateSpec | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "driver.podTemplateSpec" -}}
{{- if or .Values.driver.podTemplateSpecFile .Values.driver.podTemplateSpec }}
podTemplateSpec:
{{- if .Values.driver.podTemplateSpecFile }}
{{- .Values.driver.podTemplateSpecFile | fromYaml | toYaml | nindent 2 }}
{{- else }}
{{- .Values.driver.podTemplateSpec | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "maca.podTemplateSpec" -}}
{{- if or .Values.maca.podTemplateSpecFile .Values.maca.podTemplateSpec }}
podTemplateSpec:
{{- if .Values.maca.podTemplateSpecFile }}
{{- .Values.maca.podTemplateSpecFile | fromYaml | toYaml | nindent 2 }}
{{- else }}
{{- .Values.maca.podTemplateSpec | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "runtime.podTemplateSpec" -}}
{{- if or .Values.runtime.podTemplateSpecFile .Values.runtime.podTemplateSpec }}
podTemplateSpec:
{{- if .Values.runtime.podTemplateSpecFile }}
{{- .Values.runtime.podTemplateSpecFile | fromYaml | toYaml | nindent 2 }}
{{- else }}
{{- .Values.runtime.podTemplateSpec | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "gpuDevice.podTemplateSpec" -}}
{{- if or .Values.gpuDevice.podTemplateSpecFile .Values.gpuDevice.podTemplateSpec }}
podTemplateSpec:
{{- if .Values.gpuDevice.podTemplateSpecFile }}
{{- .Values.gpuDevice.podTemplateSpecFile | fromYaml | toYaml | nindent 2 }}
{{- else }}
{{- .Values.gpuDevice.podTemplateSpec | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
cmInit mappings for ClusterOperator spec (values -> legacy -> empty)
*/}}
{{- define "cmInit.driver" -}}
{{- $driverCmInitSet := and (hasKey .Values.driver "cmInit") (not (empty .Values.driver.cmInit)) -}}
{{- $driverLegacyV2 := or (not (empty .Values.driver.driverConfig)) (not (empty .Values.driver.driverConfigFile)) -}}
{{- if $driverCmInitSet }}
cmInit:
  {{- toYaml .Values.driver.cmInit | nindent 2 }}
{{- else if $driverLegacyV2 }}
cmInit:
  config:
    {{- $config := dict }}
    {{- if .Values.driver.driverConfigFile }}
      {{- $config = .Values.driver.driverConfigFile | fromYaml | default dict }}
    {{- else }}
      {{- $config = .Values.driver.driverConfig | default dict }}
    {{- end }}
    version: v2
    nodes-config: |
      {{- $config.nodesConfig | default list | toYaml | nindent 6 }}
    module-params: |
      {{- $config.moduleParams | default dict | toYaml | nindent 6 }}
    node-vfnums: ""
    node-module-params: ""
{{- else }}
cmInit:
  config:
    version: v1
    node-vfnums: |
      {{- toYaml .Values.driver.vfnumsConfig | nindent 6 }}
    module-params: |
      {{- toYaml .Values.driver.moduleParams | nindent 6 }}
    node-module-params: |
      {{- toYaml .Values.driver.nodeModuleParams | nindent 6 }}
    nodes-config: ""
{{- end }}
  vfio:
    vfio: |
      {{- range .Values.driver.vfioConfig }}
      - nodeName: {{ .nodeName }}
        gpus: "{{ .gpus }}"
      {{- end }}
{{- end }}

{{- define "cmInit.maca" -}}
{{- $macaCmInitSet := and (hasKey .Values.maca "cmInit") (not (empty .Values.maca.cmInit)) -}}
{{- $macaLegacy := not (empty .Values.maca.cleanupConfig) -}}
{{- if $macaCmInitSet }}
cmInit:
  {{- toYaml .Values.maca.cmInit | nindent 2 }}
{{- else if $macaLegacy }}
cmInit:
  config:
    cleanup: |
      threshold: {{ .Values.maca.cleanupConfig.threshold }}
      cleanupPolicy: {{ .Values.maca.cleanupConfig.cleanupPolicy }}
{{- end }}
{{- end -}}

{{- define "cmInit.gpuScheduler" -}}
{{- $gpuSchedulerCmInitSet := and (hasKey .Values.gpuScheduler "cmInit") (not (empty .Values.gpuScheduler.cmInit)) -}}

{{- if $gpuSchedulerCmInitSet -}}
cmInit:
  {{- toYaml .Values.gpuScheduler.cmInit | nindent 2 -}}
{{- end }}
{{- end -}}


{{- define "cmInit.devicePlugin" -}}
{{- $gpuDeviceCmInitSet := and (hasKey .Values.gpuDevice "cmInit") (not (empty .Values.gpuDevice.cmInit)) -}}
{{- $filterData := dict }}
{{- if .Values.kind.enabled }}
  {{- if .Values.kind.configDataFile }}
    {{- $filterData = fromYaml .Values.kind.configDataFile }}
  {{- else if .Values.kind.configData }}
    {{- $filterData = .Values.kind.configData }}
  {{- else }}
    {{- $gpuConfig := lookup "v1" "ConfigMap" "default" "mx-gpu-config" }}
    {{- if $gpuConfig }}
      {{- $filterData = $gpuConfig.data }}
    {{- end }}
  {{- end }}
{{- end }}
{{- if $gpuDeviceCmInitSet }}
cmInit:
  {{- toYaml .Values.gpuDevice.cmInit | nindent 2 }}
{{- else if or $filterData .Values.gpuDevice.sGPUHybridMode }}
cmInit:
  config:
    version: v1
  {{- if $filterData }}
    kind-config: |
  {{- toYaml $filterData | nindent 6 }}
  {{- end }}
    cluster-config: |
    {{- if .Values.gpuDevice.sGPUHybridMode }}
      mode: "sgpu"
    {{- else }}
      mode: "native"
    {{- end }}
{{- else }}
cmInit:
  config:
    version: v1
    cluster-config: |
      mode: {{ .Values.gpuDevice.config.mode | default "" | quote }}
{{- end }}
{{- with .Values.gpuDevice.config }}
      sgpuHybrid: {{ .sgpuHybrid | toYaml }}
      shareNums: {{ .shareNums }}
      deviceAllocationStrategy: {{ .deviceAllocationStrategy | default "" | quote }}
{{- end }}
{{- end -}}

{{- define "vendor.config" -}}
{{- $vendor := .Values.vendor | default (dict) -}}
{{- $vendorConfig := omit $vendor "deploy" | default (fromYaml ($.Files.Get "vendor.yaml")) -}}
vendorID: {{ $vendorConfig.vendorID | quote }}
domain: {{ $vendorConfig.domain }}
charDev: {{ $vendorConfig.charDev }}
driver: {{ $vendorConfig.driver }}
virtDriver: {{ $vendorConfig.virtDriver }}
{{- end }}

{{- define "dataExporter.podTemplateSpec" -}}
{{- if or .Values.dataExporter.podTemplateSpecFile .Values.dataExporter.podTemplateSpec }}
podTemplateSpec:
{{- if .Values.dataExporter.podTemplateSpecFile }}
{{- .Values.dataExporter.podTemplateSpecFile | fromYaml | toYaml | nindent 2 }}
{{- else }}
{{- .Values.dataExporter.podTemplateSpec | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "topoDiscovery.master.podTemplateSpec" -}}
{{- if or .Values.topoDiscovery.master.podTemplateSpecFile .Values.topoDiscovery.master.podTemplateSpec }}
podTemplateSpec:
{{- if .Values.topoDiscovery.master.podTemplateSpecFile }}
{{- .Values.topoDiscovery.master.podTemplateSpecFile | fromYaml | toYaml | nindent 2 }}
{{- else }}
{{- .Values.topoDiscovery.master.podTemplateSpec | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "topoDiscovery.worker.podTemplateSpec" -}}
{{- if or .Values.topoDiscovery.worker.podTemplateSpecFile .Values.topoDiscovery.worker.podTemplateSpec }}
podTemplateSpec:
{{- if .Values.topoDiscovery.worker.podTemplateSpecFile }}
{{- .Values.topoDiscovery.worker.podTemplateSpecFile | fromYaml | toYaml | nindent 2 }}
{{- else }}
{{- .Values.topoDiscovery.worker.podTemplateSpec | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "openshiftEnabled" -}}
{{- if (default dict .Values.openshift).enabled -}}
{{- print "true" -}}
{{- end }}
{{- end }}

{{- define "gpuScheduler.podTemplateSpec" -}}
{{- if or .Values.gpuScheduler.podTemplateSpecFile .Values.gpuScheduler.podTemplateSpec }}
podTemplateSpec:
{{- if .Values.gpuScheduler.podTemplateSpecFile }}
{{- .Values.gpuScheduler.podTemplateSpecFile | fromYaml | toYaml | nindent 2 }}
{{- else }}
{{- .Values.gpuScheduler.podTemplateSpec | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}