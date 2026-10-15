{{/* vim: set filetype=mustache: */}}
{{- define "unifabric.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "unifabric.fullname" -}}
{{- $name := include "unifabric.name" . -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "unifabric.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" -}}
{{- end -}}

{{- define "unifabric.labels" -}}
helm.sh/chart: {{ include "unifabric.chart" . }}
app.kubernetes.io/name: {{ include "unifabric.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "unifabric.selectorLabels" -}}
app.kubernetes.io/name: {{ include "unifabric.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "unifabric.controllerName" -}}
{{- printf "%s-controller" (include "unifabric.fullname" .) -}}
{{- end -}}

{{- define "unifabric.agentName" -}}
{{- printf "%s-agent" (include "unifabric.fullname" .) -}}
{{- end -}}

{{- define "unifabric.grafanaName" -}}
{{- printf "%s-grafana" (include "unifabric.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "unifabric.topologyDatasourceName" -}}
{{- printf "%s-topology" (include "unifabric.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "unifabric.grafanaInstanceSelector" -}}
{{- if .Values.grafanaInstance.enabled -}}
matchLabels:
  app.kubernetes.io/instance: {{ .Release.Name }}
  app.kubernetes.io/component: unifabric-grafana
{{- else if .Values.grafanaDashboard.instanceSelector -}}
{{- toYaml .Values.grafanaDashboard.instanceSelector -}}
{{- else -}}
{}
{{- end -}}
{{- end -}}

{{- define "unifabric.controllerServiceAccountName" -}}
{{- default (include "unifabric.controllerName" .) .Values.controller.serviceAccount.name -}}
{{- end -}}

{{- define "unifabric.agentServiceAccountName" -}}
{{- default (include "unifabric.agentName" .) .Values.agent.serviceAccount.name -}}
{{- end -}}

{{- define "unifabric.topoDiscovery.scaleUpMode" -}}
{{- .Values.topoDiscovery.scaleUp.mode | lower -}}
{{- end -}}

{{- define "unifabric.topoDiscovery.scaleOutMode" -}}
{{- .Values.topoDiscovery.scaleOut.mode | lower -}}
{{- end -}}

{{- define "unifabric.topoDiscovery.storageMode" -}}
{{- .Values.topoDiscovery.storage.mode | lower -}}
{{- end -}}

{{- define "unifabric.switchSubscription.enabled" -}}
{{- $scaleOutMode := include "unifabric.topoDiscovery.scaleOutMode" . -}}
{{- $storageMode := include "unifabric.topoDiscovery.storageMode" . -}}
{{- if or (eq $scaleOutMode "unifabric-roce") (has $storageMode (list "unifabric-roce" "unifabric-ib")) -}}
true
{{- end -}}
{{- end -}}

{{- define "unifabric.nvidiaTopograph.enabled" -}}
{{- $scaleUpMode := include "unifabric.topoDiscovery.scaleUpMode" . -}}
{{- $scaleOutMode := include "unifabric.topoDiscovery.scaleOutMode" . -}}
{{- if or (eq $scaleUpMode "nv-topograph") (eq $scaleOutMode "nv-topograph") -}}
true
{{- end -}}
{{- end -}}

{{- define "unifabric.switchMTLS.enabled" -}}
{{- if and (eq (include "unifabric.switchSubscription.enabled" .) "true") (ne (lower .Values.switchSubscription.mtls.mode) "disabled") -}}
true
{{- end -}}
{{- end -}}

{{- define "unifabric.switchMTLS.autoGenerate" -}}
{{- if and (eq (include "unifabric.switchMTLS.enabled" .) "true") (eq (lower .Values.switchSubscription.mtls.mode) "auto") -}}
true
{{- end -}}
{{- end -}}

{{- define "unifabric.switchMTLS.controllerSecretName" -}}
{{- default (printf "%s-switch-controller-mtls-controller" (include "unifabric.fullname" .)) .Values.switchSubscription.mtls.controllerSecretName -}}
{{- end -}}

{{- define "unifabric.switchMTLS.switchAgentSecretName" -}}
{{- default (printf "%s-switch-controller-mtls-agent" (include "unifabric.fullname" .)) .Values.switchSubscription.mtls.switchAgentSecretName -}}
{{- end -}}

{{- define "unifabric.render" -}}
{{- if typeIs "string" .value -}}
{{- tpl .value .context -}}
{{- else -}}
{{- tpl (.value | toYaml) .context -}}
{{- end -}}
{{- end -}}

{{/* Validate and render the restricted topology label template with a Tier-only context. */}}
{{- define "unifabric.topologyLabelKey" -}}
{{- $raw := required "topology label template is required" .template -}}
{{- $tier := int .tier -}}
{{- if lt $tier 1 -}}
{{- fail "topology label tier must be greater than or equal to 1" -}}
{{- end -}}
{{- $actionPattern := `\{\{[[:space:]]*\.Tier[[:space:]]*\}\}` -}}
{{- $actions := regexFindAll $actionPattern $raw -1 -}}
{{- $stripped := regexReplaceAll $actionPattern $raw "" -}}
{{- if or (ne (len $actions) 1) (contains "{{" $stripped) (contains "}}" $stripped) -}}
{{- fail (printf "topology label template %q must contain fixed text and exactly one {{ .Tier }} action" $raw) -}}
{{- end -}}
{{- $key := tpl $raw (dict "Tier" $tier) -}}
{{- $parts := splitList "/" $key -}}
{{- if or (lt (len $parts) 1) (gt (len $parts) 2) -}}
{{- fail (printf "topology label template %q renders invalid Kubernetes label key %q" $raw $key) -}}
{{- end -}}
{{- $name := last $parts -}}
{{- if or (gt (len $name) 63) (not (regexMatch `^[A-Za-z0-9]([-A-Za-z0-9_.]*[A-Za-z0-9])?$` $name)) -}}
{{- fail (printf "topology label template %q renders invalid Kubernetes label key %q" $raw $key) -}}
{{- end -}}
{{- if eq (len $parts) 2 -}}
{{- $prefix := first $parts -}}
{{- if or (gt (len $prefix) 253) (not (regexMatch `^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$` $prefix)) -}}
{{- fail (printf "topology label template %q renders invalid Kubernetes label key %q" $raw $key) -}}
{{- end -}}
{{- end -}}
{{- $key -}}
{{- end -}}

{{- define "unifabric.topoDiscovery.validate" -}}
{{- if hasKey .Values "topologyLabels" -}}
{{- fail "topologyLabels has been replaced by topoDiscovery.*.nodeLabel.keyTemplate" -}}
{{- end -}}
{{- if hasKey .Values "internalTopologyLabelWriter" -}}
{{- fail "internalTopologyLabelWriter has been replaced by topoDiscovery.*.mode" -}}
{{- end -}}
{{- if hasKey .Values "switchTopologyDiscovery" -}}
{{- fail "switchTopologyDiscovery has been renamed to switchSubscription" -}}
{{- end -}}
{{- if hasKey .Values "switchDiscovery" -}}
{{- fail "switchDiscovery has been renamed to switchSubscription" -}}
{{- end -}}
{{- if hasKey .Values "switchAgent" -}}
{{- fail "switchAgent has been renamed to switchSubscription" -}}
{{- end -}}
{{- if hasKey .Values "nodeTopologyDiscovery" -}}
{{- fail "nodeTopologyDiscovery has been renamed to fabricNode" -}}
{{- end -}}
{{- if hasKey .Values "nodeDiscovery" -}}
{{- fail "nodeDiscovery has been renamed to fabricNode" -}}
{{- end -}}
{{- if hasKey .Values.switchSubscription "enabled" -}}
{{- fail "switchSubscription.enabled has been replaced by topoDiscovery.scaleOut.mode and topoDiscovery.storage.mode" -}}
{{- end -}}
{{- range $key := list "dialTimeout" "reconnectBackoff" "maxRecvMsgSize" "keepaliveTime" -}}
{{- if hasKey $.Values.switchSubscription $key -}}
{{- fail (printf "switchSubscription.%s is now an internal controller default and is no longer configurable" $key) -}}
{{- end -}}
{{- end -}}
{{- if hasKey .Values.switchSubscription "ignoreSwitchPorts" -}}
{{- fail "switchSubscription.ignoreSwitchPorts has been renamed to switchSubscription.ignorePortPatterns" -}}
{{- end -}}
{{- range $key := list "enabled" "autoGenerate" -}}
{{- if hasKey $.Values.switchSubscription.mtls $key -}}
{{- fail (printf "switchSubscription.mtls.%s has been replaced by switchSubscription.mtls.mode=auto|existing|disabled" $key) -}}
{{- end -}}
{{- end -}}
{{- if hasKey .Values.switchSubscription.mtls "validityDays" -}}
{{- fail "switchSubscription.mtls.validityDays is now an internal certificate default and is no longer configurable" -}}
{{- end -}}
{{- $switchMTLSMode := lower (required "switchSubscription.mtls.mode is required" .Values.switchSubscription.mtls.mode) -}}
{{- if not (has $switchMTLSMode (list "auto" "existing" "disabled")) -}}
{{- fail (printf "switchSubscription.mtls.mode %q is invalid; expected auto, existing, or disabled" .Values.switchSubscription.mtls.mode) -}}
{{- end -}}
{{- if and (eq $switchMTLSMode "existing") (or (empty .Values.switchSubscription.mtls.controllerSecretName) (empty .Values.switchSubscription.mtls.switchAgentSecretName)) -}}
{{- fail "switchSubscription.mtls.mode=existing requires controllerSecretName and switchAgentSecretName" -}}
{{- end -}}
{{- if hasKey .Values.nvidiaTopograph "enable" -}}
{{- fail "nvidiaTopograph.enable has been replaced by topoDiscovery.scaleUp.mode and topoDiscovery.scaleOut.mode" -}}
{{- end -}}
{{- range $key := list "engine" "service" "imagePullSecrets" "topograph" "nodeObserver" "nodeDataBroker" -}}
{{- if hasKey $.Values.nvidiaTopograph $key -}}
{{- fail (printf "nvidiaTopograph.%s has been removed; use the simplified provider, image, gpuNodeSelector, and gpuNodeTolerations values" $key) -}}
{{- end -}}
{{- end -}}
{{- if hasKey .Values.nvidiaTopograph "credentialsSecret" -}}
{{- fail "nvidiaTopograph.credentialsSecret has been replaced by nvidiaTopograph.credentialsSecretName" -}}
{{- end -}}
{{- if hasKey .Values.nvidiaTopograph.provider "creds" -}}
{{- fail "nvidiaTopograph.provider.creds is not supported because it stores credentials in plaintext; use nvidiaTopograph.credentialsSecretName" -}}
{{- end -}}
{{- if and
  (eq (include "unifabric.nvidiaTopograph.enabled" .) "true")
  (eq (lower .Values.nvidiaTopograph.provider.name) "netq")
  (empty .Values.nvidiaTopograph.credentialsSecretName) -}}
{{- fail "nvidiaTopograph.credentialsSecretName is required when provider.name=netq" -}}
{{- end -}}
{{- if hasKey .Values.agent.lldp "image" -}}
{{- fail "agent.lldp.image has been removed; the lldpd sidecar now reuses agent.image" -}}
{{- end -}}
{{- if hasKey (.Values.nvidiaTopograph.provider.params | default dict) "useGpuCliqueLabel" -}}
{{- fail "nvidiaTopograph.provider.params.useGpuCliqueLabel has moved to nvidiaTopograph.useGpuCliqueLabel" -}}
{{- end -}}
{{- $scaleUpMode := include "unifabric.topoDiscovery.scaleUpMode" . -}}
{{- $scaleOutMode := include "unifabric.topoDiscovery.scaleOutMode" . -}}
{{- $storageMode := include "unifabric.topoDiscovery.storageMode" . -}}
{{- if eq $scaleUpMode "nvswitch" -}}
{{- fail "topoDiscovery.scaleUp.mode=nvswitch has been renamed to topoDiscovery.scaleUp.mode=nv-topograph" -}}
{{- end -}}
{{- if not (has $scaleUpMode (list "nv-topograph" "manual")) -}}
{{- fail (printf "topoDiscovery.scaleUp.mode %q is invalid; expected nv-topograph or manual" .Values.topoDiscovery.scaleUp.mode) -}}
{{- end -}}
{{- if eq $scaleOutMode "topograph" -}}
{{- fail "topoDiscovery.scaleOut.mode=topograph has been renamed to topoDiscovery.scaleOut.mode=nv-topograph" -}}
{{- end -}}
{{- if not (has $scaleOutMode (list "nv-topograph" "unifabric-roce")) -}}
{{- fail (printf "topoDiscovery.scaleOut.mode %q is invalid; expected nv-topograph or unifabric-roce" .Values.topoDiscovery.scaleOut.mode) -}}
{{- end -}}
{{- if not (has $storageMode (list "unifabric-roce" "unifabric-ib")) -}}
{{- fail (printf "topoDiscovery.storage.mode %q is invalid; expected unifabric-roce or unifabric-ib" .Values.topoDiscovery.storage.mode) -}}
{{- end -}}
{{- $scaleUp1 := include "unifabric.topologyLabelKey" (dict "template" .Values.topoDiscovery.scaleUp.nodeLabel.keyTemplate "tier" 1) -}}
{{- $scaleOut1 := include "unifabric.topologyLabelKey" (dict "template" .Values.topoDiscovery.scaleOut.nodeLabel.keyTemplate "tier" 1) -}}
{{- $storage1 := include "unifabric.topologyLabelKey" (dict "template" .Values.topoDiscovery.storage.nodeLabel.keyTemplate "tier" 1) -}}
{{- $scaleUp12 := include "unifabric.topologyLabelKey" (dict "template" .Values.topoDiscovery.scaleUp.nodeLabel.keyTemplate "tier" 12) -}}
{{- $scaleOut12 := include "unifabric.topologyLabelKey" (dict "template" .Values.topoDiscovery.scaleOut.nodeLabel.keyTemplate "tier" 12) -}}
{{- $storage12 := include "unifabric.topologyLabelKey" (dict "template" .Values.topoDiscovery.storage.nodeLabel.keyTemplate "tier" 12) -}}
{{- if or (eq $scaleUp1 $scaleOut1) (eq $scaleUp1 $storage1) (eq $scaleOut1 $storage1) (eq $scaleUp12 $scaleOut12) (eq $scaleUp12 $storage12) (eq $scaleOut12 $storage12) -}}
{{- fail "topoDiscovery scaleUp, scaleOut, and storage label templates must generate disjoint label keys" -}}
{{- end -}}
{{- end -}}

{{- define "unifabric.image" -}}
{{- $root := .root -}}
{{- $image := .image -}}
{{- $defaultRegistry := .defaultRegistry | default "" -}}
{{- $defaultRepository := .defaultRepository | default "" -}}
{{- $defaultTag := .defaultTag | default $root.Chart.AppVersion -}}
{{- $registry := $root.Values.global.registry | default $image.registry | default $defaultRegistry -}}
{{- $repository := $image.repository | default $defaultRepository -}}
{{- $tag := $image.tag | default $defaultTag -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- end -}}

{{- define "unifabric.nvidiaTopograph.topographName" -}}
{{- printf "%s-nvidia-topograph" (include "unifabric.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "unifabric.nvidiaTopograph.nodeObserverName" -}}
{{- printf "%s-nvidia-node-observer" (include "unifabric.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "unifabric.nvidiaTopograph.nodeDataBrokerName" -}}
{{- printf "%s-nvidia-node-data-broker" (include "unifabric.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "unifabric.nvidiaTopograph.topographServiceAccountName" -}}
{{- include "unifabric.nvidiaTopograph.topographName" . -}}
{{- end -}}

{{- define "unifabric.nvidiaTopograph.nodeObserverServiceAccountName" -}}
{{- include "unifabric.nvidiaTopograph.nodeObserverName" . -}}
{{- end -}}

{{- define "unifabric.nvidiaTopograph.nodeDataBrokerServiceAccountName" -}}
{{- include "unifabric.nvidiaTopograph.nodeDataBrokerName" . -}}
{{- end -}}

{{- define "unifabric.nvidiaTopograph.selectorLabels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}

{{- define "unifabric.nvidiaTopograph.labels" -}}
helm.sh/chart: {{ include "unifabric.chart" .root }}
{{ include "unifabric.nvidiaTopograph.selectorLabels" . }}
app.kubernetes.io/version: {{ .root.Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .root.Release.Service }}
app.kubernetes.io/part-of: {{ include "unifabric.name" .root }}
{{- end -}}

{{- define "unifabric.nvidiaTopograph.url" -}}
{{- printf "http://%s.%s.svc.cluster.local:49021" (include "unifabric.nvidiaTopograph.topographName" .) .Release.Namespace -}}
{{- end -}}

{{- define "unifabric.nvidiaTopograph.useGpuCliqueLabel" -}}
{{- if and (eq .Values.nvidiaTopograph.provider.name "infiniband-k8s") (eq (lower (toString .Values.nvidiaTopograph.useGpuCliqueLabel)) "true") -}}
true
{{- end -}}
{{- end -}}

{{- define "unifabric.ebpfFlowEventCollectorName" -}}
{{- printf "%s-ebpf-flow-event-collector" (include "unifabric.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
memory_limiter limit derived from the container memory limit, 75 percent
of it in MiB, falling back to 1500 when no limit is set.
*/}}
{{- define "unifabric.ebpfFlowEventCollector.memoryLimitMib" -}}
{{- $limit := dig "limits" "memory" "" .Values.ebpfFlowEventCollector.resources -}}
{{- if $limit -}}
{{- $bytes := $limit | toString | trimSuffix "i" -}}
{{- $mib := 1500 -}}
{{- if hasSuffix "G" $bytes -}}
{{- $mib = mul ($bytes | trimSuffix "G" | int) 1024 -}}
{{- else if hasSuffix "M" $bytes -}}
{{- $mib = $bytes | trimSuffix "M" | int -}}
{{- end -}}
{{- div (mul $mib 3) 4 -}}
{{- else -}}
1500
{{- end -}}
{{- end -}}

{{- define "unifabric.ebpfFlowEventCollector.exporters" -}}
{{- $exporters := list -}}
{{- if .Values.ebpfFlowEventCollector.clickhouse.enabled -}}
{{- $exporters = append $exporters "clickhouse" -}}
{{- end -}}
{{- if .Values.ebpfFlowEventCollector.elasticsearch.enabled -}}
{{- $exporters = append $exporters "elasticsearch" -}}
{{- end -}}
{{- join ", " $exporters -}}
{{- end -}}

{{/*
OTLP endpoint of the in-release Collector. Enabling flow events requires this
Collector because external Collector endpoints are not configurable.
*/}}
{{- define "unifabric.ebpfFlow.otlpEndpoint" -}}
{{- if not .Values.agent.ebpfFlow.flowEvents.enabled -}}
{{- "" -}}
{{- else -}}
{{- printf "%s.%s.svc:4317" (include "unifabric.ebpfFlowEventCollectorName" .) .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{- define "unifabric.ebpfFlowClickHouseName" -}}
{{- printf "%s-ebpf-flow-clickhouse" (include "unifabric.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "unifabric.elasticsearchName" -}}
{{- printf "%s-elasticsearch" (include "unifabric.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The bundled test backends are deployed only while the Collector writes to
that backend and no external endpoint is configured.
*/}}
{{- define "unifabric.ebpfFlow.clickhouseBundled" -}}
{{- $ch := .Values.ebpfFlowEventCollector.clickhouse -}}
{{- if and .Values.agent.ebpfFlow.flowEvents.enabled $ch.enabled (not $ch.endpoint) -}}true{{- end -}}
{{- end -}}

{{- define "unifabric.ebpfFlow.elasticsearchBundled" -}}
{{- $es := .Values.ebpfFlowEventCollector.elasticsearch -}}
{{- if and .Values.agent.ebpfFlow.flowEvents.enabled $es.enabled (not $es.endpoints) -}}true{{- end -}}
{{- end -}}

{{- define "unifabric.ebpfFlow.clickhouseEndpoint" -}}
{{- $ch := .Values.ebpfFlowEventCollector.clickhouse -}}
{{- if $ch.endpoint -}}
{{- $ch.endpoint -}}
{{- else -}}
{{- printf "tcp://%s.%s.svc:9000" (include "unifabric.ebpfFlowClickHouseName" .) .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{/* Returns the endpoint list as JSON so it can be pasted into the config. */}}
{{- define "unifabric.ebpfFlow.elasticsearchEndpoints" -}}
{{- $es := .Values.ebpfFlowEventCollector.elasticsearch -}}
{{- if $es.endpoints -}}
{{- toJson $es.endpoints -}}
{{- else -}}
{{- list (printf "http://%s.%s.svc:9200" (include "unifabric.elasticsearchName" .) .Release.Namespace) | toJson -}}
{{- end -}}
{{- end -}}

{{/*
Passwords fall back to a fixed test value only for the bundled instances,
an external backend must provide password or existingSecret.
*/}}
{{- define "unifabric.ebpfFlow.clickhousePassword" -}}
{{- $ch := .Values.ebpfFlowEventCollector.clickhouse -}}
{{- if $ch.password -}}
{{- $ch.password -}}
{{- else if include "unifabric.ebpfFlow.clickhouseBundled" . -}}
rdma-flow
{{- end -}}
{{- end -}}

{{- define "unifabric.ebpfFlow.elasticsearchPassword" -}}
{{- $es := .Values.ebpfFlowEventCollector.elasticsearch -}}
{{- if $es.password -}}
{{- $es.password -}}
{{- else if include "unifabric.ebpfFlow.elasticsearchBundled" . -}}
rdma-flow
{{- end -}}
{{- end -}}

{{/* Secret name and key holding a backend password. */}}
{{- define "unifabric.ebpfFlow.clickhouseSecretName" -}}
{{- .Values.ebpfFlowEventCollector.clickhouse.existingSecret | default (include "unifabric.ebpfFlowEventCollectorName" .) -}}
{{- end -}}
{{- define "unifabric.ebpfFlow.clickhouseSecretKey" -}}
{{- ternary "password" "clickhouse-password" (ne .Values.ebpfFlowEventCollector.clickhouse.existingSecret "") -}}
{{- end -}}
{{- define "unifabric.ebpfFlow.elasticsearchSecretName" -}}
{{- .Values.ebpfFlowEventCollector.elasticsearch.existingSecret | default (include "unifabric.ebpfFlowEventCollectorName" .) -}}
{{- end -}}
{{- define "unifabric.ebpfFlow.elasticsearchSecretKey" -}}
{{- ternary "password" "elasticsearch-password" (ne .Values.ebpfFlowEventCollector.elasticsearch.existingSecret "") -}}
{{- end -}}
