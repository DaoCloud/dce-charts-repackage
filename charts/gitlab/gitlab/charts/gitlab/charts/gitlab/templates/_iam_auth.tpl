{{/* ######### iam-auth service related templates */}}

{{/*
Return the iam-auth service token secret
*/}}

{{- define "gitlab.appConfig.iamAuthService.authToken.secret" -}}
{{- default (printf "%s-iam-auth-secret" .Release.Name) ((.Values.global.appConfig.iamAuthService).authToken).secret | quote -}}
{{- end -}}

{{- define "gitlab.appConfig.iamAuthService.authToken.key" -}}
{{- default "iam_auth_service_token" ((.Values.global.appConfig.iamAuthService).authToken).key | quote -}}
{{- end -}}

{{/*
Mount secret for iam-auth service token
*/}}
{{- define "gitlab.appConfig.iamAuthService.mountSecrets" -}}
{{- if .Values.global.appConfig.iamAuthService.enabled -}}
# mount secret for iam-auth service token
- secret:
    name: {{ template "gitlab.appConfig.iamAuthService.authToken.secret" . }}
    items:
      - key: {{ template "gitlab.appConfig.iamAuthService.authToken.key" . }}
        path: iam-auth/.gitlab_iam_auth_secret
{{- end -}}
{{- end -}}
