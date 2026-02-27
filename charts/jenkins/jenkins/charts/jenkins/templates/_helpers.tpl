{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "jenkins.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "jenkins.namespace" -}}
{{- default .Release.Namespace -}}
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
        {{- if contains .Release.Name $name -}}
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

{{- define "jenkins-agent.jnlp.image" }}
    {{- include "jenkins.images.image" ( dict "imageRoot" .Values.Agent "global" .Values.global "root" .Values.image ) }}
{{- end -}}

{{- define "jenkins-agent.volume" -}}
{{- if eq .Values.Agent.Builder.ContainerRuntime "docker" }}
- hostPathVolume:
    hostPath: "/var/run/docker.sock"
    mountPath: "/var/run/docker.sock"
{{- else }}
- configMapVolume:
    mountPath: /etc/containers/registries.conf.d
    configMapName: insecure-registries
    optional: true
{{- end }}
{{- end -}}


{{- define "jenkins.image.pullPolicy" -}}
    {{- print .Values.pullPolicy -}}
{{- end -}}

{{- define "jenkins.master.javaOpts" -}}
    {{- $javaOpts := default "" .Values.Master.JavaOpts | replace "\n" " " }}
    {{- if .Values.trace.enabled  }}
       {{- $javaOpts = printf "%s -javaagent:/otel-auto-instrumentation/javaagent.jar" $javaOpts -}} 
    {{- end }}
{{- $javaOpts -}}
{{- end -}}

{{- define "jenkins.event.receiver" -}}
    {{- $defaultReceiver := "http://amamba-devops-server.amamba-system:80/apis/internel.amamba.io/devops/pipeline/v1alpha1/webhooks/jenkins" -}}
    {{- $sidecarReceiver := "http://localhost:9090/event" -}}
    {{- $target := "" -}}
    {{- if and .Values.eventProxy .Values.eventProxy.enabled -}}
        {{- $target = $sidecarReceiver -}}
    {{- else -}}
        {{- if and .Values.plugins .Values.plugins.eventDispatcher .Values.plugins.eventDispatcher.receiver -}}
            {{- $target = .Values.plugins.eventDispatcher.receiver -}}
        {{- else -}}
            {{- $target = $defaultReceiver -}}
        {{- end -}}
    {{- end -}}
    {{ print $target }}
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


{{- define "jenkins.event-proxy.image" -}}
    {{- printf "%s/%s:%s" .Values.image.registry .Values.eventProxy.image.repository .Values.eventProxy.image.tag -}}
{{- end -}}


{{- define "jenkins.event-proxy.pullPolicy" -}}
    {{- print .Values.eventProxy.imagePullPolicy -}}
{{- end -}}

{{- define "jenkins.event-proxy.config" -}}
{{- with .Values.eventProxy.configMap -}}
eventProxy:
  host: {{ .eventProxy.host }}
  proto: {{ .eventProxy.proto }}
  webhookUrl: {{ .eventProxy.webhookUrl }}
discardStrategy: {{ toYaml .discardStrategy | nindent 2 }}
timeout: {{ toYaml .timeout | nindent 2 }}
retryConfig: {{ toYaml .retryConfig | nindent 2 }}
rateLimiterConfig: {{ toYaml .rateLimiterConfig | nindent 2 }}
{{- end }}
{{- end -}}

{{- define "jenkins.event-proxy.tokenEnv" -}}
- name: AMAMBA_EVENTPROXY_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ template "jenkins.fullname" . }}
      key: event-proxy-token
{{- end -}}

{{/*like: 0.1.10+dev-616d4c10 is illegal in label*/}}
{{- define "charts.version" -}}
    {{- printf .Chart.Version |replace "+" "-" -}}
{{- end -}}
