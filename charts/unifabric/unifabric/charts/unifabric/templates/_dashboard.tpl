{{/*
Dashboard languages selected by grafanaDashboard.language: en, zh or all.
*/}}
{{- define "unifabric.dashboardLanguages" -}}
{{- $language := .Values.grafanaDashboard.language | default "en" -}}
{{- if eq $language "all" -}}
en,zh
{{- else if or (eq $language "en") (eq $language "zh") -}}
{{ $language }}
{{- else -}}
{{- fail (printf "grafanaDashboard.language must be en, zh or all, got %q" $language) -}}
{{- end -}}
{{- end -}}

{{/*
Renders one dashboard file as a GrafanaDashboard or a ConfigMap.
English dashboards keep their historical resource names, Chinese ones get a
-zh suffix so both languages can be installed side by side.
Expects a dict with root, path, name and language.
*/}}
{{- define "unifabric.dashboard" -}}
{{- $root := .root -}}
{{- $suffix := ternary "" "-zh" (eq .language "en") -}}
{{- $resourceName := printf "%s-%s%s" $root.Release.Name .name $suffix | trunc 63 | trimSuffix "-" -}}
{{- if eq $root.Values.grafanaDashboard.kind "GrafanaDashboard" }}
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: {{ $resourceName }}
  namespace: {{ $root.Release.Namespace }}
  labels:
    {{- include "unifabric.labels" $root | nindent 4 }}
    app.kubernetes.io/component: unifabric
    unifabric.io/dashboard-language: {{ .language }}
    {{- with $root.Values.grafanaDashboard.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  allowCrossNamespaceImport: {{ $root.Values.grafanaDashboard.allowCrossNamespaceImport }}
  instanceSelector:
    {{- include "unifabric.grafanaInstanceSelector" $root | nindent 4 }}
  json: {{ $root.Files.Get .path | toJson }}
{{- else }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $resourceName }}
  namespace: {{ $root.Release.Namespace }}
  labels:
    {{- include "unifabric.labels" $root | nindent 4 }}
    app.kubernetes.io/component: unifabric
    unifabric.io/dashboard-language: {{ .language }}
    grafana_dashboard: "1"
    {{- with $root.Values.grafanaDashboard.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
data:
  {{ printf "%s%s.json" .name $suffix }}: |-
    {{- $root.Files.Get .path | nindent 4 }}
{{- end }}
{{- end -}}

{{/*
Renders every dashboard matching a file glob pattern inside each selected
language directory. Expects a dict with root and pattern.
*/}}
{{- define "unifabric.dashboards" -}}
{{- $root := .root -}}
{{- range $language := splitList "," (include "unifabric.dashboardLanguages" $root) }}
{{- range $path, $_ := $root.Files.Glob (printf "files/dashboard-%s/%s" $language $.pattern) }}
{{- $name := trimSuffix ".json" (base $path) }}
---
{{ include "unifabric.dashboard" (dict "root" $root "path" $path "name" $name "language" $language) }}
{{- end }}
{{- end }}
{{- end -}}
