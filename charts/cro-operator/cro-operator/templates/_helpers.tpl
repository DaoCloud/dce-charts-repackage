{{/* vim: set filetype=mustache: */}}
{{/*

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "openshift.clusterResourceOverride.operator.fullname" -}}
{{- printf "%s" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Return the proper image name
*/}}
{{- define "openshift.clusterResourceOverride.operator.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image Registry Secret Names
*/}}
{{- define "openshift.clusterResourceOverride.operator.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image) "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name
*/}}
{{- define "openshift.clusterResourceOverride.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.clusterResourceOverride.image "global" .Values.global) }}
{{- end -}}
