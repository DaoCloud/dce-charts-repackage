{{/*
Gateway API related templates to integrate with GitLab helm chart.
The GitLab helm chart overrides these with it's own implementation.
*/}}

{{- define "gitlab.gatewayApi.route.enabled" -}}
{{- .Values.gatewayRoute.enabled | default false -}}
{{- end -}}

{{- define "gitlab.gatewayApi.route.gateway" -}}
{{- .Values.gatewayRoute.gatewayName | default "gateway" -}}
{{- end -}}