# Upgrading HAMi Enterprise

## Upstream 2.11 configuration migration (unreleased)

This branch adopts the upstream breaking migration. Export the previous release's
values, move vendor settings to `devices.<vendor>`, and remove the old keys before
upgrading. Do not use `--reuse-values`: old and new keys together are rejected too.
The release and image versions in this branch remain `2.10.0-r5` until a separately
validated release is prepared; do not deploy this source with old images.

| Old values | New values |
| --- | --- |
| `resourceName`, `resourceMem`, `resourceMemPercentage`, `resourceCores`, `resourcePriority` | `devices.nvidia.resourceCountName`, `resourceMemoryName`, `resourceMemoryPercentageName`, `resourceCoreName`, `resourcePriorityName` |
| `nvidia.*` | `devices.nvidia.*` |
| `ascend.*`, `iluvatar.*`, `hygon.*`, `cambricon.*`, other vendor sections | Corresponding `devices.<vendor>.*` section |
| `mluResourceName`, `mluResourceMem`, `mluResourceCores` | `devices.cambricon.resourceCountName`, `resourceMemoryName`, `resourceCoreName` |
| `dcuResourceName`, `dcuResourceMem`, `dcuResourceCores` | `devices.hygon.resourceCountName`, `resourceMemoryName`, `resourceCoreName` |

The chart's `validateValues` helper is the complete list of removed fields and
replacement paths. The embedded `device-config.content` YAML remains a backend
configuration, not Helm values; its root keys remain `nvidia`, `vnpus`, etc. A
standalone resource-pool manager must consume the same rendered device config.
Its installation remains independent of the main chart.

Render the migrated values with `helm template` and inspect the resulting device
ConfigMap, resource names, selectors, image references, and scheduler endpoints.
Retain `legacySelectorLabels: true` for installations using the original fixed
`hami`/`hami` controller selectors. Preserve existing webhook CA/Secret ownership
and follow the standalone manager maintenance-window instructions below.

The extender now serves `/filter` and `/bind` on the loopback listener (default
`127.0.0.1:9444`); webhook, metrics, enterprise `/vnpu/validate`, and authenticated
`/refit` use the cluster listener. An external kube-scheduler needs a separately
reviewed connectivity arrangement; changing the cluster-facing Service alone
does not expose `/filter` or `/bind`.

HAMi-core is unchanged. Keep `devices.nvidia.limitDelivery: env` and
`devicePlugin.monitor.disableHAMiCoreForWholeGPU: false` for the supported default
combination. File-based limits and whole-GPU hook bypass require separate core
compatibility validation before enabling them. Enterprise Downward, licensing,
metric labels, and whole-card defaults for Iluvatar/Hygon are preserved.
Allocation annotation writer authorization is deliberately omitted, so external
controllers such as Kantaloupe retain their existing update path. Independent
resource-pool admission checks and `/refit` authentication still apply.

On Kubernetes 1.30 and newer, the chart also installs an independent, fail-closed
`/downward/validate` webhook. It validates NVIDIA Downward runtime limits against
the container requests, including init containers, indexed limits, and
percentage requests resolved against the assigned node inventory. This does not
add allocation-writer authorization: external controllers may still write
allocations within the container requests. MIG keeps its profile-aware plugin
validation. The webhook shares the existing admission TLS Secret and CA patch
job. Custom manifests must wire this validating endpoint as well as `/webhook`.
On older clusters this additional validation is not installed; use the
non-Downward allocation path when this resource-bound check is required.

Enabling `devicePlugin.numaRefit` now requires a scheduler CA bundle through
`caFile` or a `caSecret` containing `ca.crt`. Keep `tlsInsecure: false`: the refit
client transmits a ServiceAccount token and rejects insecure TLS. The chart
reports missing CA configuration or insecure mode during rendering.

The default Enterprise E2E profile exercises environment delivery. File-delivery
cases require an explicitly validated HAMi-core, `scheduler.useDownward=false`,
and `devices.nvidia.limitDelivery=file`; enable them with
`HAMI_E2E_LIMITS_FILE=true` when running `make e2e-test`. Those cases are skipped
in the default profile because Enterprise Downward allocation does not mount a
limits file. The environment-delivery and basic CUDA cases still run.


## Three independent chart releases

`charts/hami` installs HAMi scheduler and device plugins. Resource-pool CRDs
are installed by `charts/hami-enterprise-crds`, and resource-pool controllers,
webhooks, and certificates are installed by `charts/hami-resource-pool-manager`.
The main chart no longer accepts `resourcePoolManager.*` as an installation
switch and does not render any resource-pool runtime resources.

See the [standalone manager guide](../hami-resource-pool-manager/README.md) for
installation values, device-config sharing, TLS, and the maintenance-window
handoff from an embedded manager. Do not install both sets of pool webhooks
at once. Existing open-source HAMi installations can retain their own release;
the manager takes explicit scheduler configuration and identities.

## Upgrade or enable physical HAMi device resource pools

The `hami-enterprise` chart no longer contains the `GPUDevice`, `ResourcePool`,
or `ResourcePoolBinding` CustomResourceDefinitions. Install the independent
`hami-enterprise-crds` chart before installing `hami-resource-pool-manager`, and upgrade
it when the compatibility table requires a newer CRD schema.

The CRD chart version evolves independently from the main chart. Its
`appVersion` identifies the HAMi Enterprise API snapshot used to generate the
CRDs. Select versions from the compatibility table rather than matching version
numbers:

| CRD chart version | CRD chart `appVersion` | `hami-enterprise` chart |
| --- | --- | --- |
| `0.4.0` | `0.4.0` | `2.10.0-r1` |
| `0.3.0` | `0.3.0` | `2.10.0-r1` |
| `0.2.0` | `0.2.0` | `2.10.0-r1` |

Ascend resource pools require CRD chart `0.4.0`. The `0.2.0` and `0.3.0`
schemas accept only NVIDIA device identities; they cannot be used for Ascend
resource pools even though they share the same main-chart version.

```bash
helm upgrade --install hami-enterprise-crds \
  oci://ghcr.io/dynamia-ai/charts/hami-enterprise-crds \
  --version 0.4.0 \
  --namespace hami-system \
  --create-namespace

kubectl wait --for=condition=Established --timeout=60s \
  crd/gpudevices.resource.hami.io \
  crd/resourcepools.resource.hami.io \
  crd/resourcepoolbindings.resource.hami.io
```

Then install or upgrade the standalone manager using its own runtime version.
The manager in this branch requires CRD schema `0.4.0` or newer.

### Adopt CRDs installed by an older main chart

Existing CRDs and custom resources must not be deleted. Before the first
standalone chart installation, verify that every CRD is either unowned or
already owned by the intended standalone release. Stop if any other Helm owner
is present; do not overwrite ownership until the other release has been
investigated:

```bash
for crd in \
  gpudevices.resource.hami.io \
  resourcepools.resource.hami.io \
  resourcepoolbindings.resource.hami.io; do
  if ! ownership=$(kubectl get crd "${crd}" -o \
    'jsonpath={.metadata.labels.app\.kubernetes\.io/managed-by}{"|"}{.metadata.annotations.meta\.helm\.sh/release-name}{"|"}{.metadata.annotations.meta\.helm\.sh/release-namespace}'); then
    echo "Unable to verify ownership of ${crd}; no CRD metadata was changed" >&2
    exit 1
  fi

  case "${ownership}" in
    "||"|"Helm|hami-enterprise-crds|hami-system") ;;
    *)
      echo "Refusing to take ownership of ${crd}: ${ownership}" >&2
      exit 1
      ;;
  esac
done

for crd in \
  gpudevices.resource.hami.io \
  resourcepools.resource.hami.io \
  resourcepoolbindings.resource.hami.io; do
  kubectl label crd "${crd}" app.kubernetes.io/managed-by=Helm --overwrite
  kubectl annotate crd "${crd}" \
    meta.helm.sh/release-name=hami-enterprise-crds \
    meta.helm.sh/release-namespace=hami-system \
    --overwrite
done
```

The first loop completes before any metadata changes, so an unexpected owner
does not cause a partial takeover. Run the standalone `helm upgrade --install`
command after all three metadata updates succeed. Helm will adopt the CRDs and
update their schemas from `templates/`. Each CRD has
`helm.sh/resource-policy: keep`, so uninstalling the standalone release keeps
the CRDs and all existing custom resources.

Verify that the API server exposes fields required by the target manager before
upgrading the manager release:

```bash
kubectl explain resourcepool.spec.workloadDefaults.schedulingPolicy \
  --api-version=resource.hami.io/v1alpha1
kubectl explain resourcepool.spec.displayName \
  --api-version=resource.hami.io/v1alpha1
```

The output must include `node`, `gpu`, and `displayName`. If adoption, chart upgrade, CRD
establishment, or schema verification fails, do not upgrade the
`resource-pool-manager` deployment. Correct the CRD installation first; an older
structural schema can prune or reject fields written by the upgraded manager.

## Ascend VNPU split count and upstream HAMi synchronization

`devices.ascend.deviceSplitCount` defaults to `10` and is rendered as
`vnpus.deviceSplitCount` in the scheduler device ConfigMap. In soft-slicing
mode, a matching Ascend device plugin reports that many virtual-device slots
per physical NPU. A positive node-level `vDeviceCount` takes precedence; hard
slicing continues to calculate capacity from its templates.

### Synchronization boundary and ownership

The shared field follows the upstream contract merged in
[HAMi #3267](https://github.com/Project-HAMi/HAMi/pull/3267) and
[ascend-device-plugin #144](https://github.com/Project-HAMi/ascend-device-plugin/pull/144).
Keep the same field name when synchronizing upstream HAMi. The enterprise
plugin supports hami-core and template slicing; ENPU is an optional separate
backend that requires its compatible runtime assets and device prerequisites.

The chart patch consists of the value and default in `values.yaml`, positive
integer validation in `values.schema.json`, and the field under `vnpus` in
`templates/scheduler/device-configmap.yaml`. Regenerate `README.md` from the
values comments after replaying these changes. Keep this maintenance guide
with the enterprise chart when importing upstream files.

Also retain `hack/verify-ascend-device-config.sh` and its Chart Lint workflow
invocation. The check models `--reuse-values` from a release that predates this
option; the template must still render the integer default `10`.

The companion plugin must parse `vnpus.deviceSplitCount` and use the same
effective count for kubelet device IDs and HAMi registration `DeviceInfo.Count`.
See [ascend-device-plugin #19](https://github.com/dynamia-ai/ascend-device-plugin/pull/19)
for the original capacity implementation. Release the synchronized chart with
a plugin image that consumes the new field.
The scheduler consumes the registered count through its existing allocation
checks; the scheduler config type retains the field so configuration decoding
stays aligned with upstream.

### Revalidation after synchronization

Before accepting an upstream synchronization:

- Render the chart with the default `10` and a nondefault value such as `5`.
  Check the field at `vnpus.deviceSplitCount`; confirm the schema still
  rejects zero, negative, and noninteger values.
- On a soft-slicing node with the matching plugin, check that per-card
  registration counts agree with kubelet capacity. For two cards and count
  `5`, expect per-card Count `5` and total capacity `10`.
- Constrain small, single-slot Pods to one card: five should run, the sixth
  should wait with `CardTimeSlicingExhausted`, and releasing a slot should let
  the waiting Pod run and execute an NPU workload. Keep other resource limits
  from exhausting first. Confirm node-level `vDeviceCount` precedence and
  restore the original configuration after the test.
- Revalidate hard-slicing template capacity on a suitable test node, and check
  any upstream changes to the plugin configuration or device-count protocol
  before replaying the patch.

Retire the enterprise patch only after the upstream chart and plugin provide
an equivalent contract and these checks pass against the adopted versions.
