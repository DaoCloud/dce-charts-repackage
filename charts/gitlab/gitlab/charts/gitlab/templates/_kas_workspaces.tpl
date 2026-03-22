{{/*
Returns the KAS workspaces external hostname
*/}}
{{- define "gitlab.workspaces.hostname" -}}
{{- $hostname := $.Values.global.hosts.workspaces.name | required "Missing required workspaces host. Make sure to set `.Values.global.hosts.workspaces.name`" -}}
{{- $hostname -}}
{{- end -}}

{{/*
Returns the KAS workspaces wildcard hostname
*/}}
{{- define "gitlab.workspaces.wildcardHostname" -}}
{{- $hostname := include "gitlab.workspaces.hostname" . -}}
{{- print "*." $hostname -}}
{{- end -}}
