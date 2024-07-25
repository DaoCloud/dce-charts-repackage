
{{/*
return the driver image
*/}}
{{- define "driver.image" -}}
{{ if .Values.image.tagOverwrite }}
  {{- printf "%s/%s:%s" .Values.image.registry .Values.image.repository .Values.image.tagOverwrite -}}
{{- else -}}
  {{- printf "%s/%s:%s-%s%s-%s" .Values.image.registry .Values.image.repository .Values.image.driverVersion .Values.image.OSName .Values.image.OSVer .Values.image.Arch -}}
{{- end -}}
{{- end -}}

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

