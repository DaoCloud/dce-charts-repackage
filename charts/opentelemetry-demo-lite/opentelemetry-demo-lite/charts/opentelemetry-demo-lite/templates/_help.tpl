{{/*
Expand the name of the chart.
*/}}
{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "opentelemetry-demo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "otel-demo-ui.selectorLabels" -}}
{{- if .name }}
app.kubernetes.io/name: {{ include "otel-demo.name" . }}-{{ .name }}
{{- else }}
app.kubernetes.io/name: {{ include "otel-demo.name" . }}
{{- end }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
redis selector
*/}}
{{- define "redis.addr" -}}

{{- if eq .Values.global.middleware.redis.deployBy "builtin" -}}
{{ include "otel-demo.name" . }}-redis:6379
{{- else -}}
redis-standalone.{{ .Release.Namespace }}.svc.cluster.local:6379
{{- end }}
{{- end }}

{{/*
common java opt
*/}}
{{- define "java.common.opt" -}}
-XX:MetaspaceSize=512m -XX:MaxMetaspaceSize=512m -Dspring.application.name=$(OTEL_SERVICE_NAME)
{{- end }}

{{/*
common java nacos opt
*/}}
{{- define "java.nacos.opt" -}}
{{- if .Values.global.microservices.nacos.enabled }}
{{- $opt := "-Dspring.cloud.nacos.config.enabled=true" -}}
{{- $opt = cat  $opt "-Dspring.cloud.nacos.discovery.enabled=true" -}}
{{- $opt = cat  $opt ( printf "-Dspring.cloud.nacos.config.server-addr=%s -Dspring.cloud.nacos.discovery.server-addr=%s" .Values.global.microservices.nacos.registryAddr .Values.global.microservices.nacos.registryAddr ) -}}
{{- $opt = cat  $opt ( printf "-Dspring.cloud.nacos.discovery.namespace=%s" .Values.global.microservices.nacos.registryNamespace ) -}}
{{- $opt = cat  $opt ( printf "-Dspring.cloud.nacos.discovery.group=%s" .Values.global.microservices.nacos.registryServiceGroup ) -}}
{{- $opt = cat  $opt ( printf "-Dspring.cloud.nacos.discovery.cluster-name=%s" .Values.global.microservices.nacos.registryInstanceGroup ) -}}

{{/* check username and password */}}
{{- if ne .Values.global.microservices.nacos.username "" }}
{{- $opt = cat $opt ( printf "-Dspring.cloud.nacos.config.username=%s -Dspring.cloud.nacos.discovery.username=%s" .Values.global.microservices.nacos.username .Values.global.microservices.nacos.username ) -}}
{{- end }}
{{- if ne .Values.global.microservices.nacos.password "" }}
{{- $opt = cat $opt ( printf "-Dspring.cloud.nacos.config.password=%s -Dspring.cloud.nacos.discovery.password=%s" .Values.global.microservices.nacos.password .Values.global.microservices.nacos.password ) -}}
{{- end }}

{{/* metadata k8s */}}
{{- $opt = cat $opt ( printf "-Dspring.cloud.nacos.discovery.metadata.k8s_cluster_id=%s" (lookup "v1" "Namespace" "" "kube-system").metadata.uid ) }}
{{- $opt = cat $opt ( printf "-Dspring.cloud.nacos.discovery.metadata.k8s_cluster_name=%s" .Values.global.microservices.nacos.kubeMetadataClusterName ) -}}

{{- $opt = cat $opt "-Dspring.cloud.nacos.discovery.metadata.k8s_namespace_name=$(K8S_NAMESPACE)" -}}
{{- $opt = cat $opt "-Dspring.cloud.nacos.discovery.metadata.k8s_workload_type=deployment" -}}
{{- $opt = cat $opt "-Dspring.cloud.nacos.discovery.metadata.k8s_workload_name=$(OTEL_SERVICE_NAME)" -}}
{{- $opt = cat $opt "-Dspring.cloud.nacos.discovery.metadata.k8s_service_name=$(OTEL_SERVICE_NAME)" -}}
{{- $opt = cat $opt "-Dspring.cloud.nacos.discovery.metadata.k8s_pod_name=$(OTEL_RESOURCE_ATTRIBUTES_POD_NAME)" -}}
{{- $opt -}}
{{- else }}
-Dspring.cloud.nacos.config.enabled=false -Dspring.cloud.nacos.discovery.enabled=false
{{- end }}
{{- end }}

{{/*
common java sentinel opt
*/}}
{{- define "java.sentinel.opt" -}}
{{- if .Values.global.microservices.sentinel.enabled }}
-Dspring.cloud.sentinel.enabled=true -Dspring.cloud.sentinel.transport.dashboard={{ .Values.global.microservices.nacos.registryAddr }}
{{- else }}
-Dspring.cloud.sentinel.enabled=false
{{- end }}
{{- end }}

{{/*
java dataservice opt
*/}}
{{- define "java.dataservice.opt" -}}
{{- cat ( include "java.common.opt" . ) ( include "java.nacos.opt" . ) ( include "java.sentinel.opt" . ) -}}
{{- end }}

{{/*
common java adservice opt bug
*/}}
{{- define "java.adservice.opt" -}}
{{- $opt := "-Dmeter.port=8888" -}}

{{/* check jvm */}}
{{- if .Values.global.observability.adServiceJVMEnable }}
{{- $opt = cat $opt "-javaagent:./jmx_prometheus_javaagent-0.17.0.jar=12345:./prometheus-jmx-config.yaml" -}}
{{- $opt = cat $opt "-Dotel.metrics.exporter=prometheus" -}}
{{- $opt = cat $opt "-Dotel.exporter.prometheus.port=9464" -}}
{{- end }}

{{/* check nacos is enable */}}
{{- if .Values.global.microservices.nacos.enabled }}
{{- $opt = cat $opt "-Dspring.dataService.enabled=true" -}}
{{- $opt = cat $opt ( printf "-Ddata_service_name=%s-dataservice" .Release.Name ) -}}
{{- else }}
{{- $opt = cat $opt "-Dspring.dataService.enabled=false" -}}
{{- end }}

{{- $opt = cat $opt "-Dspring.extraAdLabel=Daocloud" -}}
{{- $opt = cat $opt "-Dspring.randomError=false" -}}
{{- $opt = cat $opt "-Dspring.matrixRow=200" -}}
{{- $opt = cat $opt  ( include "java.common.opt" . ) ( include "java.nacos.opt" . ) ( include "java.sentinel.opt" . ) -}}
{{- $opt -}}
{{- end }}

