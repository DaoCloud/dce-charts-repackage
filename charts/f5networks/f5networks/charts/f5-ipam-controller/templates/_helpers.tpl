{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "f5-ipam-controller.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Check for user given namespace or give kube-system
*/}}
{{- define "f5-ipam-controller.namespace" -}}
{{- if hasKey .Values "namespace" -}}
{{- .Values.namespace -}}
{{- else -}}
{{- print "kube-system" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "f5-ipam-controller.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "f5-ipam-controller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

 {{/*
Create the name of the service account to use
*/}}
{{- define "f5-ipam-controller.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "f5-ipam-controller.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


 {{/*
Create the name of the Persistent Volume Claim to use
*/}}
{{- define "f5-ipam-controller.persistentVolumeClaimName" -}}
{{- if .Values.pvc.create -}}
    {{ default (include "f5-ipam-controller.fullname" .) .Values.pvc.name }}
{{- else -}}
    {{ default "default" .Values.pvc.name }}
{{- end -}}
{{- end -}}
