{{/* ######### gitlab-kas related templates */}}

{{/*
Return the gitlab-kas secret
*/}}

{{- define "gitlab.kas.secret" -}}
{{- default (printf "%s-gitlab-kas-secret" .Release.Name) .Values.global.appConfig.gitlab_kas.secret | quote -}}
{{- end -}}

{{- define "gitlab.kas.key" -}}
{{- default "kas_shared_secret" .Values.global.appConfig.gitlab_kas.key | quote -}}
{{- end -}}

{{/*
Return the gitlab-kas private API secret
*/}}

{{- define "gitlab.kas.privateApi.secret" -}}
{{- $secret := "" -}}
{{- if eq .Chart.Name "kas" -}}
{{-    $secret = .Values.privateApi.secret -}}
{{- else -}}
{{-    $secret = .Values.gitlab.kas.privateApi.secret -}}
{{- end -}}
{{- default (printf "%s-kas-private-api" .Release.Name) $secret | quote -}}
{{- end -}}

{{- define "gitlab.kas.privateApi.key" -}}
{{- $key := "" -}}
{{- if eq .Chart.Name "kas" -}}
{{-    $key = .Values.privateApi.key -}}
{{- else -}}
{{-    $key = .Values.gitlab.kas.privateApi.key -}}
{{- end -}}
{{- default "kas_private_api_secret" $key | quote -}}
{{- end -}}

{{/*
Return the gitlab-kas WebSocket Token secret
*/}}

{{- define "gitlab.kas.websocketToken.secret" -}}
{{- $secret := "" -}}
{{- if eq .Chart.Name "kas" -}}
{{-    $secret = .Values.websocketToken.secret -}}
{{- else -}}
{{-    $secret = .Values.gitlab.kas.websocketToken.secret -}}
{{- end -}}
{{- default (printf "%s-kas-websocket-token" .Release.Name) $secret | quote -}}
{{- end -}}

{{- define "gitlab.kas.websocketToken.key" -}}
{{- $key := "" -}}
{{- if eq .Chart.Name "kas" -}}
{{-    $key = .Values.websocketToken.key -}}
{{- else -}}
{{-    $key = .Values.gitlab.kas.websocketToken.key -}}
{{- end -}}
{{- default "kas_websocket_token_secret" $key | quote -}}
{{- end -}}

{{/*
Return the gitlab-kas AutoFlow Temporal Workflow data encryption secret
*/}}

{{- define "gitlab.kas.autoflow.temporal.workflowDataEncryption.secret" -}}
{{- $secret := "" -}}
{{- if eq .Chart.Name "kas" -}}
{{-    $secret = ((.Values.autoflow.temporal).workflowDataEncryption).secret -}}
{{- else -}}
{{-    $secret = ((.Values.gitlab.kas.autoflow.temporal).workflowDataEncryption).secret -}}
{{- end -}}
{{- default (printf "%s-kas-autoflow-temporal-workflow-data-encryption-secret" .Release.Name) $secret | quote -}}
{{- end -}}

{{- define "gitlab.kas.autoflow.temporal.workflowDataEncryption.key" -}}
{{- $key := "" -}}
{{- if eq .Chart.Name "kas" -}}
{{-    $key = ((.Values.autoflow.temporal).workflowDataEncryption).key -}}
{{- else -}}
{{-    $key = ((.Values.gitlab.kas.autoflow.temporal).workflowDataEncryption).key -}}
{{- end -}}
{{- default "kas_autoflow_temporal_workflow_data_encryption" $key | quote -}}
{{- end -}}

{{/*
Returns the KAS external hostname (for agentk connections)
If the hostname is set in `global.hosts.kas.name`, that will be returned,
otherwise the hostname will be assembed using `kas` as the prefix, and the `gitlab.assembleHost` function.
*/}}
{{- define "gitlab.kas.hostname" -}}
{{- coalesce $.Values.global.hosts.kas.name (include "gitlab.assembleHost"  (dict "name" "kas" "context" . )) -}}
{{- end -}}
