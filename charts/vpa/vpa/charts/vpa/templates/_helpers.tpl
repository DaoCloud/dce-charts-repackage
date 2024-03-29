{{/*
Expand the name of the chart.
*/}}
{{- define "vpa.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vpa.fullname" -}}
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
{{- define "vpa.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vpa.labels" -}}
helm.sh/chart: {{ include "vpa.chart" . }}
{{ include "vpa.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.podLabels }}
{{ toYaml .Values.podLabels }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "vpa.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vpa.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "vpa.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "vpa.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper image name
*/}}
{{- define "recommender.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.recommender.image "global" .Values.global "tag" .Values.global.vpa "Values" .Values "Capabilities" .Capabilities .) -}}
{{- end -}}

{{/*
Return the proper image Registry Secret Names
*/}}
{{- define "recommender.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image) "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name
*/}}
{{- define "admissionController.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.admissionController.image "global" .Values.global "tag" .Values.global.vpa "Values" .Values "Capabilities" .Capabilities .) -}}
{{- end -}}

{{/*
Return the proper image Registry Secret Names
*/}}
{{- define "admissionController.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image) "global" .Values.global) }}
{{- end -}}


{{/*
Return the proper image name
{{- include "common.images.image" (dict "imageRoot" .Values.updater.image "global" .Values.global "tag" .Values.global.vpa) -}}
*/}}
{{- define "updater.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.updater.image "global" .Values.global "tag" .Values.global.vpa "Values" .Values "Capabilities" .Capabilities .) -}}
{{- end -}}

{{/*
Return the proper image Registry Secret Names
*/}}
{{- define "updater.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image) "global" .Values.global) }}
{{- end -}}
