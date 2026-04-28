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
Configure cluster address based on IP via env.
*/}}
{{- define "openbao.clusterAddr.env" -}}
- name: BAO_K8S_POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
- name: VAULT_CLUSTER_ADDR
  value: {{ printf "https://$(BAO_K8S_POD_IP):%d" (.Values.config.clusterPort | int) }}
{{- end -}}

{{/*
Render the external OpenBao url. Overriden by GitLab chart.
*/}}
{{- define "gitlab.openbao.url" -}}
{{- $tls := eq "true" (include "gitlab.ingress.tls.enabled" .) -}}
{{- $scheme := $tls | ternary "https" "http" -}}
{{- printf "%s://%s" $scheme (include "gitlab.openbao.hostname" .) -}}
{{- end -}}
  
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
{{- if and (eq "nginx" .Values.global.ingress.provider) .Values.ingress.tls.enabled }}
  {{- if and (not .Values.config.tlsDisable) .Values.ingress.sslPassthroughNginx }}
nginx.ingress.kubernetes.io/ssl-passthrough: "true"
nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
  {{- end }}
  {{- if eq "true" (include "gitlab.openbao.configureCertmanager" .) }}
acme.cert-manager.io/http01-edit-in-place: {{ not .Values.global.ingress.useNewIngressForCerts | quote }}
cert-manager.io/issuer: {{ tpl .Values.ingress.certmanagerIssuer . | quote }}
cert-manager.io/issue-temporary-certificate: "false"
  {{- end }}
{{- end }}
{{- end }}

{{- define "openbao.extraVolumes" -}}
{{ tpl (default "" .Values.extraVolumes) . }}
{{- end -}}

{{- define "openbao.extraVolumeMounts" -}}
{{ tpl (default "" .Values.extraVolumeMounts) . }}
{{- end -}}

{{- define "openbao.image" -}}
{{- $repo := .Values.image.repository -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- $suf := .Values.global.image.tagSuffix -}}
{{- printf "%s:%s%s" $repo $tag $suf -}}
{{- end -}}

{{- define "openbao.readinessProbe" -}}
{{- $probe := .Values.readinessProbe -}}
{{- $isHttpProbeWithoutScheme := and $probe.httpGet (not (hasKey $probe.httpGet "scheme")) -}}
{{- if $isHttpProbeWithoutScheme -}}
{{-   $_ := set $probe.httpGet "scheme" (.Values.config.tlsDisable | ternary "HTTP" "HTTPS") -}}
{{- end -}}
{{- toYaml $probe }}
{{- end -}}

{{- define "openbao.livenessProbe" -}}
{{- $probe := .Values.livenessProbe -}}
{{- $isHttpProbeWithoutScheme := and $probe.httpGet (not (hasKey $probe.httpGet "scheme")) -}}
{{- if $isHttpProbeWithoutScheme -}}
{{-   $_ := set $probe.httpGet "scheme" (.Values.config.tlsDisable | ternary "HTTP" "HTTPS") -}}
{{- end -}}
{{- toYaml $probe }}
{{- end -}}
