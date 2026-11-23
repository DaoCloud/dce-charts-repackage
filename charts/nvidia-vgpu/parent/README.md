# Nvidia vgpu

All parameters below are under `hami` in the wrapper chart, for example
`--set hami.devices.nvidia.deviceSplitCount=10`.

HAMi 2.11 rejects the old resource and scaling paths. Migrate existing overrides
to the paths below before upgrading. The main chart no longer bundles HAMi-DRA.
Webhook certificate images now use `hami.scheduler.patch.imageNew` only.

You can customize your vGPU support by setting the following parameters using `--set`, for example

* `devices.nvidia.deviceMemoryScaling:`
Float type, by default: 1. The ratio for NVIDIA device memory scaling, can be greater than 1 (enable virtual device memory, experimental feature). For NVIDIA GPU with *M* memory, if we set `devices.nvidia.deviceMemoryScaling` argument to *S*, vGPUs splitted by this GPU will totally get `S * M` memory in Kubernetes with our device plugin.
* `devices.nvidia.deviceCoreScaling:`
  Float type, by default: 1. The ratio for NVIDIA device cores scaling, can be greater than 1 (enable virtual device cores, experimental feature). For NVIDIA GPU with *M* cores, if we set `devices.nvidia.deviceCoreScaling` argument to *S*, vGPUs splitted by this GPU will totally get `S * M` cores in Kubernetes with our device plugin.
* `devices.nvidia.deviceSplitCount:`
Integer type, by default: equals 10. Maximum tasks assigned to a simple GPU device.
* `devicePlugin.migStrategy:`
String type, "none" for ignoring MIG features or "mixed" for allocating MIG device by seperate resources. Default "none"
* `devicePlugin.disablecorelimit:`
String type, "true" for disable core limit, "false" for enable core limit, default: false
* `devices.nvidia.defaultMem:`
Integer type, by default: 0. The default device memory of the current task, in MB
* `devices.nvidia.defaultCores:`
Integer type, by default: equals 0. Percentage of GPU cores reserved for the current task. If assigned to 0, it may fit in any GPU with enough device memory. If assigned to 100, it will use an entire GPU card exclusively.
* `devices.nvidia.resourceCountName:`
String type, vgpu number resource name, default: "nvidia.com/vgpu"
* `devices.nvidia.resourceMemoryName:`
String type, vgpu memory size resource name, default: "nvidia.com/gpumem"
* `devices.nvidia.resourceMemoryPercentageName:`
String type, vgpu memory fraction resource name, default: "nvidia.com/gpumem-percentage"
* `devices.nvidia.resourceCoreName:`
String type, vgpu cores resource name, default: "nvidia.com/gpucores"
* `devices.nvidia.resourcePriorityName:`
String type, vgpu task priority name, default: "nvidia.com/priority"
