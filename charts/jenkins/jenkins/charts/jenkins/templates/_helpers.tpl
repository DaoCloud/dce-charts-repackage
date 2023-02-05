{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "jenkins.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "jenkins.fullname" -}}
    {{- if .Values.fullnameOverride -}}
        {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
        {{- $name := default .Chart.Name .Values.nameOverride -}}
        {{- if contains "$name" ".Release.Name" -}}
            {{- .Release.Name | trunc 63 | trimSuffix "-" -}}
        {{- else -}}
            {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Returns the admin password
https://github.com/helm/charts/issues/5167#issuecomment-619137759
*/}}
{{- define "jenkins.password" -}}
  {{- if .Values.Master.AdminPassword -}}
    {{- .Values.Master.AdminPassword | b64enc | quote }}
  {{- else -}}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace (include "jenkins.fullname" .)).data -}}
    {{- if $secret -}}
      {{/*
        Reusing current password since secret exists
      */}}
      {{- index $secret "jenkins-admin-password" -}}
    {{- else -}}
      {{/*
          Generate new password
      */}}
      {{- randAlphaNum 22 | b64enc | quote }}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "jenkins.agent.variant" -}}
    {{ if eq .Values.Agent.Builder.ContainerRuntime "podman" }}
    {{- print "-podman" -}}
    {{- end -}}
{{- end -}}

{{- define "jenkins.agent.privileged" -}}
    {{ if eq .Values.Agent.Builder.ContainerRuntime "podman" }}
    {{- print "true" -}}
    {{- else -}}
    {{- print "false" -}}
    {{- end -}}
{{- end -}}

{{- define "jenkins.image" -}}
    {{- $jenkinsRegistryName := .Values.registry -}}
    {{- $repositoryName := .Values.Master.Image -}}
    {{- printf "%s/%s:%s" $jenkinsRegistryName $repositoryName .Values.Master.ImageTag -}}
{{- end -}}

{{- define "jenkins-agent.image.registry" -}}
    {{- $jenkinsRegistryName := .Values.registry -}}
    {{- printf "%s" $jenkinsRegistryName -}}
{{- end -}}

{{- define "jenkins-agent.jnlp.image" -}}
    {{- $registry := include "jenkins-agent.image.registry" . -}}
    {{- printf "%s/%s:%s" $registry .Values.Agent.Image .Values.Agent.ImageTag -}}
{{- end -}}

{{- define "jenkins.image.pullPolicy" -}}
    {{- print .Values.pullPolicy -}}
{{- end -}}

{{- define "jenkins.event.receiver" -}}
    {{- $defaultReceiver := "http://amamba-devops-server.%s:80/apis/internel.amamba.io/devops/pipeline/v1alpha1/webhooks/jenkins" -}}
    {{- if .Values.plugins  -}}
        {{- if .Values.plugins.eventDispatcher -}}
            {{- if .Values.plugins.eventDispatcher.receiver -}}
                 {{- print .Values.plugins.eventDispatcher.receiver -}}
            {{- else -}}
                 {{- printf  $defaultReceiver .Release.Namespace -}}
            {{- end -}}
        {{- else -}}
            {{- printf  $defaultReceiver .Release.Namespace -}}
        {{- end -}}
    {{- else -}}
        {{- printf  $defaultReceiver .Release.Namespace -}}
    {{- end -}}
{{- end -}}

{{- define "svc.serviceType" -}}
    {{- if .Values.Master.Deploy.NotWithApiServer -}}
        {{- printf "NodePort" -}}
    {{- else -}}
        {{- printf .Values.Master.ServiceType -}}
    {{- end -}}
{{- end -}}


{{- define "svc.nodePort" -}}
    {{- if .Values.Master.Deploy.NotWithApiServer -}}
        {{- if (not (empty .Values.Master.NodePort)) -}}
            {{- printf "%v" .Values.Master.NodePort -}}
        {{- else -}}
            {{- printf "31767" -}}
        {{- end -}}
    {{- else -}}
        {{- if (and (eq .Values.Master.ServiceType "NodePort") (not (empty .Values.Master.NodePort))) -}}
            {{- printf "%v" .Values.Master.NodePort -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{- define "location.url" -}}
    {{- if .Values.Master.Deploy.NotWithApiServer -}}
        {{- if (empty .Values.Master.Deploy.JenkinsHost) -}}
            {{- fail  "value for Values.Master.Deploy.JenkinsHost is not as expected" -}}
        {{- end -}}
        {{- $port := include "svc.nodePort" . -}}
        {{- printf "http://%s:%s" .Values.Master.Deploy.JenkinsHost $port -}}
    {{- else -}}
        {{- $fullname := include "jenkins.fullname" . -}}
        {{- printf "http://%s:%v" $fullname .Values.Master.ServicePort -}}
    {{- end -}}
{{- end -}}


{{- define "amamba.event-proxy.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.eventProxy.image) }}
{{- end -}}


{{- define "amamba.event-proxy.pullPolicy" -}}
    {{- print .Values.eventProxy.imagePullPolicy -}}
{{- end -}}

{{- define "amamba.namespace" -}}
{{- default .Release.Namespace -}}
{{- end -}}