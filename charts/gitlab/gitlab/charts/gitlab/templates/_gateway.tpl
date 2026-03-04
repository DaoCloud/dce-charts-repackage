{{/*
Returns name of the Gateway class. Consumed by chart managed Gateway and GatewayClass.
*/}}
{{- define "gitlab.gatewayApi.class.name" -}}
{{- .Values.global.gatewayApi.class.name -}}
{{- end -}}

{{/*
Returns the name of the EnvoyProxy resource.
*/}}
{{- define "gitlab.gatewayApi.envoy.config.name" -}}
{{- printf "%s-envoy-proxy" .Release.Name -}}
{{- end -}}

{{- define "gitlab.gatewayApi.gateway.name.default" -}}
{{- printf "%s-gw" .Release.Name -}}
{{- end -}}

{{/*
Returns a target ref to the Gateway resource without namespace and sectionName
for usage in Envoy policy custom resources.
*/}}
{{- define "gitlab.gatewayApi.gatewayRef.local" -}}
- group: gateway.networking.k8s.io
  kind: Gateway
  name: {{ coalesce (.Values.gatewayRoute).gatewayName .Values.global.gatewayApi.gatewayRef.name (include "gitlab.gatewayApi.gateway.name.default" .) | quote }}
{{- end -}}

{{/*
Returns true if envoy policies should be installed. Policies are installed if bundled envoy is installed
and if Gateway is in same namespace.
*/}}
{{- define "gitlab.gatewayApi.envoy.installPolicies" -}}
{{- $installEnvoy := and .Values.global.gatewayApi.enabled .Values.global.gatewayApi.installEnvoy -}}
{{- $gatewayNamespace := (include "gitlab.gatewayApi.gatewayRef" . | fromYamlArray | first).namespace -}}
{{- $gatewayInSameNamespace := eq .Release.Namespace $gatewayNamespace -}}
{{- if and $installEnvoy $gatewayInSameNamespace -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Returns a target refs to the Gateway resource with a namespace and optionally a section name.
*/}}
{{- define "gitlab.gatewayApi.gatewayRef" -}}
{{- template "gitlab.gatewayApi.gatewayRef.local" . }}
  namespace: {{ coalesce (.Values.gatewayRoute).gatewayNamespace .Values.global.gatewayApi.gatewayRef.namespace .Release.Namespace | quote }}
{{- with .Values.gatewayRoute }}
{{-   with .sectionName }}
  sectionName: {{ . | quote }}
{{-   end }}
{{- end }}
{{- end }}

{{/*
Renders a single listener configuration for the managed Gateway resource.

Input parameters:
local:
  name: Name of the listener
  protocol: Protocol type (HTTPS, HTTP, TCP, or nil)
  hostname: Domain name (e.g., example.com)
  tls:
    mode: TLS termination mode
    certificateRefs: List of certificate references
root:
  protocol: Default protocol (HTTPS or HTTP)

The root protocol serves as a default when no local protocol is specified,
enabling centralized protocol configuration for all HTTP(S) workloads and
listeners through a single setting.

Port assignment is automatically determined based on the selected protocol.
*/}}
{{- define "gitlab.gatewayApi.gateway.listener" -}}
{{- $name := .local.name }}
{{- $protocol := .local.protocol | default .root.protocol }}
{{- $port := 443 }}
{{- if eq "HTTP" $protocol }}
{{-   $port = 80 }}
{{- end }}
{{- if eq "TCP" $protocol }}
{{-   $port = 22 }}
{{- end }}
- name: {{ $name }}
  protocol: {{ $protocol | upper }}
  port: {{ $port }}
  allowedRoutes:
    namespaces:
      from: Same
{{- with .local.hostname }}
  hostname: {{ . | quote }}
{{- end }}
{{- with .local.tls }} 
  tls:
{{- toYaml . | nindent 4 }}
{{- end }}
{{- end -}}

{{/*
Checks if a Route should be enabled. Defaults to global GatewayAPI toggle but can be 
configured per Route by setting true/false explicitly.
*/}}
{{- define "gitlab.gatewayApi.route.enabled" -}}
{{- if not (eq nil .Values.gatewayRoute.enabled) -}}
{{-   .Values.gatewayRoute.enabled -}}
{{- else }}
{{-   .Values.global.gatewayApi.enabled -}}
{{- end -}}
{{- end -}}

{{/*
Renders the name of the HTTP01 Issuer for managing certificates used by GatewayAPI.
Different from the Issuer used for Ingresses.
*/}}
{{- define "gitlab.gatewayApi.certmanager.issuer" -}}
{{- printf "%s-gw-issuer" .Release.Name -}}
{{- end -}}

{{/*
Renders certmanager annotations for the Gateway resource.
https://cert-manager.io/docs/usage/gateway/
*/}}
{{- define "gitlab.gatewayApi.certmanager.annotations" -}}
{{- if .Values.global.gatewayApi.configureCertmanager -}}
cert-manager.io/issuer: {{ include "gitlab.gatewayApi.certmanager.issuer" . }}
{{- end -}}
{{- end -}}

{{/*
Renders true if Gateway resources should be configured for Geo traffic.
*/}}
{{- define "gitlab.gatewayApi.gateway.geo.configure" -}}
{{ if and .Values.global.geo.enabled .Values.global.geo.gatewayApi.additionalHostname .Values.global.gatewayApi.enabled -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}
