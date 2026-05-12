{{/*
Renders all listeners to be bound by the Webservice HTTPRoute.
*/}}
{{- define "webservice.gatewayApi.gatewayRefs" }}
{{-   include "gitlab.gatewayApi.gatewayRef" . }}
{{-   if .Values.global.geo.gatewayApi.additionalHostname }}
{{     include "webservice.gatewayApi.gatewayRef.geo" . }}
{{    end }}
{{-   if .Values.global.appConfig.smartcard.enabled }}
{{     include "webservice.gatewayApi.gatewayRef.smartcard" . }}
{{    end }}
{{- end }}

{{/*
Renders optional Geo Gateway+Listener reference.
*/}}
{{- define "webservice.gatewayApi.gatewayRef.geo" }}
{{-   $ref := (include "gitlab.gatewayApi.gatewayRef" . ) | fromYamlArray }}
{{-   $_ := set ($ref | first) "sectionName" .Values.gatewayRoute.geoSectionName }}
{{-   slice $ref | toYaml }}
{{- end }}

{{/*
Renders optional Smartcard Gateway+Listener reference.
*/}}
{{- define "webservice.gatewayApi.gatewayRef.smartcard" }}
{{-   $ref := (include "gitlab.gatewayApi.gatewayRef" . ) | fromYamlArray }}
{{-   $_ := set ($ref | first) "sectionName" .Values.gatewayRoute.smartcardSectionName }}
{{-   slice $ref | toYaml }}
{{- end }}

{{/*
Renders all hostnames webservice accepts traffic for.
*/}}
{{- define "webservice.gatewayApi.hostnames" }}
- {{ include "gitlab.gitlab.hostname" . | quote }}
{{-   with .Values.global.geo.gatewayApi.additionalHostname }}
- {{ . | quote }}
{{-   end }}
{{-   if $.Values.global.appConfig.smartcard.enabled }}
- {{ include "gitlab.smartcard.hostname" . | quote }}
{{-   end }}
{{- end }}