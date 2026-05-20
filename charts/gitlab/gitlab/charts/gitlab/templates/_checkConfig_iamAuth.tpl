{{/*
Ensures that http.host is configured when iamAuthService is enabled
*/}}
{{- define "gitlab.checkConfig.iamAuthService.http.host" -}}
  {{- with .Values.global.appConfig.iamAuthService -}}
    {{- if .enabled -}}
      {{- if not (dig "http" "host" "" .) }}
iamAuthService:
    http.host is required when iamAuthService is enabled. Please set `global.appConfig.iamAuthService.http.host`.
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.iamAuthService.http.host */}}

{{/*
Ensures that http.port is configured when iamAuthService is enabled
*/}}
{{- define "gitlab.checkConfig.iamAuthService.http.port" -}}
  {{- with .Values.global.appConfig.iamAuthService -}}
    {{- if .enabled -}}
      {{- if not (dig "http" "port" 0 .) }}
iamAuthService:
    http.port is required when iamAuthService is enabled. Please set `global.appConfig.iamAuthService.http.port`.
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.iamAuthService.http.port */}}

{{/*
Ensures that grpc.host is configured when iamAuthService is enabled
*/}}
{{- define "gitlab.checkConfig.iamAuthService.grpc.host" -}}
  {{- with .Values.global.appConfig.iamAuthService -}}
    {{- if .enabled -}}
      {{- if not (dig "grpc" "host" "" .) }}
iamAuthService:
    grpc.host is required when iamAuthService is enabled. Please set `global.appConfig.iamAuthService.grpc.host`.
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.iamAuthService.grpc.host */}}

{{/*
Ensures that grpc.port is configured when iamAuthService is enabled
*/}}
{{- define "gitlab.checkConfig.iamAuthService.grpc.port" -}}
  {{- with .Values.global.appConfig.iamAuthService -}}
    {{- if .enabled -}}
      {{- if not (dig "grpc" "port" 0 .) }}
iamAuthService:
    grpc.port is required when iamAuthService is enabled. Please set `global.appConfig.iamAuthService.grpc.port`.
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.iamAuthService.grpc.port */}}
