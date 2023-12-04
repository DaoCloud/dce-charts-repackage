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

{{- define "gitlab.extraEnvFrom" -}}
{{- $global := deepCopy (get .root.Values.global "extraEnvFrom" | default (dict)) -}}
{{- $values := deepCopy (get .root.Values "extraEnvFrom" | default (dict)) -}}
{{- $local  := deepCopy (get .local "extraEnvFrom" | default (dict)) -}}
{{- $allExtraEnvFrom := mergeOverwrite $global $values $local -}}
{{- range $key, $value := $allExtraEnvFrom }}
- name: {{ $key }}
  valueFrom: 
{{ toYaml $value | nindent 4 }}
{{- end -}}
{{- end -}}

{{/*
Returns the extraEnv keys and values to inject into containers.

Global values will override any chart-specific values.
*/}}
{{- define "gitlab.extraEnv" -}}
{{- $allExtraEnv := merge (default (dict) .Values.extraEnv) .Values.global.extraEnv -}}
{{- range $key, $value := $allExtraEnv }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end -}}
{{- end -}}

{{/*
Detect whether to include internal Gitaly resources.
Returns `true` when:
  - Internal Gitaly is on
  AND
  - Either:
    - Praefect is off, or
    - Praefect is on, but replaceInternalGitaly is off
*/}}
{{- define "gitlab.gitaly.includeInternalResources" -}}
{{- if and .Values.global.gitaly.enabled (or (not .Values.global.praefect.enabled) (and .Values.global.praefect.enabled (not .Values.global.praefect.replaceInternalGitaly))) -}}
{{-   true }}
{{- end -}}
{{- end -}}
