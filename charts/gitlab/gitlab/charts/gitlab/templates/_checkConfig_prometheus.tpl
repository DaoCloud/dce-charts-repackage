
{{/*
Ensure that no deprecated Prometheus config is present.
*/}}
{{- define "gitlab.checkConfig.prometheus" -}}
{{- $prom := .Values.prometheus }}
{{- if $prom.install -}}
{{-   if or (hasKey $prom "pushgateway") (hasKey $prom "nodeExporter") (hasKey $prom "kubeStateMetrics") (hasKey $prom "alertmanagerFiles") }}
prometheus:
  Detected deprecated values for the Prometheus subchart.
  Please update your configuration per https://docs.gitlab.com/charts/releases/9_0/#prometheus-upgrade.
{{-   end -}}
{{- end -}}
{{- end -}}
