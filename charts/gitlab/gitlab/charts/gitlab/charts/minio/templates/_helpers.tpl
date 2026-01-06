{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "minio.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "minio.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for networkpolicy.
*/}}
{{- define "minio.networkPolicy.apiVersion" -}}
{{- if and (ge .Capabilities.KubeVersion.Minor "4") (le .Capabilities.KubeVersion.Minor "6") -}}
{{- print "extensions/v1beta1" -}}
{{- else if ge .Capabilities.KubeVersion.Minor "7" -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified job name for creating default buckets.
*/}}
{{- define "minio.createBucketsJobName" -}}
{{- $name := include "minio.fullname" . | trunc 40 | trimSuffix "-" -}}
{{- printf "%s-create-buckets-%s" $name ( include "gitlab.jobNameSuffix" . ) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Returns the secret name for the Secret containing the TLS certificate and key.
Uses `ingress.tls.secretName` first and falls back to `global.ingress.tls.secretName`
if there is a shared tls secret for all ingresses.
*/}}
{{- define "minio.tlsSecret" -}}
{{- $defaultName := (dict "secretName" "") -}}
{{- if .Values.global.ingress.configureCertmanager -}}
{{- $_ := set $defaultName "secretName" (printf "%s-minio-tls" .Release.Name) -}}
{{- else -}}
{{- $_ := set $defaultName "secretName" (include "gitlab.wildcard-self-signed-cert-name" .) -}}
{{- end -}}
{{- pluck "secretName" .Values.ingress.tls .Values.global.ingress.tls $defaultName | first -}}
{{- end -}}

{{/*
Return the formatted annotations for the PersistentVolumeClaim.
*/}}
{{- define "minio.persistence.annotations" -}}
{{-   if .Values.persistence.annotations -}}
{{-     toYaml .Values.persistence.annotations -}}
{{-   end -}}
{{- end -}}

{{/*
Returns the MinIO image with its corresponding tag. For tags that are known to
exist in the GitLab mirror, the function returns the image-tag combination from
the GitLab image mirror.
*/}}
{{- define "minio.image" -}}
{{-   $gitlabMirror := "registry.gitlab.com/gitlab-org/cloud-native/mirror/images" }}
{{-   $mirroredTags := list "RELEASE.2017-12-28T01-21-00Z" "RELEASE.2020-09-21T22-31-59Z-arm64" -}}
{{-   $image := .Values.image -}}
{{-   $tag := .Values.imageTag -}}
{{-   if and (eq $image "minio/minio") (has $tag $mirroredTags) -}}
{{-     printf "%s/%s:%s" $gitlabMirror $image $tag }}
{{-   else -}}
{{-     printf "%s:%s" $image $tag -}}
{{-   end -}}
{{- end -}}

{{/*
Returns the MinIO MC image with its corresponding tag. For tags that are known to
exist in the GitLab mirror, the function returns the image-tag combination from
the GitLab image mirror.
*/}}
{{- define "minio.mc.image" -}}
{{-   $gitlabMirror := "registry.gitlab.com/gitlab-org/cloud-native/mirror/images" }}
{{-   $mirroredTags := list "RELEASE.2018-07-13T00-53-22Z" "RELEASE.2020-09-23T20-02-13Z-arm64" -}}
{{-   $image := .Values.minioMc.image -}}
{{-   $tag := .Values.minioMc.tag -}}
{{-   if and (eq $image "minio/mc") (has $tag $mirroredTags) -}}
{{-     printf "%s/%s:%s" $gitlabMirror $image $tag }}
{{-   else -}}
{{-     printf "%s:%s" $image $tag -}}
{{-   end -}}
{{- end -}}