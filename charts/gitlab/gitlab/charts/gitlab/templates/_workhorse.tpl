{{/* ######### gitlab-workhorse related templates */}}

{{/*
Return the gitlab-workhorse secret
*/}}

{{- define "gitlab.workhorse.secret" -}}
{{- default (printf "%s-gitlab-workhorse-secret" .Release.Name) .Values.global.workhorse.secret | quote -}}
{{- end -}}

{{- define "gitlab.workhorse.key" -}}
{{- default "shared_secret" .Values.global.workhorse.key | quote -}}
{{- end -}}

{{/*
Return the workhorse url
*/}}
{{- define "gitlab.workhorse.url" -}}
{{ template "gitlab.workhorse.scheme" . }}://{{ template "gitlab.workhorse.host" . }}:{{ template "gitlab.workhorse.port" . }}{{ .Values.global.appConfig.relativeUrlRoot }}
{{- end -}}

{{- define "gitlab.workhorse.scheme" -}}
{{- $scheme := "http" -}}
{{- if .Values.global.workhorse.tls.enabled -}}
{{-   $scheme = "https" -}}
{{- end -}}
{{- coalesce .Values.workhorse.scheme .Values.global.workhorse.scheme $scheme -}}
{{- end -}}

{{/*
Return the workhorse hostname
If the workhorse host is provided, it will use that, otherwise it will fallback
to the service name
*/}}
{{- define "gitlab.workhorse.host" -}}
{{- $hostname := default .Values.global.workhorse.host .Values.workhorse.host -}}
{{- if empty $hostname -}}
{{-   $name := default .Values.global.workhorse.serviceName .Values.workhorse.serviceName -}}
{{-   $hostname = printf "%s-%s.%s.svc" .Release.Name $name .Release.Namespace -}}
{{- end -}}
{{- $hostname -}}
{{- end -}}

{{- define "gitlab.workhorse.port" -}}
{{- coalesce .Values.workhorse.port .Values.global.workhorse.port "8181" -}}
{{- end -}}

{{- define "gitlab.workhorse.shutdownTimeout" -}}
{{- $timeout := add 1 $.Values.global.webservice.workerTimeout -}}
{{- $shutdownTimeout := printf "%ss" ($timeout | toString) -}}
{{- coalesce $.Values.workhorse.shutdownTimeout $shutdownTimeout -}}
{{- end -}}

{{/*
Return the workhorse Redis TLS configuration section
*/}}
{{- define "gitlab.workhorse.redis.tls" -}}
{{- if eq (default "redis" .redisMergedConfig.scheme) "rediss" }}
{{-   $redisTLS := .redisMergedConfig.redisTLS | default (dict) -}}
{{-   if or $redisTLS.caFile $redisTLS.cert $redisTLS.key }}
[redis.tls]
{{-     if $redisTLS.cert }}
certificate = "/etc/gitlab/redis/{{ $redisTLS.cert.key | default "cert" }}"
{{-     end }}
{{-     if $redisTLS.key }}
key = "/etc/gitlab/redis/{{ $redisTLS.key.key | default "key" }}"
{{-     end }}
{{-     if $redisTLS.caFile }}
ca_certificate = "/etc/gitlab/redis/{{ $redisTLS.caFile.key | default "ca.crt" }}"
{{-     end }}
{{-   end }}
{{- end }}
{{- end -}}

{{/*
Return the workhorse Sentinel TLS configuration section
*/}}
{{- define "gitlab.workhorse.sentinel.tls" -}}
{{- $sentinelTLS := .redisMergedConfig.sentinelTLS | default (dict) -}}
{{- if and .redisMergedConfig.sentinels $sentinelTLS.enabled }}
[Sentinel.tls]
{{-   if $sentinelTLS.cert }}
certificate = "/etc/gitlab/redis-sentinel/{{ $sentinelTLS.cert.key | default "cert" }}"
{{-   end }}
{{-   if $sentinelTLS.key }}
key = "/etc/gitlab/redis-sentinel/{{ $sentinelTLS.key.key | default "key" }}"
{{-   end }}
{{-   if $sentinelTLS.caFile }}
ca_certificate = "/etc/gitlab/redis-sentinel/{{ $sentinelTLS.caFile.key | default "ca.crt" }}"
{{-   end }}
{{- end }}
{{- end -}}
