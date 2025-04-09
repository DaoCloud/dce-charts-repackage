{{/*
Ensures that Temporal namespace is configured when AutoFlow is enabled

*/}}
{{- define "gitlab.checkConfig.kas.autoflowTemporalNamespace" -}}
{{- $kas := .Values.gitlab.kas }}
{{- if ($kas.autoflow).enabled -}}
{{- if not ($kas.autoflow.temporal).namespace -}}
kas:
    Temporal namespace is required when AutoFlow is enabled. Set `autoflow.temporal.namespace` to your unique namespace value
{{- end -}}
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.kas.autoflowTemporalNamespace */}}

{{/*
Ensures that Temporal Worker mTLS certificates are configured when AutoFlow is enabled

*/}}
{{- define "gitlab.checkConfig.kas.autoflowTemporalWorkerMtls" -}}
{{- $kas := .Values.gitlab.kas }}
{{- if ($kas.autoflow).enabled -}}
{{- if not (($kas.autoflow.temporal).workerMtls).secretName -}}
kas:
    Temporal worker mTLS secret Name is required when AutoFlow is enabled. Use `autoflow.temporal.workerMtls.secretName` to specify the name of the Kubernetes secret containing the worker mTLS key and cert
{{- end -}}
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.kas.autoflowTemporalWorkerMtls */}}
