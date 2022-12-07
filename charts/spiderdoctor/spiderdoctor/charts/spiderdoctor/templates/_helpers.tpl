{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "project.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the name of project .
*/}}
{{- define "project.name" -}}
{{- .Values.global.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
spiderdoctorAgent Common labels
*/}}
{{- define "project.spiderdoctorAgent.labels" -}}
helm.sh/chart: {{ include "project.chart" . }}
{{ include "project.spiderdoctorAgent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
spiderdoctorAgent Common labels
*/}}
{{- define "project.spiderdoctorController.labels" -}}
helm.sh/chart: {{ include "project.chart" . }}
{{ include "project.spiderdoctorController.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
spiderdoctorAgent Selector labels
*/}}
{{- define "project.spiderdoctorAgent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "project.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ .Values.spiderdoctorAgent.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
spiderdoctorAgent Selector labels
*/}}
{{- define "project.spiderdoctorController.selectorLabels" -}}
app.kubernetes.io/name: {{ include "project.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ .Values.spiderdoctorController.name | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/* vim: set filetype=mustache: */}}
{{/*
Renders a value that contains template.
Usage:
{{ include "tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}




{{/*
Return the appropriate apiVersion for poddisruptionbudget.
*/}}
{{- define "capabilities.policy.apiVersion" -}}
{{- if semverCompare "<1.21-0" .Capabilities.KubeVersion.Version -}}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "policy/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "capabilities.deployment.apiVersion" -}}
{{- if semverCompare "<1.14-0" .Capabilities.KubeVersion.Version -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}


{{/*
Return the appropriate apiVersion for RBAC resources.
*/}}
{{- define "capabilities.rbac.apiVersion" -}}
{{- if semverCompare "<1.17-0" .Capabilities.KubeVersion.Version -}}
{{- print "rbac.authorization.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
return the spiderdoctorAgent image
*/}}
{{- define "project.spiderdoctorAgent.image" -}}
{{- $registryName := .Values.spiderdoctorAgent.image.registry -}}
{{- $repositoryName := .Values.spiderdoctorAgent.image.repository -}}
{{- if .Values.global.imageRegistryOverride }}
    {{- printf "%s/%s" .Values.global.imageRegistryOverride $repositoryName -}}
{{ else if $registryName }}
    {{- printf "%s/%s" $registryName $repositoryName -}}
{{- else -}}
    {{- printf "%s" $repositoryName -}}
{{- end -}}
{{- if .Values.spiderdoctorAgent.image.digest }}
    {{- print "@" .Values.spiderdoctorAgent.image.digest -}}
{{- else if .Values.global.imageTagOverride -}}
    {{- printf ":%s" .Values.global.imageTagOverride -}}
{{- else if .Values.spiderdoctorAgent.image.tag -}}
    {{- printf ":%s" .Values.spiderdoctorAgent.image.tag -}}
{{- else -}}
    {{- printf ":v%s" .Chart.AppVersion -}}
{{- end -}}
{{- end -}}


{{/*
return the spiderdoctorController image
*/}}
{{- define "project.spiderdoctorController.image" -}}
{{- $registryName := .Values.spiderdoctorController.image.registry -}}
{{- $repositoryName := .Values.spiderdoctorController.image.repository -}}
{{- if .Values.global.imageRegistryOverride }}
    {{- printf "%s/%s" .Values.global.imageRegistryOverride $repositoryName -}}
{{ else if $registryName }}
    {{- printf "%s/%s" $registryName $repositoryName -}}
{{- else -}}
    {{- printf "%s" $repositoryName -}}
{{- end -}}
{{- if .Values.spiderdoctorController.image.digest }}
    {{- print "@" .Values.spiderdoctorController.image.digest -}}
{{- else if .Values.global.imageTagOverride -}}
    {{- printf ":%s" .Values.global.imageTagOverride -}}
{{- else if .Values.spiderdoctorController.image.tag -}}
    {{- printf ":%s" .Values.spiderdoctorController.image.tag -}}
{{- else -}}
    {{- printf ":v%s" .Chart.AppVersion -}}
{{- end -}}
{{- end -}}


{{/*
generate the CA cert
*/}}
{{- define "generate-ca-certs" }}
    {{- $ca := genCA "spidernet.io" (.Values.spiderdoctorController.tls.auto.caExpiration | int) -}}
    {{- $_ := set . "ca" $ca -}}
{{- end }}

{{- define "project.spiderdoctorAgent.serviceIpv4Name" -}}
{{- printf "%s-ipv4" .Values.spiderdoctorAgent.name -}}
{{- end -}}

{{- define "project.spiderdoctorAgent.serviceIpv6Name" -}}
{{- printf "%s-ipv6" .Values.spiderdoctorAgent.name -}}
{{- end -}}

{{- define "project.spiderdoctorAgent.ingressName" -}}
{{- printf "%s" .Values.spiderdoctorAgent.name -}}
{{- end -}}
