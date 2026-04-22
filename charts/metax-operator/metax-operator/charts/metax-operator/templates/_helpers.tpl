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