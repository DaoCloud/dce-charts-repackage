{{/*
Check if any Gateway API extension uses the deprecated global configuration.
*/}}
{{- define "gitlab.checkConfig.gatewayApi.envoy.global" -}}
{{- $keys := list "envoyProxySpec" "envoyClientTrafficPolicySpec" "envoySecurityPolicySpec" "class" "protocol" "addresses" "listeners" "gateway" "metrics" }}
{{- range $keys }}
{{-   if hasKey $.Values.global.gatewayApi . }}
Gateway API:
  The global.gatewayApi.{{ . }} settings moved away from global configuration. Please check
  https://docs.gitlab.com/charts/charts/envoygateway/ and https://docs.gitlab.com/charts/charts/globals/#gateway-api
  to migrate.
{{-   end }}
{{- end }}
{{- end -}}