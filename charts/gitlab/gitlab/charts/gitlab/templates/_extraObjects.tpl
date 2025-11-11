{{/* vim: set filetype=mustache: */}}

{{- define "gitlab.extraContainers" -}}
{{ tpl (default "" .Values.extraContainers) . }}
{{- end -}}

{{- define "gitlab.extraInitContainers" -}}
{{ tpl (default "" .Values.extraInitContainers) . }}
{{- end -}}

{{- define "gitlab.extraVolumes" -}}
{{ tpl (default "" .Values.extraVolumes) . }}
{{- end -}}

{{- define "gitlab.extraVolumeMounts" -}}
{{ tpl (default "" .Values.extraVolumeMounts) . }}
{{- end -}}

