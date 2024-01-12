{{/*
Create the migration init container.
*/}}
{{- define "velero.plugin.for.migration" -}}
{{- if .Values.veleroPluginForMigration.enabled -}}
    {{- if eq (typeOf .Values.veleroPluginForMigration.plugin) "string" }}
    {{- tpl .Values.veleroPluginForMigration.plugin . | nindent 8 }}
    {{- else }}
    {{- tpl (toYaml .Values.veleroPluginForMigration.plugin) . | nindent 8 }}
    {{- end }}
{{- end -}}
{{- end -}}