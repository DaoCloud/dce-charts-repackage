{{/* ######### gitlab-pages related templates */}}

{{/*
Return the gitlab-pages secret
*/}}

{{- define "gitlab.pages.apiSecret.secret" -}}
{{- default (printf "%s-gitlab-pages-secret" .Release.Name) $.Values.global.pages.apiSecret.secret | quote -}}
{{- end -}}

{{- define "gitlab.pages.apiSecret.key" -}}
{{- default "shared_secret" $.Values.global.pages.apiSecret.key | quote -}}
{{- end -}}

{{- define "gitlab.pages.authSecret.secret" -}}
{{ default (printf "%s-gitlab-pages-auth-secret" .Release.Name) $.Values.global.pages.authSecret.secret }}
{{- end -}}

{{- define "gitlab.pages.authSecret.key" -}}
{{ default "password" $.Values.global.pages.authSecret.key }}
{{- end -}}

{{/*
Returns the Pages hostname.
If the hostname is set in `global.hosts.pages.name`, that will be returned,
otherwise the hostname will be assembed using `pages` as the prefix, and the `gitlab.assembleHost` function.
*/}}
{{- define "gitlab.pages.hostname" -}}
{{- coalesce $.Values.global.pages.host $.Values.global.hosts.pages.name (include "gitlab.assembleHost"  (dict "name" "pages" "context" . )) -}}
{{- end -}}
