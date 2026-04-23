{{/*
Expand the name of the chart.
*/}}
{{- define "vllm-omni.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "vllm-omni.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart label.
*/}}
{{- define "vllm-omni.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "vllm-omni.labels" -}}
helm.sh/chart: {{ include "vllm-omni.chart" . }}
{{ include "vllm-omni.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "vllm-omni.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vllm-omni.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use.
*/}}
{{- define "vllm-omni.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "vllm-omni.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Build the full image reference.
*/}}
{{- define "vllm-omni.image" -}}
{{- $registry := .Values.image.registry -}}
{{- $repository := .Values.image.repository -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- else -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}
{{- end }}

{{/*
Build the vLLM-Omni server command arguments.
*/}}
{{- define "vllm-omni.serverArgs" -}}
- "--model"
- {{ .Values.model.name | quote }}
{{- if .Values.model.tensorParallelSize }}
- "--tensor-parallel-size"
- {{ .Values.model.tensorParallelSize | quote }}
{{- end }}
{{- if .Values.model.pipelineParallelSize }}
- "--pipeline-parallel-size"
- {{ .Values.model.pipelineParallelSize | quote }}
{{- end }}
{{- if .Values.model.dtype }}
- "--dtype"
- {{ .Values.model.dtype | quote }}
{{- end }}
{{- if .Values.model.gpuMemoryUtilization }}
- "--gpu-memory-utilization"
- {{ .Values.model.gpuMemoryUtilization | quote }}
{{- end }}
{{- if .Values.model.maxModelLen }}
- "--max-model-len"
- {{ .Values.model.maxModelLen | quote }}
{{- end }}
{{- if .Values.model.quantization }}
- "--quantization"
- {{ .Values.model.quantization | quote }}
{{- end }}
{{- if .Values.model.maxNumSeqs }}
- "--max-num-seqs"
- {{ .Values.model.maxNumSeqs | quote }}
{{- end }}
{{- if .Values.model.trustRemoteCode }}
- "--trust-remote-code"
{{- end }}
{{- if and .Values.worldModel.enabled .Values.worldModel.maxSessions }}
- "--world-model-max-sessions"
- {{ .Values.worldModel.maxSessions | quote }}
{{- end }}
{{- if and .Values.worldModel.enabled .Values.worldModel.sessionTimeoutSeconds }}
- "--world-model-session-timeout"
- {{ .Values.worldModel.sessionTimeoutSeconds | quote }}
{{- end }}
{{- if and .Values.worldModel.enabled .Values.worldModel.kvBuffer.maxWindowSize }}
- "--world-model-kv-window-size"
- {{ .Values.worldModel.kvBuffer.maxWindowSize | quote }}
{{- end }}
{{- range .Values.extraArgs }}
- {{ . | quote }}
{{- end }}
{{- end }}
