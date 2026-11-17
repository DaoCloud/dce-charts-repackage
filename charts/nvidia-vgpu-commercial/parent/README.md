# NVIDIA vGPU Commercial

The chart wraps HAMi Enterprise. Use the `hami.` prefix for its Helm values. DCE exposes the NVIDIA vGPU count as
`nvidia.com/vgpu` via `hami.devices.nvidia.resourceCountName`.

## Upgrade to 2.11.0-r0

1. Export the release's existing user values with `helm get values <release> -n <namespace> -o yaml`.
2. Move retained vendor settings under `hami.devices.<vendor>`. In particular, move the NVIDIA resource count name
   to `hami.devices.nvidia.resourceCountName` and the device split count, memory scaling and core scaling to
   `hami.devices.nvidia`. Remove `hami.dra` and `hami.hami-dra` entirely. Retain `hami.legacySelectorLabels: true`
   for deployments using the historical fixed selectors.
3. Review the migrated values with `helm template`, then apply them with
   `helm upgrade <release> <chart> -n <namespace> --reset-values -f migrated-values.yaml`.
   For a custom `hami.device-config.content`, migrate that document separately and verify that the NVIDIA
   allocation mode matches the existing deployment.
4. Roll affected workloads to pick up changes to the runtime library or injected environment variables.

The bundled scheduler selects a Kubernetes-compatible image by default. The offline bundle covers Kubernetes
1.18–1.35. Remove the old `hami.scheduler.kubeScheduler.image.tag: v1.28.0` override to use automatic selection,
or set a tag compatible with the target cluster and make that image available to it.

Lupine remote GPU is disabled by default. To enable it in an offline cluster, mirror the upstream
digest-pinned server and client images separately, then set `hami.devices.remotegpu.server.image`
and `hami.devices.remotegpu.clientImage` to the mirrored references.

For Ascend, enable `hami.devices.ascend.enabled` and deploy the compatible Dynamia `ascend-device-plugin` chart
separately. Before migrating workloads, check that the plugin pods are Ready, the expected device resources are
Allocatable on the target nodes, and a test workload can request those resources.

See the [Dynamia release notes](https://docs.dynamia.ai/zh/changelog/hami-enterprise/2.11.0-r0) for migration
details, Kubernetes requirements, and the enterprise defaults.
