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

{{/* Render the name of the TLS secret */}}
{{- define "gitlab.openbao.tlsSecret" -}}
{{ .Values.ingress.secretName | default (printf "%s-openbao-tls" .Release.Name) }}
{{- end -}}

{{- define "gitlab.openbao.configureCertmanager" }}
{{- .Values.ingress.configureCertmanager -}}
{{- end }}

{{- define "gitlab.certmanagerIssuerRef" }}
issuerRef:
  {{- with .Values.ingress.certmanagerIssuerRef.name }}
  name: {{ . }}
  {{- else }}
  name: {{ printf "%s-issuer" .Release.Name }}
  {{- end }}
  {{- with .Values.ingress.certmanagerIssuerRef.kind }}
  kind: {{ . }}
  {{- end }}
{{- end }}
