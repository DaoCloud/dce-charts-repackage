{{/*
Expand the name of the chart.
*/}}
{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "opentelemetry-demo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "otel-demo-ui.selectorLabels" -}}
app.kubernetes.io/name: {{ include "otel-demo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
redis selector
*/}}
{{- define "redis.addr" -}}
{{- if .Values.redis_resource.enabled -}}
redis-standalone.{{ .Release.Namespace }}.svc.cluster.local:6379
{{- else -}}
{{ include "otel-demo.name" . }}-redis:6379
{{- end }}
{{- end }}
