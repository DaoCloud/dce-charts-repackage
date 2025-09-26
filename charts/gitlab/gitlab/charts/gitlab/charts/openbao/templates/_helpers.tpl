{{/*
Expand the name of the chart.
*/}}
{{- define "openbao.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "openbao.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "openbao.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "openbao.labels" -}}
helm.sh/chart: {{ include "openbao.chart" . }}
{{ include "openbao.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "openbao.selectorLabels" -}}
app.kubernetes.io/name: {{ include "openbao.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "openbao.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "openbao.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

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
{{- define "openbao.serviceRegistration.env" -}}
- name: BAO_K8S_POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: BAO_K8S_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
{{- end }}


{{/*
Pass metadata to Pod. Needed for self labeling.
*/}}
{{- define "openbao.serviceRegistration.config" -}}
"service_registration": {
  "kubernetes": {}
}
{{- end }}

{{/*
Render the internal URL.
*/}}
{{- define "openbao.internalUrl" -}}
{{- $scheme := .Values.config.tlsDisable | ternary "http" "https" }}
{{- $hostname := include "gitlab.openbao.hostname" . -}}
{{- $port := .Values.config.apiPort }}
{{- printf "%s://%s:%d" $scheme $hostname ($port | int) }} 
{{- end }}

{{/*
Render extra Ingress annotations. If internal TLS is enabled,
we default to ssl passthrough for full end to end encryption.

We disable in place editing for certmanager, because the DNS
challange must go throught a non-HTTPS backend.
*/}}
{{- define "openbao.ingress.annotations" }}
{{- if not .Values.config.tlsDisable }}
  {{- if eq "nginx" .Values.global.ingress.provider }}
nginx.ingress.kubernetes.io/ssl-passthrough: "true"
nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
  {{- end }}
acme.cert-manager.io/http01-edit-in-place: "false"
{{- end }}
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
{{-     toPrettyJson $tele -}}
{{-   end }}
{{- end }}
{{- end }}
