{{/*
Ingress related templates to integrate with GitLab helm chart.
The GitLab helm chart overrides these with it's own implementation.
*/}}

{{/* Check if the Ingress should be enabled */}}
{{- define "gitlab.ingress.enabled" -}}
{{- .Values.ingress.enabled -}}
{{- end -}}

{{/* Renders the ingressClassName field. */}}
{{- define "ingress.class.field" -}}
{{- $class := (include "ingress.class.name" .) -}}
{{- if $class -}}
ingressClassName: {{ $class }}
{{- end -}}
{{- end -}}

{{/* Render the IngressClass name. */}}
{{- define "ingress.class.name" -}}
{{ .local.className }}
{{- end -}}

{{/* Render the hostname. */}}
{{- define "gitlab.openbao.hostname" -}}
{{ .Values.ingress.hostname }}
{{- end -}}

{{/* Check if the Ingress should enable TLS */}}
{{- define "gitlab.ingress.tls.enabled" -}}
{{ .Values.ingress.tls.enabled }}
{{- end -}}

{{/* Render the name of the Ingress TLS secret */}}
{{- define "gitlab.openbao.tlsSecret" -}}
{{- .Values.tlsSecretName | default (include "gitlab.openbao.ingress.tlsSecret" .) }}
{{- end -}}

{{/* Render the name of the TLS secret */}}
{{- define "gitlab.openbao.ingress.tlsSecret" -}}
{{ .Values.ingress.tls.secretName | default (printf "%s-openbao-tls" .Release.Name) }}
{{- end -}}

{{- define "gitlab.openbao.configureCertmanager" -}}
{{- if eq nil .Values.ingress "configureCertmanager" -}}
{{-   .Values.ingress.configureCertmanager -}}
{{- else -}}
{{-   .Values.ingress.tls.enabled -}}
{{- end -}}
{{- end -}}
