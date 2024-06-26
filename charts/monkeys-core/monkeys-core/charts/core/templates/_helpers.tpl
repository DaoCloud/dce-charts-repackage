{{/*
Expand the name of the chart.
*/}}
{{- define "monkeys.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "monkeys.fullname" -}}
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
Create a default fully qualified server name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "monkeys.server.fullname" -}}
{{ template "monkeys.fullname" . }}-server
{{- end -}}

{{/*
Create a default fully qualified admin name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "monkeys.admin.fullname" -}}
{{ template "monkeys.fullname" . }}-admin
{{- end -}}

{{/*
Create a default fully qualified clash name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "monkeys.clash.fullname" -}}
{{ template "monkeys.fullname" . }}-clash
{{- end -}}

{{/*
Create a default fully qualified conductor name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "monkeys.conductor.fullname" -}}
{{ template "monkeys.fullname" . }}-conductor
{{- end -}}

{{/*
Create a default fully qualified oneapi name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "monkeys.oneapi.fullname" -}}
{{ template "monkeys.fullname" . }}-oneapi
{{- end -}}

{{/*
Create a default fully qualified web name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "monkeys.web.fullname" -}}
{{ template "monkeys.fullname" . }}-web
{{- end -}}

{{/*
Create a default fully qualified web name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "monkeys.proxy.fullname" -}}
{{ template "monkeys.fullname" . }}-proxy
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "monkeys.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "monkeys.labels" -}}
helm.sh/chart: {{ include "monkeys.chart" . }}
{{ include "monkeys.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "monkeys.selectorLabels" -}}
app.kubernetes.io/name: {{ include "monkeys.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "monkeys.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "monkeys.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* annotations defiend by user*/}}
{{- define "monkeys.ud.annotations" -}}
{{- if .Values.annotations }}
{{- toYaml .Values.annotations }}
{{- end -}}
{{- end -}}

{{/* labels defiend by user*/}}
{{- define "monkeys.ud.labels" -}}
{{- if .Values.labels }}
{{- toYaml .Values.labels }}
{{- end -}}
{{- end -}}