{{/*
Expand the name of the chart.
*/}}
{{- define "bmc-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "bmc-operator.fullname" -}}
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
{{- define "bmc-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "bmc-operator.labels" -}}
helm.sh/chart: {{ include "bmc-operator.chart" . }}
{{ include "bmc-operator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "bmc-operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "bmc-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "bmc-operator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "bmc-operator.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
return the controller image
*/}}
{{- define "bmc-operator.controller.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- if .Values.global.imageRegistryOverride }}
    {{- printf "%s/%s" .Values.global.imageRegistryOverride $repositoryName -}}
{{- else -}}
    {{- printf "%s/%s" $registryName $repositoryName -}}
{{- end -}}
{{- if .Values.image.digest }}
    {{- print "@" .Values.image.digest -}}
{{- else if .Values.global.imageTagOverride -}}
    {{- printf ":%s" (toString .Values.global.imageTagOverride) -}}
{{- else if .Values.image.tag -}}
    {{- printf ":%s" (toString .Values.image.tag) -}}
{{- else -}}
    {{- printf ":v%s" .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{/*
return the agent image
*/}}
{{- define "bmc-operator.agent.image" -}}
{{- $registryName := .Values.clusterAgent.agentYaml.image.registry -}}
{{- $repositoryName := .Values.clusterAgent.agentYaml.image.repository -}}
{{- if .Values.global.imageRegistryOverride }}
    {{- printf "%s/%s" .Values.global.imageRegistryOverride $repositoryName -}}
{{- else -}}
    {{- printf "%s/%s" $registryName $repositoryName -}}
{{- end -}}
{{- if .Values.clusterAgent.agentYaml.image.digest }}
    {{- print "@" .Values.clusterAgent.agentYaml.image.digest -}}
{{- else if .Values.global.imageTagOverride -}}
    {{- printf ":%s" (toString .Values.global.imageTagOverride) -}}
{{- else if .Values.clusterAgent.agentYaml.image.tag -}}
    {{- printf ":%s" (toString .Values.clusterAgent.agentYaml.image.tag) -}}
{{- else -}}
    {{- printf ":v%s" .Chart.AppVersion -}}
{{- end -}}
{{- end -}}
