{{/*
Expand the name of the chart.
*/}}
{{- define "topohub.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "topohub.fullname" -}}
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
{{- define "topohub.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "topohub.labels" -}}
helm.sh/chart: {{ include "topohub.chart" . }}
{{ include "topohub.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "topohub.selectorLabels" -}}
app.kubernetes.io/name: {{ include "topohub.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "topohub.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "topohub.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
return the image
*/}}
{{- define "topohub.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- if .Values.registryOverride }}
{{- $registryName = .Values.registryOverride }}
{{- end }}
{{- $repositoryName := .Values.image.repository -}}
{{- printf "%s/%s" $registryName $repositoryName -}}
{{- if .Values.image.digest }}
    {{- print "@" .Values.image.digest -}}
{{- else if .Values.image.tag -}}
    {{- printf ":%s" (toString .Values.image.tag) -}}
{{- else -}}
    {{- printf ":v%s" .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{/*
return the image
*/}}
{{- define "fileBrowser.image" -}}
{{- $registryName := .Values.fileBrowser.image.registry -}}
{{- if .Values.registryOverride }}
{{- $registryName = .Values.registryOverride }}
{{- end }}
{{- $repositoryName := .Values.fileBrowser.image.repository -}}
{{- printf "%s/%s" $registryName $repositoryName -}}
{{- if .Values.fileBrowser.image.digest }}
    {{- print "@" .Values.fileBrowser.image.digest -}}
{{- else if .Values.fileBrowser.image.tag -}}
    {{- printf ":%s" (toString .Values.fileBrowser.image.tag) -}}
{{- end -}}
{{- end -}}
