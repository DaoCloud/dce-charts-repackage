{{/*
Expand the name of the chart.
*/}}
{{- define "iaas-network-provider.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "iaas-network-provider.fullname" -}}
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
Common labels
*/}}
{{- define "iaas-network-provider.labels" -}}
helm.sh/chart: {{ include "iaas-network-provider.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "iaas-network-provider.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "iaas-network-provider.selectorLabels" -}}
app.kubernetes.io/name: {{ include "iaas-network-provider.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Default image tag: v + appVersion when controller.image.tag is unset.
*/}}
{{- define "iaas-network-provider.imageTag" -}}
{{- if .Values.controller.image.tag -}}
{{- .Values.controller.image.tag -}}
{{- else -}}
{{- printf "v%s" .Chart.AppVersion -}}
{{- end -}}
{{- end }}

{{/*
Full container image reference.
*/}}
{{- define "iaas-network-provider.image" -}}
{{- printf "%s/%s:%s" .Values.controller.image.registry .Values.controller.image.repository (include "iaas-network-provider.imageTag" .) -}}
{{- end }}

{{/*
ServiceAccount name
*/}}
{{- define "iaas-network-provider.serviceAccountName" -}}
{{- if .Values.controller.serviceAccount.create }}
{{- default (include "iaas-network-provider.fullname" .) .Values.controller.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.controller.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Parse the numeric TCP port from controller.bindAddress for containerPort.
Supports ":8443", "0.0.0.0:8443", and "127.0.0.1:8443".
*/}}
{{- define "iaas-network-provider.httpsPort" -}}
{{- $addr := .Values.controller.bindAddress | trim -}}
{{- if hasPrefix ":" $addr -}}
{{- trimPrefix ":" $addr -}}
{{- else if contains ":" $addr -}}
{{- (splitList ":" $addr | last) -}}
{{- else -}}
{{- $addr -}}
{{- end -}}
{{- end }}

{{/*
Parse the numeric TCP port from controller.pprof.bindAddress for containerPort.
Supports ":6060", "0.0.0.0:7070", and "127.0.0.1:6060".
*/}}
{{- define "iaas-network-provider.pprofPort" -}}
{{- $addr := .Values.controller.pprof.bindAddress | trim -}}
{{- if hasPrefix ":" $addr -}}
{{- trimPrefix ":" $addr -}}
{{- else if contains ":" $addr -}}
{{- (splitList ":" $addr | last) -}}
{{- else -}}
{{- $addr -}}
{{- end -}}
{{- end }}

{{/*
Validate required chart values and fail fast on empty inputs.
*/}}
{{- define "iaas-network-provider.validateValues" -}}
{{- $cloud := .Values.cloud -}}
{{- $access := $cloud.accessConfig -}}
{{- $auth := $cloud.auth -}}
{{- $mgr := .Values.controller.ippoolManager -}}
{{- $_ := required "values.controller.image.registry is required and cannot be empty" .Values.controller.image.registry -}}
{{- $_ := required "values.controller.image.repository is required and cannot be empty" .Values.controller.image.repository -}}
{{- $_ := required "values.cloud.provider is required and cannot be empty" $cloud.provider -}}
{{- if ne $cloud.provider "huaweicloud" -}}
{{- fail (printf "values.cloud.provider must be \"huaweicloud\", got %q" $cloud.provider) -}}
{{- end -}}
{{- $_ := required "values.cloud.accessConfig.region is required and cannot be empty" $access.region -}}
{{- $_ := required "values.cloud.accessConfig.projectID is required and cannot be empty" $access.projectID -}}
{{- $_ := required "values.cloud.accessConfig.endpoint is required and cannot be empty" $access.endpoint -}}
{{- $_ := required "values.cloud.auth.mode is required and cannot be empty" $auth.mode -}}
{{- $_ := required "values.cloud.auth.secret is required and cannot be empty" $auth.secret -}}

{{- if and (hasPrefix "http://" $access.endpoint) (not $cloud.allowInsecureHTTP) -}}
{{- fail (printf "values.cloud.accessConfig.endpoint %q is plaintext HTTP; set cloud.allowInsecureHTTP=true (test only) or use https://" $access.endpoint) -}}
{{- end -}}

{{- if eq $auth.mode "token" -}}
{{- $_ := required "values.cloud.auth.token.username is required when auth.mode=token" $auth.token.username -}}
{{- $_ := required "values.cloud.auth.token.iamDomain is required when auth.mode=token" $auth.token.iamDomain -}}
{{- $_ := required "values.cloud.accessConfig.iamEndpoint is required when auth.mode=token" $access.iamEndpoint -}}
{{- $_ := required "values.cloud.accessConfig.projectName is required when auth.mode=token" $access.projectName -}}
{{- if and (not $auth.token.agencyName) (not $auth.token.trustTenantName) -}}
{{- fail "one of values.cloud.auth.token.agencyName or trustTenantName is required when auth.mode=token" -}}
{{- end -}}
{{- if and $auth.token.trustTenantName (not $access.scEndpoint) -}}
{{- fail "values.cloud.accessConfig.scEndpoint is required when auth.token.trustTenantName is set" -}}
{{- end -}}
{{- else if ne $auth.mode "ak-sk" -}}
{{- fail (printf "values.cloud.auth.mode must be either \"ak-sk\" or \"token\", got %q" $auth.mode) -}}
{{- end -}}

{{- if and (not .Values.tls.autoGenerate) (not .Values.tls.existingSecret) -}}
{{- fail "values.tls.existingSecret is required when tls.autoGenerate=false" -}}
{{- end -}}

{{- if le (int $cloud.maxSubEniPerNode) 0 -}}
{{- fail "values.cloud.maxSubEniPerNode must be positive" -}}
{{- end -}}
{{- if lt (int $cloud.maxSubEniPerMachine) 0 -}}
{{- fail "values.cloud.maxSubEniPerMachine must be >= 0 (0 disables the machine-level guard)" -}}
{{- end -}}
{{- if le (int $mgr.ipWorkersPerPool) 0 -}}
{{- fail "values.controller.ippoolManager.ipWorkersPerPool must be positive" -}}
{{- end -}}
{{- if lt (int $mgr.ipIdleTTLSeconds) 0 -}}
{{- fail "values.controller.ippoolManager.ipIdleTTLSeconds must be >= 0" -}}
{{- end -}}
{{- if not (has $mgr.ipRecycleStrategy (list "ttl" "watermark")) -}}
{{- fail (printf "values.controller.ippoolManager.ipRecycleStrategy must be \"ttl\" or \"watermark\", got %q" $mgr.ipRecycleStrategy) -}}
{{- end -}}
{{- $le := .Values.controller.leaderElection -}}
{{- if ge (int $le.renewDeadlineSeconds) (int $le.leaseDurationSeconds) -}}
{{- fail "values.controller.leaderElection.renewDeadlineSeconds must be less than leaseDurationSeconds" -}}
{{- end -}}
{{- if ge (int $le.retryPeriodSeconds) (int $le.renewDeadlineSeconds) -}}
{{- fail "values.controller.leaderElection.retryPeriodSeconds must be less than renewDeadlineSeconds" -}}
{{- end -}}

{{- if .Values.controller.pprof.enabled -}}
{{- $port := include "iaas-network-provider.pprofPort" . -}}
{{- if or (not $port) (not (regexMatch "^[0-9]+$" $port)) (lt (int $port) 1) (gt (int $port) 65535) -}}
{{- fail (printf "controller.pprof.bindAddress %q must contain a valid TCP port (1-65535) when pprof.enabled=true" .Values.controller.pprof.bindAddress) -}}
{{- end -}}
{{- end -}}
{{- end }}
