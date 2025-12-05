{{/*
Helpers related to rendering the OpenBao configuration JSON.
https://openbao.org/docs/configuration/
*/}}

{{/*
Return PostgreSQL configuration as yaml.

This is a hook to be overriden by the GitLab chart to easily override
this information.
*/}}
{{- define "openbao.postgresql.configuration" -}}
{{ toYaml .Values.config.storage.postgresql.connection }}
{{- end -}}

{{/*
Render PostgreSQL storage configuration.
*/}}
{{- define "openbao.storage.postgresql" -}}
{{- $psql := dict "connection_url" (include "openbao.storage.postgresql.connectionUrl" .) -}}
{{- with .Values.config.storage.postgresql -}}
  {{- with .table -}}
  {{ $_ := set $psql "table" . -}}
  {{- end -}}
  {{- with .haTable -}}
  {{ $_ := set $psql "ha_table" . -}}
  {{- end -}}
  {{- with .skipCreateTable -}}
  {{ $_ := set $psql "skip_create_table" . -}}
  {{- end -}}
  {{- with .maxConnectRetries -}}
  {{ $_ := set $psql "max_connect_retries" . -}}
  {{- end -}}
  {{- with .haEnabled -}}
  {{ $_ := set $psql "ha_enabled" . -}}
  {{- end -}}
{{- end -}}
{{- dict "postgresql" $psql | toPrettyJson -}}
{{- end -}}

{{/*
Render PostgreSQL connection URL.

The password is not contained in this URL, and must be configured via environment variables.
*/}}
{{- define "openbao.storage.postgresql.connectionUrl" -}}
{{- $psqlConfig := (include "openbao.postgresql.configuration" . | fromYaml) }}
{{- with $psqlConfig }}
  {{- $connectionUrl := printf "postgres://%s@%s:%d/%s?" .username .host (.port | int) .database -}}
  {{- with .keepalives -}}
  {{-   $connectionUrl = printf "%s&keepalives=%d" $connectionUrl (. | int) -}}
  {{- end -}}
  {{- with .keepalivesIdle -}}
  {{-   $connectionUrl = printf "%s&keepalives_idle=%d" $connectionUrl (. | int) -}}
  {{- end }}
  {{- with .keepalivesInterval -}}
  {{-   $connectionUrl = printf "%s&keepalives_interval=%d" $connectionUrl (. | int) -}}
  {{- end -}}
  {{- with .keepalivesCount -}}
  {{-   $connectionUrl = printf "%s&keepalives_count=%d" $connectionUrl (. | int) -}}
  {{- end -}}
  {{- with .tcpUserCount }}
  {{-   $connectionUrl = printf "%s&tcp_user_count=%d" $connectionUrl (. | int) -}}
  {{- end -}}
  {{- with .sslMode -}}
  {{-   $connectionUrl = printf "%s&sslmode=%s" $connectionUrl . -}}
  {{- end -}}
  {{- $connectionUrl -}}
{{- end -}}
{{- end -}}


{{/*
Pass metadata to Pod. Needed for self labeling.
*/}}
{{- define "openbao.serviceRegistration.config" -}}
"service_registration": {
  "kubernetes": {}
}
{{- end }}

{{/*
Render active TCP listener configuration.
*/}}
{{- define "openbao.listener.config" -}}
{{- $listeners := list -}}
{{/* Default listener */}}
{{- with .Values.config -}}
{{-   $defaultListener := dict "tls_disable" .tlsDisable -}}
{{-   if not .tlsDisable -}}
{{-     $_ := set $defaultListener "tls_cert_file" "/srv/openbao/tls/tls.crt" -}}
{{-     $_ := set $defaultListener "tls_key_file" "/srv/openbao/tls/tls.key" -}}
{{-   end -}}
{{-   $_ := set $defaultListener "address" (printf ":%d" (.apiPort | int)) -}}
{{-   $_ := set $defaultListener "max_request_size" (.maxRequestSize) -}}
{{-   $_ := set $defaultListener "max_request_json_memory" (.maxRequestJsonMemory) -}}
{{-   $listeners = append $listeners (dict "tcp" $defaultListener) -}}
{{- end -}}
{{/* Metrics listener */}}
{{- with .Values.config.metricsListener -}}
{{-   if .enabled -}}
{{-     $metricsListener := dict "tls_disable" .tlsDisable -}}
{{-     if not .tlsDisable -}}
{{-       $_ := set $metricsListener "tls_cert_file" "/srv/openbao/tls/tls.crt" -}}
{{-       $_ := set $metricsListener "tls_key_file" "/srv/openbao/tls/tls.key" -}}
{{-     end -}}
{{-     $_ := set $metricsListener "address" (printf ":%d" (.port | int)) -}}
{{-     $_ := set $metricsListener "telemetry" (dict "unauthenticated_metrics_access" .unauthenticatedMetricsAccess) -}}
{{-     $_ := set $metricsListener "max_request_size" ($.Values.config.maxRequestSize) -}}
{{-     $_ := set $metricsListener "max_request_json_memory" ($.Values.config.maxRequestJsonMemory) -}}
{{-     $listeners = append $listeners (dict "tcp" $metricsListener) -}}
{{-   end -}}
{{- end -}}
{{- toPrettyJson $listeners -}}
{{- end -}}

{{- define "openbao.telemetry.config" -}}
{{- with .Values.config.telemetry -}}
{{-   if .enabled }}
{{-     $tele := dict "disable_hostname" .disableHostname -}}
{{-     $_ := set $tele "prometheus_retention_time" .prometheusRetentionTime -}}
{{-     $_ := set $tele "metrics_prefix" .metricsPrefix -}}
{{-     $_ := set $tele "usage_gauge_period" .usageGaugePeriod -}}
{{-     $_ := set $tele "num_lease_metrics_buckets" .numLeaseMetricsBuckets -}}
{{-     $_ := set $tele "prefix_filter" .prefixFilter -}}
{{-     toPrettyJson $tele -}}
{{-   end }}
{{- end }}
{{- end }}

{{- define "openbao.seal.config" -}}
{{- $conf := dict }}
{{- with .Values.config.unseal.static }}
{{-   if .enabled }}
{{-     $static := dict "current_key_id" .currentKeyId "current_key" (printf "file://%s" .currentKey) }}
{{-     if .previousKeyId }}
{{        $_ := set "previous_key_id" .previousKeyId "previous_key" (printf "file://%s" .previousKey) }}
{{-     end }}
{{-     $_ := set $conf "static" $static }}
{{-   end }}
{{- end }}
{{- toPrettyJson $conf }}
{{- end }}

{{- define "openbao.initialize.config" -}}
{{- if .Values.config.initialize.enabled }}
{{- tpl .Values.initializeTpl . | fromYamlArray | toPrettyJson }}
{{- end }}
{{- end }}

{{- define "openbao.audit.config" -}}
{{- tpl .Values.auditTpl . | fromYamlArray | toPrettyJson }}
{{- end -}}

{{- define "openbao.logging.config" -}}
{{- with .Values.config -}}
"log_level": {{ .logLevel | quote }},
"log_requests_level": {{ .logRequestsLevel | quote }},
"log_format": {{ .logFormat | quote }}
{{- end -}}
{{- end -}}
