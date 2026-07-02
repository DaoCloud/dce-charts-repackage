{{/*
Expand the name of the chart.
*/}}
{{- define "iaas-network-provider.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "iaas-network-provider.fullname" -}}
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
Common labels
*/}}
{{- define "iaas-network-provider.labels" -}}
helm.sh/chart: {{ include "iaas-network-provider.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "iaas-network-provider.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "iaas-network-provider.selectorLabels" -}}
app.kubernetes.io/name: {{ include "iaas-network-provider.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Default image tag: v + appVersion when image.tag is unset.
*/}}
{{- define "iaas-network-provider.imageTag" -}}
{{- if .Values.image.tag -}}
{{- .Values.image.tag -}}
{{- else -}}
{{- printf "v%s" .Chart.AppVersion -}}
{{- end -}}
{{- end }}

{{/*
Full container image reference.
*/}}
{{- define "iaas-network-provider.image" -}}
{{- printf "%s/%s:%s" .Values.image.registry .Values.image.repository (include "iaas-network-provider.imageTag" .) -}}
{{- end }}

{{/*
ServiceAccount name
*/}}
{{- define "iaas-network-provider.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "iaas-network-provider.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Validate required chart values and fail fast on empty inputs.
*/}}
{{- define "iaas-network-provider.validateValues" -}}
{{- $_ := required "values.image.registry is required and cannot be empty" .Values.image.registry -}}
{{- $_ := required "values.image.repository is required and cannot be empty" .Values.image.repository -}}
{{- $_ := required "values.config.iaasProvider.provider is required and cannot be empty" .Values.config.iaasProvider.provider -}}
{{- $_ := required "values.config.iaasProvider.endpoint is required and cannot be empty" .Values.config.iaasProvider.endpoint -}}
{{- $_ := required "values.config.iaasProvider.region is required and cannot be empty" .Values.config.iaasProvider.region -}}
{{- $_ := required "values.config.iaasProvider.projectID is required and cannot be empty" .Values.config.iaasProvider.projectID -}}
{{- $_ := required "values.config.iaasProvider.auth.mode is required and cannot be empty" .Values.config.iaasProvider.auth.mode -}}

{{- if eq .Values.config.iaasProvider.auth.mode "token" -}}
{{- $_ := required "values.config.iaasProvider.auth.token.username is required when auth.mode=token" .Values.config.iaasProvider.auth.token.username -}}
{{- $_ := required "values.config.iaasProvider.auth.token.password is required when auth.mode=token" .Values.config.iaasProvider.auth.token.password -}}
{{- $_ := required "values.config.iaasProvider.auth.token.iamDomain is required when auth.mode=token" .Values.config.iaasProvider.auth.token.iamDomain -}}
{{- $_ := required "values.config.iaasProvider.auth.token.agencyName is required when auth.mode=token" .Values.config.iaasProvider.auth.token.agencyName -}}
{{- else if eq .Values.config.iaasProvider.auth.mode "ak-sk" -}}
{{- $_ := required "values.config.iaasProvider.auth.aksk.credentialsSecret is required when auth.mode=ak-sk" .Values.config.iaasProvider.auth.aksk.credentialsSecret -}}
{{- else -}}
{{- fail (printf "values.config.iaasProvider.auth.mode must be either \"token\" or \"ak-sk\", got %q" .Values.config.iaasProvider.auth.mode) -}}
{{- end -}}
{{- end }}
