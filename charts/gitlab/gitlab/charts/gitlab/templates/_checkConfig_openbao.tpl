{{/*
Ensure a database is configured when OpenBao is installed.

The database must be configured explicitly via global.openbao.psql or
openbao.config.storage.postgresql.connection with host, database, username, and password.
Password is required and is not inherited from the main DB.
*/}}
{{- define "gitlab.checkConfig.openbao.database" -}}
{{- if .Values.openbao.install -}}
{{-   $baoPsql := (include "openbao.postgresql.configuration" . | fromYaml) -}}
{{-   if not $baoPsql.host }}
openbao: no database configured
    It appears OpenBao is enabled but no database was configured. Configure `global.openbao.psql` with host, database, username, and password. See https://docs.gitlab.com/charts/charts/openbao/#database-configuration
{{-   end }}
{{-   $password := $baoPsql.password | default dict -}}
{{-   if not (hasKey $password "secret") }}
openbao: no database password configured
    OpenBao requires an explicit database password. Configure `global.openbao.psql.password` with secret/key. Password is not inherited from the main DB. See https://docs.gitlab.com/charts/charts/openbao/#database-configuration
{{-   end -}}
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.openbao.database */}}
