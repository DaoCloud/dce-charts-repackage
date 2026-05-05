{{/* vim: set filetype=mustache: */}}

{{- define "toolbox.backups.cron.persistence.persistentVolumeClaim" -}}
metadata:
{{- if not .Values.backups.cron.persistence.useGenericEphemeralVolume }}
  name: {{ template "fullname" . }}-backup-tmp
  namespace: {{ $.Release.Namespace }}
{{- end }}
  labels:
    {{- include "gitlab.standardLabels" . | nindent 4 }}
    {{- include "gitlab.commonLabels" . | nindent 4 }}
spec:
  accessModes:
    - {{ .Values.backups.cron.persistence.accessMode | quote }}
  resources:
    requests:
      storage: {{ .Values.backups.cron.persistence.size | quote }}
{{- if .Values.backups.cron.persistence.volumeName }}
  volumeName: {{ .Values.backups.cron.persistence.volumeName }}
{{- end }}
{{- if .Values.backups.cron.persistence.storageClass }}
{{- if (eq "-" .Values.backups.cron.persistence.storageClass) }}
  storageClassName: ""
{{- else }}
  storageClassName: "{{ .Values.backups.cron.persistence.storageClass }}"
{{- end -}}
{{- end }}
  selector:
{{- if .Values.backups.cron.persistence.matchLabels }}
    matchLabels:
      {{- toYaml .Values.backups.cron.persistence.matchLabels | nindent 6 }}
{{- end -}}
{{- if .Values.backups.cron.persistence.matchExpressions }}
    matchExpressions:
      {{- toYaml .Values.backups.cron.persistence.matchExpressions | nindent 6 }}
{{- end -}}
{{- end -}}

{{/*
Returns the secret configuring access to the object storage for backups.

Usage:
  {{ include "toolbox.backups.objectStorage.config.secret" .Values.backups.objectStorage }}

*/}}
{{- define "toolbox.backups.objectStorage.config.secret" -}}
{{-   if eq .backend "gcs" -}}
{{- if .config -}}
- secret:
    name: {{ .config.secret }}
    items:
      - key: {{ default "config" .config.key }}
        path: objectstorage/{{ default "config" .config.key }}
{{- end -}}
{{-   else if eq .backend "azure" -}}
- secret:
    name: {{ .config.secret }}
    items:
      - key: {{ default "config" .config.key }}
        path: objectstorage/azure_config
{{-   else -}}
- secret:
    name: {{ .config.secret }}
    items:
      - key: {{ default "config" .config.key }}
        path: objectstorage/.s3cfg
{{-   end -}}
{{- end -}}

{{/*
Return the secret name for toolbox registry database password
*/}}
{{- define "toolbox.registry.database.password.secret" -}}
{{- $database := default (dict) .Values.backups.registry.database -}}
{{- dig "password" "secret" "" $database | default (printf "%s-toolbox-registry-database-password" .Release.Name) -}}
{{- end -}}

{{/*
Return the secret key for toolbox registry database backup password
*/}}
{{- define "toolbox.registry.database.password.backupKey" -}}
{{- $database := default (dict) .Values.backups.registry.database -}}
{{- dig "password" "backupPasswordKey" "backupPassword" $database | default "backupPassword" -}}
{{- end -}}

{{/*
Return the secret key for toolbox registry database restore password
*/}}
{{- define "toolbox.registry.database.password.restoreKey" -}}
{{- $database := default (dict) .Values.backups.registry.database -}}
{{- dig "password" "restorePasswordKey" "restorePassword" $database | default "restorePassword" -}}
{{- end -}}

{{/*
Registry database configuration volume for toolbox pods.

This projected volume mounts registry metadata database credentials and connection
configuration to toolbox pods for backup/restore operations.

The volume includes three optional sources:
1. Connection parameters (host, port, database, SSL config) from registry chart ConfigMap
2. Database username from toolbox ConfigMap
3. Database password from Secret

All sources use optional: true to maintain backward compatibility when registry
database is not configured.

Usage:
  {{- include "toolbox.registry.database.volume" . | nindent ... }}

Files:
  - connection.env: Database connection parameters
  - user.env: Database username
  - pass: Database password
*/}}
{{- define "toolbox.registry.databaseBackupCredentialsVolume" -}}
- name: registry-db-config
  projected:
    defaultMode: 0440
    sources:
      - configMap:
          name: {{ include "gitlab.other.fullname" ( dict "context" . "chartName" "registry" ) }}-db-connection-config
          items:
          - key: db-connection.env
            path: connection.env
          optional: true
      - configMap:
          name: {{ template "fullname" . }}-registry-db-backuprestore-users
          items:
          - key: backup-user
            path: backup-user.env
          - key: restore-user
            path: restore-user.env
          optional: true
      - secret:
          name: {{ include "toolbox.registry.database.password.secret" . }}
          items:
          - key: {{ template "toolbox.registry.database.password.backupKey" . }}
            path: backup-pass
          - key: {{ template "toolbox.registry.database.password.restoreKey" . }}
            path: restore-pass
          optional: true
{{- end -}}

{{/*
Registry database configuration volume mount for toolbox containers.

Mounts the registry database configuration volume to the container.

Usage:
  {{- include "toolbox.registry.database.volumeMount" . | nindent 12 }}
*/}}
{{- define "toolbox.registry.database.databaseBackupCredentialsMount" -}}
- name: registry-db-config
  mountPath: /etc/gitlab/registry-db/
  readOnly: true
{{- end -}}
