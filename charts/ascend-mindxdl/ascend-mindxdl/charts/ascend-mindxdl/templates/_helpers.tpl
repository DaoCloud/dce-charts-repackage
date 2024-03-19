{{/*
Expand the name of the chart.
*/}}
{{- define "ascend-mindxdl.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ascend-mindxdl.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
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
{{- define "ascend-mindxdl.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ascend-mindxdl.labels" -}}
helm.sh/chart: {{ include "ascend-mindxdl.chart" . }}
{{ include "ascend-mindxdl.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "ascend-mindxdl.npu-exporter.serviceMonitor.labels" -}}
{{- if .Values.npuExporter.serviceMonitor.labels }}
{{- range $key, $value := .Values.npuExporter.serviceMonitor.labels -}}
{{ $key }}: {{ $value }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "ascend-mindxdl.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ascend-mindxdl.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ascend-mindxdl.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ascend-mindxdl.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Full image name with tag
*/}}
{{- define "devicePlugin.fullimage" -}}
{{- .Values.devicePlugin.daemonsets.devicePlugin.repository -}}/{{- .Values.devicePlugin.daemonsets.devicePlugin.image -}}:{{- .Values.devicePlugin.daemonsets.devicePlugin.version | default .Chart.AppVersion -}}
{{- end }}

{{- define "npuExporter.fullimage" -}}
{{- .Values.npuExporter.repository -}}/{{- .Values.npuExporter.image -}}:{{- .Values.npuExporter.version | default .Chart.AppVersion -}}
{{- end }}
