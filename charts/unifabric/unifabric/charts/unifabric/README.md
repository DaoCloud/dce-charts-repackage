# Helm Values

## Global Settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.imagePullSecrets | list | `[]` | Image pull secrets applied to Unifabric controller and agent pods. |
| global.registry | string | `""` | Registry prepended to chart-managed images when an image-specific registry is not set. |

## Topology Discovery

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| topoDiscovery.scaleOut.mode | string | `"unifabric-roce"` | Scale-out discovery mode. Options: nv-topograph (NVIDIA Topograph) or unifabric-roce (built-in LLDP discovery). |
| topoDiscovery.scaleOut.nodeLabel.keyTemplate | string | `"scale-out.unifabric.io/tier-{{ .Tier }}"` | Go text/template for scale-out topology label keys. It must contain exactly one {{ .Tier }} action. |
| topoDiscovery.scaleUp.mode | string | `"manual"` | Scale-up discovery mode. Options: nv-topograph (NVIDIA Topograph) or manual (labels are managed externally). |
| topoDiscovery.scaleUp.nodeLabel.keyTemplate | string | `"scale-up.unifabric.io/tier-{{ .Tier }}"` | Go text/template for scale-up topology label keys. It must contain exactly one {{ .Tier }} action. |
| topoDiscovery.storage.mode | string | `"unifabric-roce"` | Storage discovery mode. Currently supported: unifabric-roce (RoCE storage). |
| topoDiscovery.storage.nodeLabel.keyTemplate | string | `"storage.unifabric.io/tier-{{ .Tier }}"` | Go text/template for storage topology label keys. It must contain exactly one {{ .Tier }} action. |

`topoDiscovery.*.mode` is the only topology-writer switch. The former
`topologyLabels`, `internalTopologyLabelWriter.enabled`,
`switchTopologyDiscovery`, `switchDiscovery`, `switchAgent`,
`nodeTopologyDiscovery`, `nodeDiscovery`, and `nvidiaTopograph.enable` values
are rejected with migration errors instead of being silently ignored. The
former component-level NVIDIA blocks are replaced by the shared
`nvidiaTopograph.image` and GPU-node values.

## Switch Subscription

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| switchSubscription.defaultGrpcPort | int | `8090` | Default gRPC port used when a Switch resource does not set spec.grpcPort. |
| switchSubscription.ignorePortPatterns | list | `["mgmt*","Management*","oob*"]` | Glob patterns for switch local ports ignored before topology graph construction. |
| switchSubscription.mtls.controllerSecretName | string | `"switch-controller-mtls-controller"` | Secret mounted into the controller containing tls.crt, tls.key, and peer.crt. |
| switchSubscription.mtls.mode | string | `"auto"` | Certificate mode: auto generates Helm-managed Secrets, existing uses pre-created Secrets, and disabled uses plaintext gRPC. |
| switchSubscription.mtls.switchAgentSecretName | string | `"switch-controller-mtls-agent"` | Secret exported for switch agents containing tls.crt, tls.key, and peer.crt. |

Per-switch addresses and port overrides belong to `Switch.spec`. gRPC transport
tuning uses Controller defaults, while `switchSubscription.mtls.mode` selects
auto-generated, existing, or disabled mTLS.

## FabricNode Reporting and Observability

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fabricNode.initialScanDelay | string | `"1m"` | Delay before the first agent scan, allowing lldpd to learn neighbors. |
| fabricNode.refreshInterval | string | `"1m"` | Interval between agent refreshes of local RDMA interfaces and LLDP neighbors. |
| fabricNode.scaleOutInterfaceSelector | string | `""` | RDMA interfaces included in scale-out topology and metrics. Supports selectors such as cidr=172.17.0.0/16 or interface=eth*,!eth9. |
| fabricNode.scaleUpInterfaceSelector | string | `""` | RDMA interfaces classified as scale-up and excluded from scale-out topology. Leave empty when no dedicated scale-up RDMA network exists. |
| fabricNode.storageInterfaceSelector | string | `""` | RDMA interfaces classified as storage and excluded from scale-out topology. Leave empty when no dedicated storage RDMA network exists. |
| nodeMetrics.enabled | bool | `true` | Enable RDMA metrics collection and expose the agent metrics Service. |
| nodeMetrics.path | string | `"/metrics"` | HTTP path served by the agent metrics endpoint. |
| nodeMetrics.port | int | `8082` | Container port used by the agent metrics endpoint. |
| nodeMetrics.service.port | int | `8086` | Service port used by Prometheus to scrape agent RDMA metrics. |
| nodeMetrics.service.type | string | `"ClusterIP"` | Kubernetes Service type for agent RDMA metrics. |
| nodeMetrics.serviceMonitor.enabled | bool | `true` | Create a Prometheus Operator ServiceMonitor for agent RDMA metrics. |
| nodeMetrics.serviceMonitor.interval | string | `"15s"` | Prometheus scrape interval for agent RDMA metrics. |
| nodeMetrics.serviceMonitor.labels | object | `{}` | Extra labels added to the ServiceMonitor for Prometheus selection. |
| nodeMetrics.serviceMonitor.path | string | `"/metrics"` | HTTP path scraped by the ServiceMonitor. |
| nodeMetrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Prometheus scrape timeout for agent RDMA metrics. |
| topologyAPI.enabled | bool | `false` | Enable the Topology HTTP API. Disabled by default since it has no authentication of its own. |
| grafanaDashboard.allowCrossNamespaceImport | bool | `true` | Allow Grafana Operator to import GrafanaDashboard resources across namespaces. |
| grafanaDashboard.enabled | bool | `true` | Render the bundled Grafana dashboards. |
| grafanaDashboard.instanceSelector | object | `{}` | Grafana Operator instance selector for importing dashboards and the Topology datasource into an external Grafana instance. Ignored when grafanaInstance.enabled is true. |
| grafanaDashboard.kind | string | `"GrafanaDashboard"` | Dashboard resource kind. Use ConfigMap for Grafana sidecar import, or GrafanaDashboard for Grafana Operator. |
| grafanaDashboard.labels | object | `{}` | Extra labels added to rendered dashboard resources. |
| grafanaDashboard.language | string | `"en"` | Dashboard language to install. en installs the English dashboards, zh the Chinese ones with a -zh suffix on their uid and resource name, all installs both. |
| grafanaInstance.enabled | bool | `false` | Create a Grafana CR for this release and, when topologyAPI.enabled is true, its Topology GrafanaDatasource. |
| grafanaInstance.image.registry | string | `"ghcr.io"` | Container image registry for the bundled Grafana instance. |
| grafanaInstance.image.repository | string | `"unifabric-io/unifabric-grafana"` | Container image repository containing the Unifabric Grafana plugins. |
| grafanaInstance.image.tag | string | `""` | Container image tag. Defaults to the chart appVersion when empty. |
| grafanaInstance.labels | object | `{}` | Extra labels added to the Grafana instance. |
| grafanaInstance.serviceType | string | `"NodePort"` | Kubernetes Service type for the bundled Grafana instance. |

## Controller and Agent

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| controller.affinity | object | `{}` | Affinity rules for scheduling controller pods. |
| controller.config.healthProbe.bindAddress | string | `":8081"` | Controller health and readiness bind address inside the container. |
| controller.config.leaderElection.enabled | bool | `true` | Enable Kubernetes leader election for the controller. |
| controller.config.leaderElection.id | string | `"unifabric-controller"` | Leader election lease identifier. |
| controller.config.leaderElection.namespace | string | `""` | Namespace used for leader election leases. Empty uses the release namespace. |
| controller.config.logLevel | string | `"info"` | Controller log level. Valid values are debug, info, warn, and error. |
| controller.config.metrics.bindAddress | string | `":8080"` | Controller metrics bind address inside the container. |
| controller.config.pprof.bindAddress | string | `""` | Controller pprof bind address. Leave empty to disable pprof. |
| controller.containerSecurityContext.allowPrivilegeEscalation | bool | `false` | Prevent privilege escalation in the controller container. |
| controller.containerSecurityContext.capabilities.drop | list | `["ALL"]` | Linux capabilities dropped from the controller container. |
| controller.containerSecurityContext.readOnlyRootFilesystem | bool | `true` | Mount the controller container root filesystem as read-only. |
| controller.enabled | bool | `true` | Deploy the Unifabric controller. |
| controller.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the controller container. |
| controller.image.registry | string | `"ghcr.io"` | Container image registry for the controller. |
| controller.image.repository | string | `"unifabric-io/unifabric-controller"` | Container image repository for the controller. |
| controller.image.tag | string | `""` | Container image tag for the controller. Defaults to the chart appVersion when empty. |
| controller.nodeSelector | object | `{}` | Node selector for scheduling controller pods. |
| controller.podAnnotations | object | `{}` | Annotations added to controller pods. |
| controller.podLabels | object | `{}` | Extra labels added to controller pods. |
| controller.podSecurityContext.fsGroup | int | `65532` | Filesystem group ID used by mounted controller volumes. |
| controller.podSecurityContext.runAsGroup | int | `65532` | Group ID used by controller containers. |
| controller.podSecurityContext.runAsNonRoot | bool | `true` | Run the controller pod as a non-root user. |
| controller.podSecurityContext.runAsUser | int | `65532` | User ID used by controller containers. |
| controller.podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` | Seccomp profile applied to controller pods. |
| controller.ports.health | int | `8081` | Controller health probe container port. |
| controller.ports.metrics | int | `8080` | Controller metrics container port. |
| controller.ports.topologyAPI | int | `8082` | Controller Topology API container, Service, and datasource port. Only listened on when topologyAPI.enabled is true. |
| controller.replicaCount | int | `1` | Number of controller replicas. |
| controller.resources.limits.cpu | string | `"500m"` | Controller CPU limit. |
| controller.resources.limits.memory | string | `"512Mi"` | Controller memory limit. |
| controller.resources.requests.cpu | string | `"100m"` | Controller CPU request. |
| controller.resources.requests.memory | string | `"128Mi"` | Controller memory request. |
| controller.service.enabled | bool | `true` | Create a Service for the controller metrics endpoint. |
| controller.service.port | int | `8080` | Service port for controller metrics. |
| controller.service.type | string | `"ClusterIP"` | Kubernetes Service type for the controller metrics endpoint. |
| controller.serviceAccount.annotations | object | `{}` | Annotations added to the controller ServiceAccount. |
| controller.serviceAccount.create | bool | `true` | Create a ServiceAccount for the controller. |
| controller.serviceAccount.name | string | `""` | Controller ServiceAccount name. Defaults to the generated controller name when empty. |
| controller.tolerations | list | `[]` | Tolerations for scheduling controller pods. |
| agent.affinity.nodeAffinity | object | See chart/values.yaml for the full default node affinity. | Default Linux node affinity for agent pods. |
| agent.config.healthProbe.bindAddress | string | `":8083"` | Agent health and readiness bind address inside the container. |
| agent.config.logLevel | string | `"info"` | Agent log level. Valid values are debug, info, warn, and error. |
| agent.config.metrics.bindAddress | string | `":8082"` | Agent metrics bind address inside the container. |
| agent.config.node.defaultRouteProbe | string | `"8.8.8.8:53"` | host:port used to infer the default route when classifying local interfaces. |
| agent.config.node.name | string | `""` | Kubernetes node name override. Leave empty to use the pod NODE_NAME environment value. |
| agent.config.node.role | string | `"gpu"` | Agent node role. Valid values are gpu and storage. |
| agent.containerSecurityContext.privileged | bool | `true` | Run the agent container as privileged so it can inspect host RDMA and network state. |
| agent.ebpfFlow.bpffsPath | string | `"/sys/fs/bpf"` | Host bpffs mount holding the pinned qp_infos and qp_stats maps. |
| agent.ebpfFlow.discoveryInterval | string | `"5s"` | Fallback interval for scanning new processes and libibverbs libraries. |
| agent.ebpfFlow.enabled | bool | `false` | Enable the eBPF flow component that attributes RDMA sends to Pod-to-Pod flows, publishes RDMAEndpoint objects and exports rdma_flow_* metrics. Requires a kernel with BPF ring buffer and uprobe support. |
| agent.ebpfFlow.endpoint.allPods | bool | `false` | Also publish Pods with their own network namespace. Required on InfiniBand fabrics where peers are addressed by LID. |
| agent.ebpfFlow.endpoint.enabled | bool | `true` | Publish one RDMAEndpoint per Pod that holds an RDMA device. |
| agent.ebpfFlow.endpoint.interval | string | `"30s"` | Fallback publish interval covering lost events. |
| agent.ebpfFlow.endpoint.minInterval | string | `"3s"` | Minimum spacing between event driven RDMAEndpoint updates. |
| agent.ebpfFlow.flowEvents.aggregate | string | `"0s"` | Merge identical submissions of a QP inside this window into one row with a count. 0s stores every submission. |
| agent.ebpfFlow.flowEvents.batch | int | `10000` | Send event rows per export batch. |
| agent.ebpfFlow.flowEvents.enabled | bool | `false` | Emit per-send ring buffer events, send-size metrics, and OTLP rows. Enable only when per-send details are required; cumulative bytes, WR, and QP flow metrics remain available when disabled. |
| agent.ebpfFlow.flowEvents.flush | string | `"1s"` | Maximum time a partial batch waits before export. |
| agent.ebpfFlow.flowEvents.queue | int | `200000` | Send event rows buffered per sink before new rows are dropped. |
| agent.ebpfFlow.flowEvents.sample | int | `1` | Store one send event in every N, metrics still count every event. |
| agent.ebpfFlow.hostStateDir | string | `"/var/lib/unifabric"` | Host directory persisting learned provider callback offsets across agent restarts. |
| agent.ebpfFlow.offsetCache | string | `"/var/lib/unifabric/ebpf-flow/callback-offsets.json"` | File persisting learned provider callback offsets, under hostStateDir. |
| agent.ebpfFlow.otlp.insecure | bool | `true` | Use plaintext gRPC for the OTLP endpoint. |
| agent.ebpfFlow.otlp.timeout | string | `"10s"` | Per export timeout for the OTLP exporter. |
| agent.ebpfFlow.pinDir | string | `"/sys/fs/bpf/unifabric"` | bpffs directory for pinned maps so a restarted agent keeps learned QP state. Empty disables pinning. |
| agent.ebpfFlow.reportInterval | string | `"5s"` | Interval for joining the BPF maps into flow metrics. |
| agent.enabled | bool | `true` | Deploy the Unifabric node agent DaemonSet. |
| agent.hostNetwork | bool | `true` | Run agent pods in the host network namespace. |
| agent.hostPID | bool | `true` | Run agent pods in the host PID namespace. |
| agent.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy shared by the agent and lldpd sidecar. |
| agent.image.registry | string | `"ghcr.io"` | Container image registry shared by the agent and lldpd sidecar. |
| agent.image.repository | string | `"unifabric-io/unifabric-agent"` | Container image repository shared by the agent and lldpd sidecar. |
| agent.image.tag | string | `""` | Container image tag shared by the agent and lldpd sidecar. Defaults to the chart appVersion when empty. |
| agent.lldp.containerSecurityContext.privileged | bool | `true` | Run the lldpd sidecar as privileged so it can access host network interfaces. |
| agent.lldp.enabled | bool | `true` | Run the lldpd sidecar used by the agent to collect LLDP neighbors. |
| agent.lldp.extraConfig | string | `""` | Additional raw lldpd configuration appended to lldpd.conf. |
| agent.lldp.interfaces | string | `""` | Interface pattern passed to lldpd for LLDP discovery. Leave empty to let lldpd use its defaults. |
| agent.lldp.managementIPPattern | string | `""` | lldpd management IP pattern written to lldpd.conf. Leave empty to let lldpd choose. |
| agent.lldp.resources.limits.cpu | string | `"100m"` | lldpd sidecar CPU limit. |
| agent.lldp.resources.limits.memory | string | `"128Mi"` | lldpd sidecar memory limit. |
| agent.lldp.resources.requests.cpu | string | `"50m"` | lldpd sidecar CPU request. |
| agent.lldp.resources.requests.memory | string | `"64Mi"` | lldpd sidecar memory request. |
| agent.lldp.txInterval | int | `30` | LLDP transmit interval, in seconds, configured for lldpd. |
| agent.nodeSelector | object | `{}` | Node selector for scheduling agent pods. |
| agent.podAnnotations | object | `{}` | Annotations added to agent pods. |
| agent.podLabels | object | `{}` | Extra labels added to agent pods. |
| agent.podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` | Seccomp profile applied to agent pods. |
| agent.ports.health | int | `8083` | Agent health probe container port. |
| agent.ports.metrics | int | `8082` | Agent metrics container port. |
| agent.resources.limits.cpu | string | `"2"` | Agent CPU limit. Keep it generous: the agent issues one ethtool ioctl per RDMA interface (PFs and every SR-IOV VF) while holding the kernel rtnl lock, and CFS throttling mid-ioctl stalls other network operations on the node. |
| agent.resources.limits.memory | string | `"1Gi"` | Agent memory limit. |
| agent.resources.requests.cpu | string | `"100m"` | Agent CPU request. |
| agent.resources.requests.memory | string | `"256Mi"` | Agent memory request. |
| agent.serviceAccount.annotations | object | `{}` | Annotations added to the agent ServiceAccount. |
| agent.serviceAccount.create | bool | `true` | Create a ServiceAccount for the agent. |
| agent.serviceAccount.name | string | `""` | Agent ServiceAccount name. Defaults to the generated agent name when empty. |
| agent.tolerations | list | `[]` | Tolerations for scheduling agent pods. |
| agent.workloadOwnerRules | object | `{"batch.volcano.sh":["jobs"],"jobset.x-k8s.io":["jobsets"],"kubeflow.org":["mpijobs","pytorchjobs","tfjobs","xgboostjobs","paddlejobs","jaxjobs"],"leaderworkerset.x-k8s.io":["leaderworkersets"],"ray.io":["rayclusters","rayjobs","rayservices"],"sparkoperator.k8s.io":["sparkapplications"],"trainer.kubeflow.org":["trainjobs"]}` | Third-party workload kinds the agent may read while walking a Pod's ownerReferences to its top-level owner, rendered into the agent-workload-owners ClusterRole with the get verb. Keys are API groups, values their plural resources, user values merge with these defaults so a new controller is one extra key. Kubernetes built-in kinds and unifabric.io resources are covered by the generated agent role. |

## eBPF RDMA Flow Collector

Optional OpenTelemetry Collector that stores the per-send events produced by
`agent.ebpfFlow` in ClickHouse and/or Elasticsearch. Point `clickhouse.endpoint`
or `elasticsearch.endpoints` at your own servers. When they are left empty the
chart deploys the single replica instances described under `bundled`, which are
meant for testing only. See [docs/usage/rdma-flow.md](../docs/usage/rdma-flow.md).

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ebpfFlowEventCollector.batch.sendBatchMaxSize | int | `20000` | Upper bound of a batch. |
| ebpfFlowEventCollector.batch.sendBatchSize | int | `10000` | Records per batch sent to the backends. |
| ebpfFlowEventCollector.batch.timeout | string | `"1s"` | Maximum time a partial batch waits. |
| ebpfFlowEventCollector.clickhouse.bundled.image.pullPolicy | string | `"IfNotPresent"` | Bundled ClickHouse image pull policy. |
| ebpfFlowEventCollector.clickhouse.bundled.image.registry | string | `"docker.io"` | Bundled ClickHouse image registry. |
| ebpfFlowEventCollector.clickhouse.bundled.image.repository | string | `"clickhouse/clickhouse-server"` | Bundled ClickHouse image repository. |
| ebpfFlowEventCollector.clickhouse.bundled.image.tag | string | `"24.8"` | Bundled ClickHouse image tag. |
| ebpfFlowEventCollector.clickhouse.bundled.nodeSelector | object | `{}` | Node selector for the bundled ClickHouse Pod. |
| ebpfFlowEventCollector.clickhouse.bundled.persistence.enabled | bool | `true` | Keep the data directory on a PersistentVolumeClaim so tables survive Pod recreation. false uses an emptyDir. |
| ebpfFlowEventCollector.clickhouse.bundled.persistence.existingClaim | string | `""` | Existing PersistentVolumeClaim to mount instead of creating one. |
| ebpfFlowEventCollector.clickhouse.bundled.persistence.size | string | `"20Gi"` | Size of the claim, or of the emptyDir limit when persistence is disabled. |
| ebpfFlowEventCollector.clickhouse.bundled.persistence.storageClassName | string | `""` | StorageClass of the claim. Empty uses the cluster default class. |
| ebpfFlowEventCollector.clickhouse.bundled.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"500m","memory":"1Gi"}}` | Bundled ClickHouse container resources. max_server_memory_usage follows the memory limit. |
| ebpfFlowEventCollector.clickhouse.bundled.tolerations | list | `[]` | Tolerations for the bundled ClickHouse Pod. |
| ebpfFlowEventCollector.clickhouse.database | string | `"rdma"` | ClickHouse database holding the send events table. |
| ebpfFlowEventCollector.clickhouse.enabled | bool | `false` | Write send events to ClickHouse. |
| ebpfFlowEventCollector.clickhouse.endpoint | string | `""` | Native protocol endpoint of an external ClickHouse, for example tcp://clickhouse.data.svc:9000. Leave empty to deploy the bundled test instance described under bundled instead. |
| ebpfFlowEventCollector.clickhouse.existingSecret | string | `""` | Existing Secret with a password key used instead of password. |
| ebpfFlowEventCollector.clickhouse.password | string | `""` | ClickHouse password. Defaults to rdma-flow for the bundled test instance. Prefer existingSecret for an external server. |
| ebpfFlowEventCollector.clickhouse.schema.create | bool | `true` | Create the database and the strongly typed table with an init container before the Collector starts. The exporter never creates the schema itself. |
| ebpfFlowEventCollector.clickhouse.schema.image.registry | string | `"docker.io"` | ClickHouse client image used by the schema init container. |
| ebpfFlowEventCollector.clickhouse.schema.image.repository | string | `"clickhouse/clickhouse-server"` | ClickHouse client image repository. |
| ebpfFlowEventCollector.clickhouse.schema.image.tag | string | `"24.8"` | ClickHouse client image tag. |
| ebpfFlowEventCollector.clickhouse.table | string | `"rdma_sends"` | ClickHouse table name. |
| ebpfFlowEventCollector.clickhouse.ttlDays | int | `3` | Row retention applied by the table TTL. |
| ebpfFlowEventCollector.clickhouse.username | string | `"rdma"` | ClickHouse user. |
| ebpfFlowEventCollector.elasticsearch.bundled.exporter.enabled | bool | `true` | Run the elasticsearch-exporter sidecar exposing elasticsearch_* metrics on port 9114 for the dashboards. |
| ebpfFlowEventCollector.elasticsearch.bundled.exporter.image.registry | string | `"quay.io"` | elasticsearch-exporter image registry. |
| ebpfFlowEventCollector.elasticsearch.bundled.exporter.image.repository | string | `"prometheuscommunity/elasticsearch-exporter"` | elasticsearch-exporter image repository. |
| ebpfFlowEventCollector.elasticsearch.bundled.exporter.image.tag | string | `"v1.7.0"` | elasticsearch-exporter image tag. |
| ebpfFlowEventCollector.elasticsearch.bundled.image.pullPolicy | string | `"IfNotPresent"` | Bundled Elasticsearch image pull policy. |
| ebpfFlowEventCollector.elasticsearch.bundled.image.registry | string | `"docker.elastic.co"` | Bundled Elasticsearch image registry. |
| ebpfFlowEventCollector.elasticsearch.bundled.image.repository | string | `"elasticsearch/elasticsearch"` | Bundled Elasticsearch image repository. |
| ebpfFlowEventCollector.elasticsearch.bundled.image.tag | string | `"8.15.3"` | Bundled Elasticsearch image tag. |
| ebpfFlowEventCollector.elasticsearch.bundled.javaHeap | string | `"2g"` | JVM heap passed as -Xms and -Xmx. Keep it at half of the memory limit or less. |
| ebpfFlowEventCollector.elasticsearch.bundled.nodeSelector | object | `{}` | Node selector for the bundled Elasticsearch Pod. |
| ebpfFlowEventCollector.elasticsearch.bundled.persistence.enabled | bool | `false` | Keep the data directory on a PersistentVolumeClaim. false uses an emptyDir and loses data on Pod recreation. |
| ebpfFlowEventCollector.elasticsearch.bundled.persistence.existingClaim | string | `""` | Existing PersistentVolumeClaim to mount instead of creating one. |
| ebpfFlowEventCollector.elasticsearch.bundled.persistence.size | string | `"20Gi"` | Size of the claim, or of the emptyDir limit when persistence is disabled. |
| ebpfFlowEventCollector.elasticsearch.bundled.persistence.storageClassName | string | `""` | StorageClass of the claim. Empty uses the cluster default class. |
| ebpfFlowEventCollector.elasticsearch.bundled.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"1","memory":"3Gi"}}` | Bundled Elasticsearch container resources. |
| ebpfFlowEventCollector.elasticsearch.bundled.sysctlImage.registry | string | `"docker.io"` | busybox image used by the privileged init container raising vm.max_map_count. |
| ebpfFlowEventCollector.elasticsearch.bundled.sysctlImage.repository | string | `"library/busybox"` | busybox image repository. |
| ebpfFlowEventCollector.elasticsearch.bundled.sysctlImage.tag | string | `"1.36"` | busybox image tag. |
| ebpfFlowEventCollector.elasticsearch.bundled.tolerations | list | `[]` | Tolerations for the bundled Elasticsearch Pod. |
| ebpfFlowEventCollector.elasticsearch.enabled | bool | `false` | Write send events to Elasticsearch as a data stream. |
| ebpfFlowEventCollector.elasticsearch.endpoints | list | `[]` | HTTP endpoints of an external Elasticsearch, for example http://elasticsearch.data.svc:9200. Leave empty to deploy the bundled test instance described under bundled instead. |
| ebpfFlowEventCollector.elasticsearch.existingSecret | string | `""` | Existing Secret with a password key used instead of password. |
| ebpfFlowEventCollector.elasticsearch.grafanaDatasource.enabled | bool | `true` | Create a GrafanaDatasource for the data stream so the flow-sends-es dashboard works. Requires grafanaDashboard.kind GrafanaDashboard. |
| ebpfFlowEventCollector.elasticsearch.index | string | `"rdma-sends"` | Data stream receiving the documents. |
| ebpfFlowEventCollector.elasticsearch.password | string | `""` | Elasticsearch password. Defaults to rdma-flow for the bundled test instance. Prefer existingSecret for an external cluster. |
| ebpfFlowEventCollector.elasticsearch.schema.create | bool | `true` | Write the index template and ILM policy of the data stream before the Collector starts. The template maps every attribute as keyword or number, disables dynamic mapping and uses date_nanos timestamps. |
| ebpfFlowEventCollector.elasticsearch.schema.ilm.deleteMinAge | string | `"3d"` | Delete backing indices this long after rollover. |
| ebpfFlowEventCollector.elasticsearch.schema.ilm.rolloverMaxAge | string | `"1d"` | Roll the write index over after this age. |
| ebpfFlowEventCollector.elasticsearch.schema.ilm.rolloverMaxPrimaryShardSize | string | `"10gb"` | Roll the write index over when a primary shard reaches this size. |
| ebpfFlowEventCollector.elasticsearch.schema.image.registry | string | `"docker.io"` | curl image used by the schema init container against an external Elasticsearch. The bundled instance applies the schema from its own Pod. |
| ebpfFlowEventCollector.elasticsearch.schema.image.repository | string | `"curlimages/curl"` | curl image repository. |
| ebpfFlowEventCollector.elasticsearch.schema.image.tag | string | `"8.10.1"` | curl image tag. |
| ebpfFlowEventCollector.elasticsearch.schema.refreshInterval | string | `"30s"` | Refresh interval of the backing indices. |
| ebpfFlowEventCollector.elasticsearch.user | string | `"elastic"` | Elasticsearch user. |
| ebpfFlowEventCollector.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| ebpfFlowEventCollector.image.registry | string | `"docker.io"` | OpenTelemetry Collector contrib image registry. Only the contrib distribution ships the clickhouse and elasticsearch exporters. |
| ebpfFlowEventCollector.image.repository | string | `"otel/opentelemetry-collector-contrib"` | OpenTelemetry Collector contrib image repository. |
| ebpfFlowEventCollector.image.tag | string | `"0.137.0"` | OpenTelemetry Collector contrib image tag. |
| ebpfFlowEventCollector.nodeSelector | object | `{}` | Node selector for the Collector Pod. |
| ebpfFlowEventCollector.replicas | int | `1` | Collector replicas. Agents hold one gRPC connection each, so more replicas than agents stay idle. |
| ebpfFlowEventCollector.resources.limits.cpu | string | `"2"` | Collector CPU limit. |
| ebpfFlowEventCollector.resources.limits.memory | string | `"2Gi"` | Collector memory limit. memory_limiter is derived from it. |
| ebpfFlowEventCollector.resources.requests.cpu | string | `"500m"` | Collector CPU request. |
| ebpfFlowEventCollector.resources.requests.memory | string | `"512Mi"` | Collector memory request. |
| ebpfFlowEventCollector.serviceMonitor.enabled | bool | `true` | Create a ServiceMonitor for the Collector's own metrics on port 8888. |
| ebpfFlowEventCollector.serviceMonitor.interval | string | `"15s"` | Scrape interval for the Collector metrics. |
| ebpfFlowEventCollector.serviceMonitor.labels | object | `{}` | Extra labels added to the ServiceMonitor. |
| ebpfFlowEventCollector.tolerations | list | `[]` | Tolerations for the Collector Pod. |

## NVIDIA Topograph

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nvidiaTopograph.credentialsSecretName | string | `""` | Existing Secret containing a credentials.yaml key. Required by the netq provider; credentials are mounted only into the topograph Pod. |
| nvidiaTopograph.gpuNodeSelector | object | `{"nvidia.com/gpu.present":"true"}` | Selects GPU Nodes observed by node-observer and running node-data-broker. |
| nvidiaTopograph.gpuNodeTolerations | list | `[]` | Tolerations applied to node-data-broker on selected GPU Nodes. |
| nvidiaTopograph.image.pullPolicy | string | `"IfNotPresent"` | NVIDIA Topograph image pull policy. |
| nvidiaTopograph.image.registry | string | `"ghcr.io"` | NVIDIA Topograph image registry. |
| nvidiaTopograph.image.repository | string | `"nvidia/topograph"` | NVIDIA Topograph image repository. |
| nvidiaTopograph.image.tag | string | `"v0.5.0"` | NVIDIA Topograph image tag. |
| nvidiaTopograph.provider.name | string | `"infiniband-k8s"` | Provider name. Use infiniband-k8s for InfiniBand or netq for Spectrum-X. |
| nvidiaTopograph.provider.params | object | `{}` | Provider-specific parameters, such as apiUrl for netq. |
| nvidiaTopograph.useGpuCliqueLabel | bool | `true` | Use the GPU Operator clique label as the accelerator topology source for infiniband-k8s. |
