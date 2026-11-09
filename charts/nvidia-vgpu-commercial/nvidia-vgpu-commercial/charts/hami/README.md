# hami-enterprise

![Version: 2.10.0-r5](https://img.shields.io/badge/Version-2.10.0--r5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.10.0-r5](https://img.shields.io/badge/AppVersion-2.10.0--r5-informational?style=flat-square)

Heterogeneous AI Computing Virtualization Middleware

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| limengxuan | <archlitchi@gmail.com> |  |
| zhangxiao | <xiaozhang0210@hotmail.com> |  |

## Source Code

* <https://github.com/dynamia-ai/hami-enterprise>

## Requirements

Kubernetes: `>= 1.18.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://project-hami.github.io/HAMi-DRA/ | hami-dra | 0.2.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| birenResourceName | string | `"birentech.com/gpu"` | Biren GPU resource name |
| device-config.content | string | `""` |  |
| devicePlugin.cdiVendor | string | `""` | CDI vendor for generated specs and device annotations (default: k8s.device-plugin.nvidia.com) |
| devicePlugin.createRuntimeClass | bool | `false` | Whether to create runtime class |
| devicePlugin.deviceCoreScaling | int | `1` | Device core scaling factor |
| devicePlugin.deviceListStrategy | string | `"envvar"` | Device list strategy. Supported values: `envvar`, `volume-mounts`, `cdi-annotations` |
| devicePlugin.deviceMemoryScaling | int | `1` | Device memory scaling factor |
| devicePlugin.deviceSplitCount | int | `10` | Number of slices to split each GPU into |
| devicePlugin.disablecorelimit | string | `"false"` | Disable core limit |
| devicePlugin.enableNumaTopology | bool | `false` | Advertise the physical GPU's NUMA node on each vGPU replica |
| devicePlugin.enabled | bool | `true` | Enable device plugin |
| devicePlugin.extraArgs | list | `["-v=4"]` | Extra arguments for device plugin |
| devicePlugin.extraEnvs | list | `[]` | Extra environment variables for device plugin as a Kubernetes env list. |
| devicePlugin.gdrcopyEnabled | bool | `false` | Enable GDRCopy |
| devicePlugin.gdsEnabled | bool | `false` | Enable GDS |
| devicePlugin.gpuOperatorToolkitReady.enabled | bool | `false` | Enable GPU operator toolkit ready check |
| devicePlugin.gpuOperatorToolkitReady.hostPath | string | `"/run/nvidia/validations"` | Host path for GPU operator toolkit ready check |
| devicePlugin.gpuOperatorToolkitReady.securityContext | object | `{"privileged":true,"runAsUser":0}` | Security context for the GPU operator toolkit validation init container |
| devicePlugin.hostNetwork | bool | `false` | Share the host network namespace with the device plugin pod |
| devicePlugin.hostPID | bool | `true` | Share the host PID namespace with the device plugin pod |
| devicePlugin.image.pullPolicy | string | `"IfNotPresent"` | Device plugin image pull policy |
| devicePlugin.image.pullSecrets | list | `[]` | Specify docker-registry secret names as an array |
| devicePlugin.image.registry | string | `"ghcr.io"` | Device plugin image registry |
| devicePlugin.image.repository | string | `"dynamia-ai/hami-enterprise"` | Device plugin image repository |
| devicePlugin.image.tag | string | `""` | Device plugin image tag (immutable tags are recommended) |
| devicePlugin.libPath | string | `"/usr/local/vgpu"` | Library path for vGPU |
| devicePlugin.migStrategy | string | `"none"` | MIG strategy. Supported values: `none`, `single`, `mixed` |
| devicePlugin.mofedEnabled | bool | `false` | Enable Mellanox OFED |
| devicePlugin.monitor.ctrPath | string | `"/usr/local/vgpu/containers"` | Container path for monitor |
| devicePlugin.monitor.extraArgs | list | `["-v=4"]` | Extra arguments for monitor |
| devicePlugin.monitor.extraEnvs | list | `[]` | Extra environment variables for monitor as a Kubernetes env list. |
| devicePlugin.monitor.image.pullPolicy | string | `"IfNotPresent"` | Monitor image pull policy |
| devicePlugin.monitor.image.pullSecrets | list | `[]` | Specify docker-registry secret names as an array |
| devicePlugin.monitor.image.registry | string | `"ghcr.io"` | Monitor image registry |
| devicePlugin.monitor.image.repository | string | `"dynamia-ai/hami-enterprise"` | Monitor image repository |
| devicePlugin.monitor.image.tag | string | `""` | Monitor image tag (immutable tags are recommended) |
| devicePlugin.monitor.resources | object | `{}` | Resources for monitor container |
| devicePlugin.monitor.resyncInterval | string | `"5m"` | Resync interval for monitor |
| devicePlugin.monitor.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":["SYS_ADMIN"],"drop":["ALL"]}}` | Security context for the monitor container |
| devicePlugin.nodeConfiguration.config | string | `"{\n  \"nodeconfig\": [\n    {\n      \"name\": \"your-node-name\",\n      \"operatingmode\": \"hami-core\",\n      \"devicememoryscaling\": 1,\n      \"devicesplitcount\": 10,\n      \"preconfigureddevicememory\": 0,\n      \"enablenumatopology\": false,\n      \"migstrategy\": \"none\",\n      \"filterdevices\": {\n        \"uuid\": [],\n        \"index\": []\n      },\n      \"enablegetpreferredallocation\": false\n    }\n  ]\n}\n"` | Node configuration for device plugin. If set, overrides the default config.json |
| devicePlugin.nodeConfiguration.externalConfigName | string | `""` | Name of an existing ConfigMap to use for node configuration |
| devicePlugin.numaRefit | object | `{"caFile":"","caSecret":"","enabled":false,"schedulerEndpoint":"","tlsInsecure":true}` | NUMA alignment refit configuration |
| devicePlugin.numaRefit.caFile | string | `""` | Path to a CA bundle already mounted in the device-plugin Pod |
| devicePlugin.numaRefit.caSecret | string | `""` | Secret containing ca.crt, mounted at /etc/hami/numa-refit-ca |
| devicePlugin.numaRefit.enabled | bool | `false` | Enable NUMA alignment refit |
| devicePlugin.numaRefit.schedulerEndpoint | string | `""` | Scheduler base URL override. Defaults to the in-cluster Scheduler service |
| devicePlugin.numaRefit.tlsInsecure | bool | `true` | Skip Scheduler TLS verification. Set false with caFile or caSecret to verify TLS |
| devicePlugin.nvidiaDriverRoot | string | `""` | NVIDIA driver root on the host, mounted into the device plugin and monitor containers |
| devicePlugin.nvidiaHookPath | string | `""` | Path for NVIDIA hook |
| devicePlugin.nvidiaNodeSelector | object | `{"gpu":"on"}` | Node selector for NVIDIA device plugin |
| devicePlugin.passDeviceSpecsEnabled | bool | `false` | Enable passing device specs |
| devicePlugin.pluginPath | string | `"/var/lib/kubelet/device-plugins"` | Path for device plugin socket |
| devicePlugin.podAnnotations | object | `{}` | Annotations for device plugin pod |
| devicePlugin.preConfiguredDeviceMemory | int | `0` | Pre-configured device memory in MB for GPUs that don't support memory query. Set to 0 for auto-detection |
| devicePlugin.resources | object | `{}` | Resources for device plugin container |
| devicePlugin.runtimeClassName | string | `""` | Runtime class name to be used by the device plugin |
| devicePlugin.securityContext | object | `{"allowPrivilegeEscalation":true,"capabilities":{"add":["SYS_ADMIN"],"drop":["ALL"]},"privileged":true}` | Security context for the device plugin container |
| devicePlugin.service.annotations | object | `{}` | Annotations for device plugin service |
| devicePlugin.service.httpPort | int | `31992` | HTTP port for device plugin service |
| devicePlugin.service.labels | object | `{}` | Labels for device plugin service |
| devicePlugin.service.type | string | `"NodePort"` | Service type for device plugin |
| devicePlugin.tolerations | list | `[{"effect":"NoSchedule","key":"nvidia.com/gpu","operator":"Exists"}]` | Tolerations for device plugin pod |
| devicePlugin.updateStrategy.rollingUpdate.maxUnavailable | int | `1` | Maximum unavailable pods during update |
| devicePlugin.updateStrategy.type | string | `"RollingUpdate"` | Update strategy for device plugin DaemonSet |
| devices.alibaba.customresources | list | `["alibaba.com/ppu","alibaba.com/ppu-memory","alibaba.com/gpu-core"]` | Custom resource definitions for Alibaba devices |
| devices.alibaba.enabled | bool | `true` | Enable Alibaba PPU device |
| devices.alibaba.ppuCorePolicy | string | `"default"` | PPU core policy for Alibaba devices |
| devices.amd.customresources | list | `["amd.com/gpu","amd.com/gpumem","amd.com/gpucores"]` | Custom resource definitions for AMD devices |
| devices.ascend.customresources | list | `["huawei.com/Ascend910A","huawei.com/Ascend910A-memory","huawei.com/Ascend910A-core","huawei.com/Ascend910B2","huawei.com/Ascend910B2-memory","huawei.com/Ascend910B2-core","huawei.com/Ascend910B3","huawei.com/Ascend910B3-memory","huawei.com/Ascend910B3-core","huawei.com/Ascend910B4","huawei.com/Ascend910B4-memory","huawei.com/Ascend910B4-core","huawei.com/Ascend910B4-1","huawei.com/Ascend910B4-1-memory","huawei.com/Ascend910B4-1-core","huawei.com/Ascend310P","huawei.com/Ascend310P-memory","huawei.com/Ascend310P-core","huawei.com/Ascend910C","huawei.com/Ascend910C-memory","huawei.com/Ascend910C-core"]` | Custom resource definitions for Ascend devices |
| devices.ascend.deviceCoreScaling | int | `1` | hami-core advertised percentage capacity multiplier; each workload still requests at most 100 percent. |
| devices.ascend.deviceSplitCount | int | `10` | Number of virtual devices advertised per physical Ascend NPU in soft-slicing mode. A positive node-level vDeviceCount overrides it. |
| devices.ascend.enabled | bool | `false` | Enable Ascend device plugin |
| devices.ascend.enpuPolicy | string | `"elastic"` | Default ENPU policy; enabling ENPU also requires compatible runtime assets on the node. |
| devices.ascend.extraArgs | list | `[]` | Extra arguments for Ascend device plugin |
| devices.ascend.hamiCorePolicy | string | `"spatial"` | Default hami-core runtime policy; Pod and node settings take precedence. Explicit enterprise force/disable controls remain effective. |
| devices.ascend.hamiVnpuCore | bool | `false` | Enable soft-partitioning based on hami-vnpu-core (node-level annotation takes higher priority) |
| devices.ascend.hamiVnpuMode | string | `""` | Backend: template, hami-core (alias hamiCore), or enpu. Empty preserves hamiVnpuCore compatibility. |
| devices.ascend.image | string | `""` | Ascend device plugin image |
| devices.ascend.imagePullPolicy | string | `"IfNotPresent"` | Image pull policy for Ascend device plugin |
| devices.ascend.nodeSelector | object | `{"ascend":"on"}` | Node selector for Ascend device plugin |
| devices.ascend.runtimeClassName | string | `""` | Runtime class name for Ascend NPU pods |
| devices.ascend.tolerations | list | `[]` | Tolerations for Ascend device plugin |
| devices.awsneuron.customresources | list | `["aws.amazon.com/neuron","aws.amazon.com/neuroncore"]` | Custom resource definitions for AWS Neuron devices |
| devices.biren.customresources | list | `["birentech.com/gpu"]` | Custom resource definitions for Biren devices |
| devices.biren.enabled | bool | `true` | Enable Biren device plugin |
| devices.enflame.customresources | list | `["enflame.com/drs-gcu","enflame.com/gcu-memory","enflame.com/gcu-core","enflame.com/gcu","enflame.com/vgcu","enflame.com/vgcu-percentage"]` | Custom resource definitions for Enflame devices |
| devices.enflame.enabled | bool | `true` | Enable Enflame device plugin |
| devices.iluvatar.customresources | list | `["iluvatar.ai/BI-V100-vgpu","iluvatar.ai/BI-V100.vCore","iluvatar.ai/BI-V100.vMem","iluvatar.ai/BI-V150-vgpu","iluvatar.ai/BI-V150.vCore","iluvatar.ai/BI-V150.vMem","iluvatar.ai/MR-V100-vgpu","iluvatar.ai/MR-V100.vCore","iluvatar.ai/MR-V100.vMem","iluvatar.ai/MR-V50-vgpu","iluvatar.ai/MR-V50.vCore","iluvatar.ai/MR-V50.vMem"]` | Custom resource definitions for Iluvatar devices |
| devices.iluvatar.enabled | bool | `false` | Enable Iluvatar device plugin |
| devices.kunlun.customresources | list | `["kunlunxin.com/xpu","kunlunxin.com/vxpu","kunlunxin.com/vxpu-memory"]` | Custom resource definitions for Kunlun devices |
| devices.kunlun.enabled | bool | `true` | Enable Kunlun device plugin |
| devices.mthreads.customresources | list | `["mthreads.com/vgpu"]` | Custom resource definitions for MThreads devices |
| devices.mthreads.enabled | bool | `true` | Enable MThreads device plugin |
| devices.nvidia.gpuCorePolicy | string | `"default"` | GPU core policy for NVIDIA devices |
| devices.nvidia.libCudaLogLevel | int | `2` | libCUDA log level |
| devices.vastai.customresources | list | `["vastaitech.com/va"]` | Custom resource definitions for Vastai devices |
| devices.vastai.enabled | bool | `true` | Enable Vastai device plugin |
| dra.enabled | bool | `false` | Enable DRA (Dynamic Resource Allocation) |
| enflameResourceNameDRSGCU | string | `"enflame.com/drs-gcu"` | Enflame DRS GCU resource name |
| enflameResourceNameGCUCore | string | `"enflame.com/gcu-core"` | Enflame GCU core resource name |
| enflameResourceNameGCUMemory | string | `"enflame.com/gcu-memory"` | Enflame GCU memory resource name |
| enflameResourceNameVGCU | string | `"enflame.com/vgcu"` | Enflame VGCU resource name |
| enflameResourceNameVGCUPercentage | string | `"enflame.com/vgcu-percentage"` | Enflame VGCU percentage resource name |
| fullnameOverride | string | `""` | Override the fullname of the chart |
| global.annotations | object | `{}` | Global annotations to add to all resources |
| global.gpuHookPath | string | `"/usr/local"` | Path for GPU hook installation on nodes |
| global.imagePullSecrets | list | `[]` | Global Docker image pull secrets |
| global.imageRegistry | string | `""` | Global Docker image registry |
| global.imageTag | string | `"v2.10.0-r5"` | Global image tag for HAMi Enterprise components |
| global.labels | object | `{}` | Global labels to add to all resources |
| global.managedNodeSelector | object | `{"usage":"gpu"}` | Node selector configuration for managed GPU nodes |
| global.managedNodeSelectorEnable | bool | `false` | Enable managed node selector for GPU nodes |
| hami-dra.drivers.nvidia.containerDriver | bool | `true` | Enable container driver for NVIDIA DRA |
| hami-dra.drivers.nvidia.enabled | bool | `true` | Enable NVIDIA DRA driver |
| hami-dra.drivers.nvidia.image.repository | string | `"ghcr.io/project-hami/k8s-dra-driver"` | NVIDIA DRA driver image repository |
| hami-dra.drivers.nvidia.image.tag | string | `"main"` | NVIDIA DRA driver image tag |
| hami-dra.monitor.enabled | bool | `true` | Enable monitor for hami-dra |
| hcuResourceCores | string | `"hygon.com/hcucores"` | Hygon HCU cores resource name |
| hcuResourceMem | string | `"hygon.com/hcumem"` | Hygon HCU memory resource name |
| hcuResourceName | string | `"hygon.com/hcunum"` | Hygon HCU resource name |
| kunlunResourceName | string | `"kunlunxin.com/xpu"` | Kunlun XPU resource name |
| kunlunResourceVCountName | string | `"kunlunxin.com/vxpu"` | Kunlun virtual XPU count resource name |
| kunlunResourceVMemoryName | string | `"kunlunxin.com/vxpu-memory"` | Kunlun virtual XPU memory resource name |
| legacyMetrics | bool | `false` | Enable legacy metrics |
| legacySelectorLabels | bool | `false` | Keep historical hami/hami scheduler and NVIDIA device-plugin selector labels. Enable when upgrading an existing Enterprise release and keep enabled on subsequent upgrades. |
| metaxResourceCore | string | `"metax-tech.com/vcore"` | Metax sGPU core resource name |
| metaxResourceMem | string | `"metax-tech.com/vmemory"` | Metax sGPU memory resource name |
| metaxResourceName | string | `"metax-tech.com/sgpu"` | Metax sGPU resource name |
| metaxsGPUTopologyAware | string | `"false"` | Enable Metax sGPU topology awareness |
| mluResourceCores | string | `"cambricon.com/mlu.smlu.vcore"` | MLU cores resource name |
| mluResourceMem | string | `"cambricon.com/mlu.smlu.vmemory"` | MLU memory resource name |
| mluResourceName | string | `"cambricon.com/vmlu"` | MLU resource name |
| mockDevicePlugin.enabled | bool | `false` | Enable mock device plugin |
| mockDevicePlugin.image.pullPolicy | string | `"IfNotPresent"` | Mock device plugin image pull policy |
| mockDevicePlugin.image.pullSecrets | list | `[]` | Specify docker-registry secret names as an array |
| mockDevicePlugin.image.registry | string | `"docker.io"` | Mock device plugin image registry |
| mockDevicePlugin.image.repository | string | `"projecthami/mock-device-plugin"` | Mock device plugin image repository |
| mockDevicePlugin.image.tag | string | `"1.0.1"` | Mock device plugin image tag |
| nameOverride | string | `""` | Override the chart name |
| namespaceOverride | string | `""` | Override the namespace |
| openshift.securityContextConstraints.create | bool | `true` | Create the named device-plugin SCC and its use ClusterRole when OpenShift support is enabled. Set this to false only when both the SCC and `system:openshift:scc:<name>` ClusterRole already exist, such as for the built-in `privileged` SCC. |
| openshift.securityContextConstraints.name | string | `"hami-device-plugin"` | SCC granted to enabled device-plugin service accounts. When `create=false`, the matching `system:openshift:scc:<name>` ClusterRole must already exist. The built-in `privileged` SCC requires `create=false`. |
| platform.openshift | bool | `false` | Enable OpenShift-specific resources and handling |
| platform.openshiftVersion | string | `""` | OpenShift version used to resolve the Red Hat OpenShift hyperkube image tag when `platform.openshift=true` and `scheduler.kubeScheduler.image.tag` is empty |
| podSecurityPolicy.enabled | bool | `false` | Enable PodSecurityPolicy |
| prometheus.enabled | bool | `false` | Enable Prometheus metrics |
| resourceCores | string | `"nvidia.com/gpucores"` | NVIDIA GPU cores resource name |
| resourceMem | string | `"nvidia.com/gpumem"` | NVIDIA GPU memory resource name |
| resourceMemPercentage | string | `"nvidia.com/gpumem-percentage"` | NVIDIA GPU memory percentage resource name |
| resourceName | string | `"nvidia.com/gpu"` | NVIDIA GPU resource name |
| resourcePriority | string | `"nvidia.com/priority"` | NVIDIA GPU priority resource name |
| scheduler.admissionWebhook.customURL.enabled | bool | `false` | Enable custom webhook URL |
| scheduler.admissionWebhook.customURL.host | string | `"127.0.0.1"` | Webhook host (must be an endpoint using https) |
| scheduler.admissionWebhook.customURL.path | string | `"/webhook"` | Webhook path |
| scheduler.admissionWebhook.customURL.port | int | `31998` | Webhook port |
| scheduler.admissionWebhook.enabled | bool | `true` | Enable admission webhook. If disabled, pods must be configured with correct schedulerName manually |
| scheduler.admissionWebhook.failurePolicy | string | `"Ignore"` | Failure policy for webhook |
| scheduler.admissionWebhook.manageNamespaceSelector | bool | `true` | Whether the chart renders and manages the webhook's namespaceSelector field |
| scheduler.admissionWebhook.namespaceSelector | object | `{"matchExpressions":[],"matchLabels":{}}` | Namespace selector for webhook |
| scheduler.admissionWebhook.objectSelector | object | `{"matchExpressions":[]}` | Object selector for webhook |
| scheduler.admissionWebhook.reinvocationPolicy | string | `"Never"` | Reinvocation policy for webhook |
| scheduler.admissionWebhook.whitelistNamespaces | list | `[]` | Namespaces that the webhook will not be applied to |
| scheduler.certManager.enabled | bool | `false` | Enable cert-manager for TLS certificate generation |
| scheduler.defaultSchedulerPolicy.gpuSchedulerPolicy | string | `"spread"` | GPU-level scheduling policy. Supported values: `binpack`, `spread` |
| scheduler.defaultSchedulerPolicy.nodeSchedulerPolicy | string | `"binpack"` | Node-level scheduling policy. Supported values: `binpack`, `spread` |
| scheduler.extender.extraArgs | list | `["--debug","-v=4"]` | Extra arguments for scheduler extender |
| scheduler.extender.image.pullPolicy | string | `"IfNotPresent"` | Scheduler extender image pull policy |
| scheduler.extender.image.pullSecrets | list | `[]` | Specify docker-registry secret names as an array |
| scheduler.extender.image.registry | string | `"ghcr.io"` | Scheduler extender image registry |
| scheduler.extender.image.repository | string | `"dynamia-ai/hami-enterprise"` | Scheduler extender image repository |
| scheduler.extender.image.tag | string | `""` | Scheduler extender image tag (immutable tags are recommended) |
| scheduler.extender.resources | object | `{}` | Resources for scheduler extender container |
| scheduler.forceOverwriteDefaultScheduler | bool | `true` | Force overwrite the default scheduler name in pods when it equals the K8s default scheduler name |
| scheduler.kubeScheduler.enabled | bool | `true` | Whether to run kube-scheduler container in the scheduler pod |
| scheduler.kubeScheduler.extraArgs | list | `["--policy-config-file=/config/config.json","-v=4"]` | Extra arguments for kube-scheduler (legacy config format) |
| scheduler.kubeScheduler.extraNewArgs | list | `["--config=/config/config.yaml","-v=4"]` | Extra arguments for kube-scheduler (new config format) |
| scheduler.kubeScheduler.image.pullPolicy | string | `"IfNotPresent"` | kube-scheduler image pull policy |
| scheduler.kubeScheduler.image.pullSecrets | list | `[]` | Specify docker-registry secret names as an array |
| scheduler.kubeScheduler.image.registry | string | `"registry.cn-hangzhou.aliyuncs.com"` | kube-scheduler image registry |
| scheduler.kubeScheduler.image.repository | string | `"google_containers/kube-scheduler"` | kube-scheduler image repository |
| scheduler.kubeScheduler.image.tag | string | `""` | kube-scheduler image tag (immutable tags are recommended) |
| scheduler.kubeScheduler.resources | object | `{}` | Resources for kube-scheduler container |
| scheduler.leaderElect | bool | `true` | Enable leader election for scheduler |
| scheduler.livenessProbe | bool | `false` | Enable liveness probe for scheduler |
| scheduler.metricsBindAddress | string | `":9395"` | Address to bind metrics server |
| scheduler.nodeLockExpire | string | `"5m"` | Node lock expiration time |
| scheduler.nodeName | string | `""` | Node name for scheduler pod. If installing as default scheduler, set this to skip the schedule workflow |
| scheduler.overwriteEnv | string | `"false"` | Overwrite environment variables |
| scheduler.patch.enabled | bool | `true` | Enable kube-webhook-certgen patch job |
| scheduler.patch.image.pullPolicy | string | `"IfNotPresent"` | kube-webhook-certgen image pull policy |
| scheduler.patch.image.pullSecrets | list | `[]` | Specify docker-registry secret names as an array |
| scheduler.patch.image.registry | string | `"docker.io"` | kube-webhook-certgen image registry |
| scheduler.patch.image.repository | string | `"jettech/kube-webhook-certgen"` | kube-webhook-certgen image repository |
| scheduler.patch.image.tag | string | `"v1.5.2"` | kube-webhook-certgen image tag |
| scheduler.patch.imageNew.pullPolicy | string | `"IfNotPresent"` | Kubernetes 1.22+ kube-webhook-certgen image pull policy |
| scheduler.patch.imageNew.pullSecrets | list | `[]` | Specify docker-registry secret names as an array |
| scheduler.patch.imageNew.registry | string | `"registry.k8s.io"` | Kubernetes 1.22+ kube-webhook-certgen image registry |
| scheduler.patch.imageNew.repository | string | `"ingress-nginx/kube-webhook-certgen"` | Kubernetes 1.22+ kube-webhook-certgen image repository |
| scheduler.patch.imageNew.tag | string | `"v1.6.9"` | Kubernetes 1.22+ kube-webhook-certgen image tag |
| scheduler.patch.nodeSelector | object | `{}` | Node selector for patch job |
| scheduler.patch.podAnnotations | object | `{}` | Annotations for patch job pod |
| scheduler.patch.priorityClassName | string | `""` | Priority class name for patch job |
| scheduler.patch.runAsUser | int | `2000` | User ID to run patch job as. OpenShift omits this value at render time so its SCC can allocate an allowed UID |
| scheduler.patch.tolerations | list | `[]` | Tolerations for patch job |
| scheduler.podAnnotations | object | `{}` | Annotations for scheduler pod |
| scheduler.replicas | int | `1` | Number of scheduler replicas (only effective when leaderElect is true) |
| scheduler.service.annotations | object | `{}` | Annotations for scheduler service |
| scheduler.service.httpPort | int | `443` | HTTP port for scheduler service |
| scheduler.service.httpTargetPort | int | `9443` | Target port on which the scheduler extender listens |
| scheduler.service.labels | object | `{}` | Labels for scheduler service |
| scheduler.service.monitorPort | int | `31993` | Monitoring port for scheduler service |
| scheduler.service.monitorTargetPort | int | `9395` | Target port for monitoring |
| scheduler.service.schedulerPort | int | `31998` | NodePort for scheduler HTTP |
| scheduler.service.type | string | `"NodePort"` | Service type for scheduler |
| scheduler.tolerations | list | `[]` | Tolerations for scheduler pod |
| scheduler.useDownward | bool | `true` | Whether to enable useDownward in the generated scheduler device config for NVIDIA devices |
| schedulerName | string | `"hami-scheduler"` | Name of the scheduler |
| selinux.enabled | bool | `false` | Relabel shared vGPU host directories on SELinux-enabled Kubernetes nodes |
| selinux.level | string | `"s0"` | SELinux level applied to shared vGPU host directories |
| selinux.type | string | `"container_file_t"` | SELinux type applied to shared vGPU host directories |
| vastaiResourceName | string | `"vastaitech.com/va"` | Vastai resource name |
