{{/*
Returns the hostname.
If the hostname is set in `global.hosts.openbao.name`, that will be returned,
otherwise the hostname will be assembled using `openbao` as the prefix, and the `gitlab.assembleHost` function.
*/}}
{{- define "gitlab.openbao.hostname" -}}
{{- coalesce .Values.global.openbao.host .Values.global.hosts.openbao.name (include "gitlab.assembleHost"  (dict "name" "openbao" "context" . )) -}}
{{- end -}}

{{/*
Returns the OpenBao Url, ex: `http://openbao.example.com`

Populated from one of:
- Direct setting of URL
- Populated by  "gitlab.openbao.hostname", plus `https` boolean
*/}}
{{- define "gitlab.openbao.url" -}}
{{- if $.Values.global.openbao.url -}}
{{-   $.Values.global.openbao.url -}}
{{- else if or .Values.global.openbao.https .Values.global.hosts.https .Values.global.hosts.openbao.https -}}
{{-   printf "https://%s" (include "gitlab.openbao.hostname" .) -}}
{{- else -}}
{{-   printf "http://%s" (include "gitlab.openbao.hostname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Returns the OpenBao internal hostname.
If the hostname is set in `global.openbao.internal_host`, that will be returned,
otherwise falls back to the regular hostname.
*/}}
{{- define "gitlab.openbao.internal_hostname" -}}
{{- coalesce .Values.global.openbao.internal_host (include "gitlab.openbao.hostname" .) -}}
{{- end -}}

{{/*
Returns the OpenBao internal URL, ex: `https://openbao.internal.net`

Populated from one of:
- Direct setting of internal_url
- Populated by "gitlab.openbao.internal_hostname", plus `https` boolean
- Empty if neither internal_url nor internal_host are set
*/}}
{{- define "gitlab.openbao.internal_url" -}}
{{- if $.Values.global.openbao.internal_url -}}
{{-   $.Values.global.openbao.internal_url -}}
{{- else if $.Values.global.openbao.internal_host -}}
{{-   if has true (list .Values.global.openbao.https .Values.global.hosts.https .Values.global.hosts.openbao.https) -}}
{{-    printf "https://%s" .Values.global.openbao.internal_host -}}
{{-   else -}}
{{-    printf "http://%s" .Values.global.openbao.internal_host -}}
{{-   end -}}
{{- end -}}
{{- end -}}

{{/*
Render the OpenBao postgresql configuration yaml.

* Takes the rails main DB as base, and merges OpenBao custom storage
  configuration in.
* This needs special handling for <no value> objects because these are not
  considered empty: https://github.com/helm/helm/issues/13487.

*/}}
{{- define "openbao.postgresql.configuration" -}}
{{- $main := (fromYaml (include "gitlab.database.yml" .)).production.main -}}
{{- $_ := (include "gitlab.keysToCamelCase" $main) -}}
{{- range $k, $v := $main -}}
{{-   if and (kindIs "string" $v) (eq $v "<no value>") }}
{{      $_ := unset $main $k }}
{{-   end }}
{{- end -}}
{{- $psqlSecret := dict "secret" (include "gitlab.psql.password.secret" .Values.local.psql.main) -}}
{{- $_ := set $psqlSecret "key" (include "gitlab.psql.password.key" .Values.local.psql.main) -}}
{{- $_ := set $main "password" $psqlSecret -}}
{{ merge .Values.config.storage.postgresql.connection $main | toYaml }}
{{- end -}}

{{- define "gitlab.openbao.configureCertmanager" -}}
{{ pluck "configureCertmanager" .Values.ingress .Values.global.ingress (dict "configureCertmanager" false) | first }}
{{- end }}

{{- define "gitlab.openbao.unseal.secret" -}}
{{- printf "%s-openbao-unseal" .Release.Name -}}
{{- end -}}

{{- define "gitlab.openbao.unseal.key" -}}
key
{{- end -}}

{{- define "gitlab.openbao.authenticationTokenSecretFilePath.secret" -}}
{{- .Values.global.openbao.httpAudit.secret | default (printf "%s-openbao-audit-secret" .Release.Name) -}}
{{- end -}}

{{- define "gitlab.openbao.authenticationTokenSecretFilePath.key" -}}
{{- .Values.global.openbao.httpAudit.key }}
{{- end -}}
