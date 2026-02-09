{{/*
Render monitoring annotations for services.

These render both the default prometheus annotation, as well as the annotations
used by the Prometheus bundled with GitLab chart.
*/}}
{{- define "openbao.monitoring.annotations" }}
{{- with .Values.config.metricsListener }}
gitlab.com/prometheus_scrape: {{ .enabled | quote }}
prometheus.io/scrape: {{ .enabled | quote }}
  {{- if .enabled }}
gitlab.com/prometheus_port: {{ .port | quote }}
prometheus.io/port: {{ .port | quote }}
gitlab.com/prometheus_path: "/v1/sys/metrics"
prometheus.io/path: "/v1/sys/metrics"
prometheus.io/param_format: "prometheus"
gitlab.com/prometheus_param_format: "prometheus"
    {{- $scheme := include "openbao.monitoring.scheme" $ }}
gitlab.com/prometheus_scheme: {{ $scheme | quote }}
prometheus.io/scheme: {{ $scheme | quote }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Determine the monitoring scheme (http or https) based on TLS configuration.
*/}}
{{- define "openbao.monitoring.scheme" }}
{{- ternary "http" "https" .Values.config.metricsListener.tlsDisable }}
{{- end }}
