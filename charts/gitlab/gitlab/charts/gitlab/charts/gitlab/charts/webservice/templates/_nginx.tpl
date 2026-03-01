{{/*
Detect if `tls.verify` is set
Returns `.tls.verify` if it is a boolean,
Return false in any other case.
*/}}
{{- define "webservice.ingress.nginx.tls.verify" -}}
{{- $deploymentSet := and (hasKey . "tls") (and (hasKey .tls "verify") (kindIs "bool" .tls.verify)) }}
{{- if $deploymentSet }}
{{-   .tls.verify }}
{{- else }}
{{-   false }}
{{- end -}}
{{- end -}}

{{/*
Generate the nginx annotations for the webservice ingress to be used in the merge of annotations in the ingress template.
Returns a YAML string with the annotations.
*/}}
{{- define "webservice.ingress.nginx.annotations" -}}
{{- $ingressCfg := .ingressCfg -}}
{{- $global := .root.Values.global }}
{{- $ingress := merge (index .root "ingress" | default dict) (default dict $ingressCfg) -}}
{{- if eq "nginx" (default $global.ingress.provider $ingressCfg.local.provider) }}
{{-   if eq (default "nginx" $ingress.provider) "nginx" -}}
{{   $annotations := dict -}}
{{-     if $global.workhorse.tls.enabled }}
{{-       $_ := set $annotations "nginx.ingress.kubernetes.io/backend-protocol" "https" }}
{{-       if eq (include "webservice.ingress.nginx.tls.verify" .deployment.workhorse) "true" -}}
{{-         $_ := set $annotations "nginx.ingress.kubernetes.io/proxy-ssl-verify" "on" }}
{{-         $_ := set $annotations "nginx.ingress.kubernetes.io/proxy-ssl-name" (printf "%s.%s.svc" (include "webservice.fullname.withSuffix" .deployment) .root.Release.Namespace) }}
{{-         if .deployment.workhorse.tls.caSecretName }}
{{-           $_ := set $annotations "nginx.ingress.kubernetes.io/proxy-ssl-secret" (printf "%s/%s" .root.Release.Namespace .deployment.workhorse.tls.caSecretName) }}
{{-         end }}
{{-       end }}
{{-     end }}
{{-     $_ := set $annotations "nginx.ingress.kubernetes.io/proxy-body-size" $ingress.local.proxyBodySize -}}
{{-     $_ := set $annotations "nginx.ingress.kubernetes.io/proxy-read-timeout" $ingress.local.proxyReadTimeout -}}
{{-     $_ := set $annotations "nginx.ingress.kubernetes.io/proxy-connect-timeout" $ingress.local.proxyConnectTimeout -}}
{{-     $_ := set $annotations "nginx.ingress.kubernetes.io/service-upstream" $ingress.local.serviceUpstream  -}}
{{-     $annotations | toYaml -}}
{{-   end }}
{{- end }}
{{- end }}
