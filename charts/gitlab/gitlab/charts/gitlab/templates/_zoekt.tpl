{{/*
Return the Zoekt basic auth password secret name
*/}}

{{- define "gitlab.zoekt.gateway.basicAuth.secretName" -}}
{{- if .Values.global.zoekt.gateway.basicAuth.secretName }}
    {{- printf "%s" (tpl .Values.global.zoekt.gateway.basicAuth.secretName $) -}}
{{- else -}}
    {{- printf "%s-zoekt-basicauth" .Release.Name -}}
{{- end -}}
{{- end -}}
