<!--- app-name: Contour -->

# Contour packaged by Bitnami

Contour is an open source Kubernetes ingress controller that works by deploying the Envoy proxy as a reverse proxy and load balancer.

[Overview of Contour](https://github.com/projectcontour/contour)

Trademarks: This software listing is packaged by Bitnami. The respective trademarks mentioned in the offering are owned by the respective companies, and use of them does not imply any affiliation or endorsement.

## TL;DR

```console
helm install my-release oci://registry-1.docker.io/bitnamicharts/contour
```

## Introduction

Bitnami charts for Helm are carefully engineered, actively maintained and are the quickest and easiest way to deploy containers on a Kubernetes cluster that are ready to handle production workloads.

This chart bootstraps a [Contour](https://projectcontour.io) Ingress Controller Deployment and a [Envoy Proxy](https://www.envoyproxy.io) Daemonset on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

Bitnami charts can be used with [Kubeapps](https://kubeapps.dev/) for deployment and management of Helm Charts in clusters.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- An Operator for `ServiceType: LoadBalancer` like [MetalLB](https://github.com/bitnami/charts/tree/main/bitnami/metallb)

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm install my-release oci://registry-1.docker.io/bitnamicharts/contour
```

These commands deploy contour on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list` or `helm ls --all-namespaces`

## Uninstalling the Chart

:warning: Uninstalling this chart will also remove CRDs. Removing CRDs will **remove all instances of it's Custom Resources**. If you wish to retain your Custom Resources for the future, run the following commands before uninstalling.

```console
kubectl get -o yaml extensionservice,httpproxy,tlscertificatedelegation -A > backup.yaml
```

To uninstall/delete the `my-release` helm release:

```console
helm uninstall my-release
```

## Parameters

### Global parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `global.imageRegistry`    | Global Docker image registry                    | `""`  |
| `global.imagePullSecrets` | Global Docker registry secret names as an array | `[]`  |
| `global.storageClass`     | Global StorageClass for Persistent Volume(s)    | `""`  |

### Common parameters

| Name                     | Description                                                                             | Value   |
| ------------------------ | --------------------------------------------------------------------------------------- | ------- |
| `nameOverride`           | String to partially override contour.fullname include (will maintain the release name)  | `""`    |
| `fullnameOverride`       | String to fully override contour.fullname template                                      | `""`    |
| `namespaceOverride`      | String to fully override common.names.namespace                                         | `""`    |
| `kubeVersion`            | Force target Kubernetes version (using Helm capabilities if not set)                    | `""`    |
| `extraDeploy`            | Array of extra objects to deploy with the release                                       | `[]`    |
| `commonLabels`           | Labels to add to all deployed objects                                                   | `{}`    |
| `commonAnnotations`      | Annotations to add to all deployed objects                                              | `{}`    |
| `diagnosticMode.enabled` | Enable diagnostic mode (all probes will be disabled and the command will be overridden) | `false` |
| `diagnosticMode.command` | Command to override all containers in the deployment                                    | `[]`    |
| `diagnosticMode.args`    | Args to override all containers in the deployment                                       | `[]`    |

### Contour parameters

| Name                                                          | Description                                                                                                                        | Value                 |
| ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | --------------------- |
| `existingConfigMap`                                           | Specifies the name of an externally-defined ConfigMap to use as the configuration (this is mutually exclusive with `configInline`) | `""`                  |
| `configInline`                                                | Specifies Contour's configuration directly in YAML format                                                                          | `{}`                  |
| `contour.enabled`                                             | Contour Deployment creation.                                                                                                       | `true`                |
| `contour.image.registry`                                      | Contour image registry                                                                                                             | `docker.io`           |
| `contour.image.repository`                                    | Contour image name                                                                                                                 | `bitnami/contour`     |
| `contour.image.tag`                                           | Contour image tag                                                                                                                  | `1.25.0-debian-11-r0` |
| `contour.image.digest`                                        | Contour image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag                            | `""`                  |
| `contour.image.pullPolicy`                                    | Contour Image pull policy                                                                                                          | `IfNotPresent`        |
| `contour.image.pullSecrets`                                   | Contour Image pull secrets                                                                                                         | `[]`                  |
| `contour.image.debug`                                         | Enable image debug mode                                                                                                            | `false`               |
| `contour.replicaCount`                                        | Number of Contour Pod replicas                                                                                                     | `1`                   |
| `contour.priorityClassName`                                   | Priority class assigned to the pods                                                                                                | `""`                  |
| `contour.schedulerName`                                       | Name of the k8s scheduler (other than default)                                                                                     | `""`                  |
| `contour.terminationGracePeriodSeconds`                       | In seconds, time the given to the Contour pod needs to terminate gracefully                                                        | `""`                  |
| `contour.topologySpreadConstraints`                           | Topology Spread Constraints for pod assignment                                                                                     | `[]`                  |
| `contour.containerPorts.xds`                                  | Set xds port inside Contour pod                                                                                                    | `8001`                |
| `contour.containerPorts.metrics`                              | Set metrics port inside Contour pod                                                                                                | `8000`                |
| `contour.hostAliases`                                         | Add deployment host aliases                                                                                                        | `[]`                  |
| `contour.updateStrategy`                                      | Strategy to use to update Pods                                                                                                     | `{}`                  |
| `contour.extraArgs`                                           | Extra arguments passed to Contour container                                                                                        | `[]`                  |
| `contour.resources.limits`                                    | Specify resource limits which the container is not allowed to succeed.                                                             | `{}`                  |
| `contour.resources.requests`                                  | Specify resource requests which the container needs to spawn.                                                                      | `{}`                  |
| `contour.manageCRDs`                                          | Manage the creation, upgrade and deletion of Contour CRDs.                                                                         | `true`                |
| `contour.envoyServiceNamespace`                               | Namespace of the envoy service to inspect for Ingress status details.                                                              | `""`                  |
| `contour.envoyServiceName`                                    | Name of the envoy service to inspect for Ingress status details.                                                                   | `""`                  |
| `contour.leaderElectionResourceName`                          | Name of the contour (Lease) leader election will lease.                                                                            | `""`                  |
| `contour.ingressStatusAddress`                                | Address to set in Ingress object status. It is exclusive with `envoyServiceName` and `envoyServiceNamespace`.                      | `""`                  |
| `contour.podAffinityPreset`                                   | Contour Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                        | `""`                  |
| `contour.podAntiAffinityPreset`                               | Contour Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                   | `soft`                |
| `contour.podLabels`                                           | Extra labels for Contour pods                                                                                                      | `{}`                  |
| `contour.lifecycleHooks`                                      | lifecycleHooks for the container to automate configuration before or after startup.                                                | `{}`                  |
| `contour.customLivenessProbe`                                 | Override default liveness probe                                                                                                    | `{}`                  |
| `contour.customReadinessProbe`                                | Override default readiness probe                                                                                                   | `{}`                  |
| `contour.customStartupProbe`                                  | Override default startup probe                                                                                                     | `{}`                  |
| `contour.nodeAffinityPreset.type`                             | Contour Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                  | `""`                  |
| `contour.nodeAffinityPreset.key`                              | Contour Node label key to match Ignored if `affinity` is set.                                                                      | `""`                  |
| `contour.nodeAffinityPreset.values`                           | Contour Node label values to match. Ignored if `affinity` is set.                                                                  | `[]`                  |
| `contour.command`                                             | Override default command                                                                                                           | `[]`                  |
| `contour.args`                                                | Override default args                                                                                                              | `[]`                  |
| `contour.affinity`                                            | Affinity for Contour pod assignment                                                                                                | `{}`                  |
| `contour.nodeSelector`                                        | Node labels for Contour pod assignment                                                                                             | `{}`                  |
| `contour.tolerations`                                         | Tolerations for Contour pod assignment                                                                                             | `[]`                  |
| `contour.podAnnotations`                                      | Contour Pod annotations                                                                                                            | `{}`                  |
| `contour.serviceAccount.create`                               | Create a serviceAccount for the Contour pod                                                                                        | `true`                |
| `contour.serviceAccount.name`                                 | Use the serviceAccount with the specified name, a name is generated using the fullname template                                    | `""`                  |
| `contour.serviceAccount.automountServiceAccountToken`         | Automount service account token for the server service account                                                                     | `true`                |
| `contour.serviceAccount.annotations`                          | Annotations for service account. Evaluated as a template. Only used if `create` is `true`.                                         | `{}`                  |
| `contour.podSecurityContext.enabled`                          | Default backend Pod securityContext                                                                                                | `true`                |
| `contour.podSecurityContext.fsGroup`                          | Set Default backend Pod's Security Context fsGroup                                                                                 | `1001`                |
| `contour.containerSecurityContext.enabled`                    | Envoy Container securityContext                                                                                                    | `true`                |
| `contour.containerSecurityContext.runAsUser`                  | User ID for the Contour container (to change this, http and https containerPorts must be set to >1024)                             | `1001`                |
| `contour.containerSecurityContext.runAsNonRoot`               | Run as non root                                                                                                                    | `true`                |
| `contour.livenessProbe.enabled`                               | Enable/disable the Liveness probe                                                                                                  | `true`                |
| `contour.livenessProbe.initialDelaySeconds`                   | Delay before liveness probe is initiated                                                                                           | `120`                 |
| `contour.livenessProbe.periodSeconds`                         | How often to perform the probe                                                                                                     | `20`                  |
| `contour.livenessProbe.timeoutSeconds`                        | When the probe times out                                                                                                           | `5`                   |
| `contour.livenessProbe.failureThreshold`                      | Minimum consecutive failures for the probe to be considered failed after having succeeded.                                         | `6`                   |
| `contour.livenessProbe.successThreshold`                      | Minimum consecutive successes for the probe to be considered successful after having failed.                                       | `1`                   |
| `contour.readinessProbe.enabled`                              | Enable/disable the readiness probe                                                                                                 | `true`                |
| `contour.readinessProbe.initialDelaySeconds`                  | Delay before readiness probe is initiated                                                                                          | `15`                  |
| `contour.readinessProbe.periodSeconds`                        | How often to perform the probe                                                                                                     | `10`                  |
| `contour.readinessProbe.timeoutSeconds`                       | When the probe times out                                                                                                           | `5`                   |
| `contour.readinessProbe.failureThreshold`                     | Minimum consecutive failures for the probe to be considered failed after having succeeded.                                         | `3`                   |
| `contour.readinessProbe.successThreshold`                     | Minimum consecutive successes for the probe to be considered successful after having failed.                                       | `1`                   |
| `contour.startupProbe.enabled`                                | Enable/disable the startup probe                                                                                                   | `false`               |
| `contour.startupProbe.initialDelaySeconds`                    | Delay before startup probe is initiated                                                                                            | `15`                  |
| `contour.startupProbe.periodSeconds`                          | How often to perform the probe                                                                                                     | `10`                  |
| `contour.startupProbe.timeoutSeconds`                         | When the probe times out                                                                                                           | `5`                   |
| `contour.startupProbe.failureThreshold`                       | Minimum consecutive failures for the probe to be considered failed after having succeeded.                                         | `3`                   |
| `contour.startupProbe.successThreshold`                       | Minimum consecutive successes for the probe to be considered successful after having failed.                                       | `1`                   |
| `contour.certgen.serviceAccount.create`                       | Create a serviceAccount for the Contour pod                                                                                        | `true`                |
| `contour.certgen.serviceAccount.name`                         | Use the serviceAccount with the specified name, a name is generated using the fullname template                                    | `""`                  |
| `contour.certgen.serviceAccount.automountServiceAccountToken` | Automount service account token for the server service account                                                                     | `true`                |
| `contour.certgen.serviceAccount.annotations`                  | Annotations for service account. Evaluated as a template. Only used if `create` is `true`.                                         | `{}`                  |
| `contour.certgen.certificateLifetime`                         | Generated certificate lifetime (in days).                                                                                          | `365`                 |
| `contour.tlsExistingSecret`                                   | Name of the existingSecret to be use in Contour deployment. If it is not nil `contour.certgen` will be disabled.                   | `""`                  |
| `contour.service.type`                                        | Service type                                                                                                                       | `ClusterIP`           |
| `contour.service.ports.xds`                                   | Contour service xds port                                                                                                           | `8001`                |
| `contour.service.ports.metrics`                               | Contour service xds port                                                                                                           | `8000`                |
| `contour.service.nodePorts.xds`                               | Node port for HTTP                                                                                                                 | `""`                  |
| `contour.service.clusterIP`                                   | Contour service Cluster IP                                                                                                         | `""`                  |
| `contour.service.loadBalancerIP`                              | Contour service Load Balancer IP                                                                                                   | `""`                  |
| `contour.service.loadBalancerSourceRanges`                    | Contour service Load Balancer sources                                                                                              | `[]`                  |
| `contour.service.loadBalancerClass`                           | Contour service Load Balancer Class                                                                                                | `""`                  |
| `contour.service.externalTrafficPolicy`                       | Contour service external traffic policy                                                                                            | `Cluster`             |
| `contour.service.annotations`                                 | Additional custom annotations for Contour service                                                                                  | `{}`                  |
| `contour.service.extraPorts`                                  | Extra port to expose on Contour service                                                                                            | `[]`                  |
| `contour.service.sessionAffinity`                             | Session Affinity for Kubernetes service, can be "None" or "ClientIP"                                                               | `None`                |
| `contour.service.sessionAffinityConfig`                       | Additional settings for the sessionAffinity                                                                                        | `{}`                  |
| `contour.initContainers`                                      | Attach additional init containers to Contour pods                                                                                  | `[]`                  |
| `contour.sidecars`                                            | Add additional sidecar containers to the Contour pods                                                                              | `[]`                  |
| `contour.extraVolumes`                                        | Array to add extra volumes                                                                                                         | `[]`                  |
| `contour.extraVolumeMounts`                                   | Array to add extra mounts (normally used with extraVolumes)                                                                        | `[]`                  |
| `contour.extraEnvVars`                                        | Array containing extra env vars to be added to all Contour containers                                                              | `[]`                  |
| `contour.extraEnvVarsCM`                                      | ConfigMap containing extra env vars to be added to all Contour containers                                                          | `""`                  |
| `contour.extraEnvVarsSecret`                                  | Secret containing extra env vars to be added to all Contour containers                                                             | `""`                  |
| `contour.ingressClass.name`                                   | Name of the ingress class to route through this controller.                                                                        | `""`                  |
| `contour.ingressClass.create`                                 | Whether to create or not the IngressClass resource                                                                                 | `true`                |
| `contour.ingressClass.default`                                | Mark IngressClass resource as default for cluster                                                                                  | `true`                |
| `contour.debug`                                               | Enable Contour debug log level                                                                                                     | `false`               |
| `contour.logFormat`                                           | Set contour log-format. Default text, either text or json.                                                                         | `text`                |
| `contour.kubernetesDebug`                                     | Contour kubernetes debug log level, Default 0, minimum 0, maximum 9.                                                               | `0`                   |
| `contour.rootNamespaces`                                      | Restrict Contour to searching these namespaces for root ingress routes.                                                            | `""`                  |
| `contour.overloadManager.enabled`                             | Enable Overload Manager                                                                                                            | `false`               |
| `contour.overloadManager.maxHeapBytes`                        | Overload Manager's maximum heap size in bytes                                                                                      | `2147483648`          |

### Envoy parameters

| Name                                                | Description                                                                                                           | Value                 |
| --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | --------------------- |
| `envoy.enabled`                                     | Envoy Proxy creation                                                                                                  | `true`                |
| `envoy.image.registry`                              | Envoy Proxy image registry                                                                                            | `docker.io`           |
| `envoy.image.repository`                            | Envoy Proxy image repository                                                                                          | `bitnami/envoy`       |
| `envoy.image.tag`                                   | Envoy Proxy image tag (immutable tags are recommended)                                                                | `1.26.1-debian-11-r4` |
| `envoy.image.digest`                                | Envoy Proxy image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag           | `""`                  |
| `envoy.image.pullPolicy`                            | Envoy image pull policy                                                                                               | `IfNotPresent`        |
| `envoy.image.pullSecrets`                           | Envoy image pull secrets                                                                                              | `[]`                  |
| `envoy.priorityClassName`                           | Priority class assigned to the pods                                                                                   | `""`                  |
| `envoy.schedulerName`                               | Name of the k8s scheduler (other than default)                                                                        | `""`                  |
| `envoy.topologySpreadConstraints`                   | Topology Spread Constraints for pod assignment                                                                        | `[]`                  |
| `envoy.extraArgs`                                   | Extra arguments passed to Envoy container                                                                             | `[]`                  |
| `envoy.hostAliases`                                 | Add deployment host aliases                                                                                           | `[]`                  |
| `envoy.resources.limits`                            | Specify resource limits which the container is not allowed to succeed.                                                | `{}`                  |
| `envoy.resources.requests`                          | Specify resource requests which the container needs to spawn.                                                         | `{}`                  |
| `envoy.command`                                     | Override default command                                                                                              | `[]`                  |
| `envoy.args`                                        | Override default args                                                                                                 | `[]`                  |
| `envoy.shutdownManager.enabled`                     | Contour shutdownManager sidecar                                                                                       | `true`                |
| `envoy.shutdownManager.resources.limits`            | Specify resource limits which the container is not allowed to succeed.                                                | `{}`                  |
| `envoy.shutdownManager.resources.requests`          | Specify resource requests which the container needs to spawn.                                                         | `{}`                  |
| `envoy.kind`                                        | Install as deployment or daemonset                                                                                    | `daemonset`           |
| `envoy.replicaCount`                                | Desired number of Controller pods                                                                                     | `1`                   |
| `envoy.lifecycleHooks`                              | lifecycleHooks for the container to automate configuration before or after startup.                                   | `{}`                  |
| `envoy.updateStrategy`                              | Strategy to use to update Pods                                                                                        | `{}`                  |
| `envoy.minReadySeconds`                             | The minimum number of seconds for which a newly created Pod should be ready                                           | `0`                   |
| `envoy.revisionHistoryLimit`                        | The number of old history to retain to allow rollback                                                                 | `10`                  |
| `envoy.autoscaling.enabled`                         | Enable autoscaling for Controller                                                                                     | `false`               |
| `envoy.autoscaling.minReplicas`                     | Minimum number of Controller replicas                                                                                 | `1`                   |
| `envoy.autoscaling.maxReplicas`                     | Maximum number of Controller replicas                                                                                 | `11`                  |
| `envoy.autoscaling.targetCPU`                       | Target CPU utilization percentage                                                                                     | `""`                  |
| `envoy.autoscaling.targetMemory`                    | Target Memory utilization percentage                                                                                  | `""`                  |
| `envoy.podAffinityPreset`                           | Envoy Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                             | `""`                  |
| `envoy.podAntiAffinityPreset`                       | Envoy Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                        | `""`                  |
| `envoy.nodeAffinityPreset.type`                     | Envoy Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                       | `""`                  |
| `envoy.nodeAffinityPreset.key`                      | Envoy Node label key to match Ignored if `affinity` is set.                                                           | `""`                  |
| `envoy.nodeAffinityPreset.values`                   | Envoy Node label values to match. Ignored if `affinity` is set.                                                       | `[]`                  |
| `envoy.affinity`                                    | Affinity for Envoy pod assignment                                                                                     | `{}`                  |
| `envoy.nodeSelector`                                | Node labels for Envoy pod assignment                                                                                  | `{}`                  |
| `envoy.tolerations`                                 | Tolerations for Envoy pod assignment                                                                                  | `[]`                  |
| `envoy.podAnnotations`                              | Envoy Pod annotations                                                                                                 | `{}`                  |
| `envoy.podLabels`                                   | Extra labels for Envoy pods                                                                                           | `{}`                  |
| `envoy.podSecurityContext.enabled`                  | Envoy Pod securityContext                                                                                             | `false`               |
| `envoy.podSecurityContext.fsGroup`                  | User ID for the for the mounted volumes                                                                               | `0`                   |
| `envoy.podSecurityContext.sysctls`                  | Array of sysctl options to allow                                                                                      | `[]`                  |
| `envoy.containerSecurityContext.enabled`            | Envoy Container securityContext                                                                                       | `true`                |
| `envoy.containerSecurityContext.runAsUser`          | User ID for the Envoy container (to change this, http and https containerPorts must be set to >1024)                  | `1001`                |
| `envoy.containerSecurityContext.runAsNonRoot`       | Run as non root                                                                                                       | `true`                |
| `envoy.hostNetwork`                                 | Envoy Pod host network access                                                                                         | `false`               |
| `envoy.dnsPolicy`                                   | Envoy Pod Dns Policy's DNS Policy                                                                                     | `ClusterFirst`        |
| `envoy.tlsExistingSecret`                           | Name of the existingSecret to be use in Envoy deployment                                                              | `""`                  |
| `envoy.serviceAccount.create`                       | Specifies whether a ServiceAccount should be created                                                                  | `true`                |
| `envoy.serviceAccount.name`                         | The name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`                  |
| `envoy.serviceAccount.automountServiceAccountToken` | Whether to auto mount API credentials for a service account                                                           | `false`               |
| `envoy.serviceAccount.annotations`                  | Annotations for service account. Evaluated as a template. Only used if `create` is `true`.                            | `{}`                  |
| `envoy.livenessProbe.enabled`                       | Enable livenessProbe                                                                                                  | `true`                |
| `envoy.livenessProbe.initialDelaySeconds`           | Initial delay seconds for livenessProbe                                                                               | `120`                 |
| `envoy.livenessProbe.periodSeconds`                 | Period seconds for livenessProbe                                                                                      | `20`                  |
| `envoy.livenessProbe.timeoutSeconds`                | Timeout seconds for livenessProbe                                                                                     | `5`                   |
| `envoy.livenessProbe.failureThreshold`              | Failure threshold for livenessProbe                                                                                   | `6`                   |
| `envoy.livenessProbe.successThreshold`              | Success threshold for livenessProbe                                                                                   | `1`                   |
| `envoy.readinessProbe.enabled`                      | Enable/disable the readiness probe                                                                                    | `true`                |
| `envoy.readinessProbe.initialDelaySeconds`          | Delay before readiness probe is initiated                                                                             | `10`                  |
| `envoy.readinessProbe.periodSeconds`                | How often to perform the probe                                                                                        | `3`                   |
| `envoy.readinessProbe.timeoutSeconds`               | When the probe times out                                                                                              | `1`                   |
| `envoy.readinessProbe.failureThreshold`             | Minimum consecutive failures for the probe to be considered failed after having succeeded.                            | `3`                   |
| `envoy.readinessProbe.successThreshold`             | Minimum consecutive successes for the probe to be considered successful after having failed.                          | `1`                   |
| `envoy.startupProbe.enabled`                        | Enable/disable the startup probe                                                                                      | `false`               |
| `envoy.startupProbe.initialDelaySeconds`            | Delay before startup probe is initiated                                                                               | `15`                  |
| `envoy.startupProbe.periodSeconds`                  | How often to perform the probe                                                                                        | `10`                  |
| `envoy.startupProbe.timeoutSeconds`                 | When the probe times out                                                                                              | `5`                   |
| `envoy.startupProbe.failureThreshold`               | Minimum consecutive failures for the probe to be considered failed after having succeeded.                            | `3`                   |
| `envoy.startupProbe.successThreshold`               | Minimum consecutive successes for the probe to be considered successful after having failed.                          | `1`                   |
| `envoy.customLivenessProbe`                         | Override default liveness probe                                                                                       | `{}`                  |
| `envoy.customReadinessProbe`                        | Override default readiness probe                                                                                      | `{}`                  |
| `envoy.customStartupProbe`                          | Override default startup probe                                                                                        | `{}`                  |
| `envoy.terminationGracePeriodSeconds`               | Envoy termination grace period in seconds                                                                             | `300`                 |
| `envoy.logLevel`                                    | Envoy log level                                                                                                       | `info`                |
| `envoy.service.name`                                | envoy service name                                                                                                    | `""`                  |
| `envoy.service.targetPorts`                         | Map the controller service HTTP/HTTPS port                                                                            | `{}`                  |
| `envoy.service.type`                                | Type of Envoy service to create                                                                                       | `LoadBalancer`        |
| `envoy.service.externalTrafficPolicy`               | Envoy Service external cluster policy. If `envoy.service.type` is NodePort or LoadBalancer                            | `Local`               |
| `envoy.service.labels`                              | Labels to add to te envoy service                                                                                     | `{}`                  |
| `envoy.service.clusterIP`                           | Internal envoy cluster service IP                                                                                     | `""`                  |
| `envoy.service.externalIPs`                         | Envoy service external IP addresses                                                                                   | `[]`                  |
| `envoy.service.loadBalancerIP`                      | IP address to assign to load balancer (if supported)                                                                  | `""`                  |
| `envoy.service.loadBalancerSourceRanges`            | List of IP CIDRs allowed access to load balancer (if supported)                                                       | `[]`                  |
| `envoy.service.loadBalancerClass`                   | Envoy service Load Balancer Class                                                                                     | `""`                  |
| `envoy.service.ipFamilyPolicy`                      | , support SingleStack, PreferDualStack and RequireDualStack                                                           | `""`                  |
| `envoy.service.annotations`                         | Annotations for Envoy service                                                                                         | `{}`                  |
| `envoy.service.ports.http`                          | Sets service http port                                                                                                | `80`                  |
| `envoy.service.ports.https`                         | Sets service https port                                                                                               | `443`                 |
| `envoy.service.nodePorts.http`                      | HTTP Port. If `envoy.service.type` is NodePort and this is non-empty                                                  | `""`                  |
| `envoy.service.nodePorts.https`                     | HTTPS Port. If `envoy.service.type` is NodePort and this is non-empty                                                 | `""`                  |
| `envoy.service.extraPorts`                          | Extra ports to expose (normally used with the `sidecar` value)                                                        | `[]`                  |
| `envoy.service.sessionAffinity`                     | Session Affinity for Kubernetes service, can be "None" or "ClientIP"                                                  | `None`                |
| `envoy.service.sessionAffinityConfig`               | Additional settings for the sessionAffinity                                                                           | `{}`                  |
| `envoy.useHostPort`                                 | Enable/disable `hostPort` for TCP/80 and TCP/443                                                                      | `true`                |
| `envoy.useHostIP`                                   | Enable/disable `hostIP`                                                                                               | `false`               |
| `envoy.hostPorts.http`                              | Sets `hostPort` http port                                                                                             | `80`                  |
| `envoy.hostPorts.https`                             | Sets `hostPort` https port                                                                                            | `443`                 |
| `envoy.hostIPs.http`                                | Sets `hostIP` http IP                                                                                                 | `127.0.0.1`           |
| `envoy.hostIPs.https`                               | Sets `hostIP` https IP                                                                                                | `127.0.0.1`           |
| `envoy.containerPorts.http`                         | Sets http port inside Envoy pod  (change this to >1024 to run envoy as a non-root user)                               | `8080`                |
| `envoy.containerPorts.https`                        | Sets https port inside Envoy pod  (change this to >1024 to run envoy as a non-root user)                              | `8443`                |
| `envoy.initContainers`                              | Attach additional init containers to Envoy pods                                                                       | `[]`                  |
| `envoy.sidecars`                                    | Add additional sidecar containers to the Envoy pods                                                                   | `[]`                  |
| `envoy.extraVolumes`                                | Array to add extra volumes                                                                                            | `[]`                  |
| `envoy.extraVolumeMounts`                           | Array to add extra mounts (normally used with extraVolumes)                                                           | `[]`                  |
| `envoy.extraEnvVars`                                | Array containing extra env vars to be added to all Envoy containers                                                   | `[]`                  |
| `envoy.extraEnvVarsCM`                              | ConfigMap containing extra env vars to be added to all Envoy containers                                               | `""`                  |
| `envoy.extraEnvVarsSecret`                          | Secret containing extra env vars to be added to all Envoy containers                                                  | `""`                  |

### Default backend parameters

| Name                                                   | Description                                                                                                     | Value                    |
| ------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `defaultBackend.enabled`                               | Enable a default backend based on NGINX                                                                         | `false`                  |
| `defaultBackend.image.registry`                        | Default backend image registry                                                                                  | `docker.io`              |
| `defaultBackend.image.repository`                      | Default backend image name                                                                                      | `bitnami/nginx`          |
| `defaultBackend.image.tag`                             | Default backend image tag                                                                                       | `1.23.4-debian-11-r15`   |
| `defaultBackend.image.digest`                          | Default backend image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag | `""`                     |
| `defaultBackend.image.pullPolicy`                      | Image pull policy                                                                                               | `IfNotPresent`           |
| `defaultBackend.image.pullSecrets`                     | Specify docker-registry secret names as an array                                                                | `[]`                     |
| `defaultBackend.extraArgs`                             | Additional command line arguments to pass to NGINX container                                                    | `{}`                     |
| `defaultBackend.lifecycleHooks`                        | lifecycleHooks for the container to automate configuration before or after startup.                             | `{}`                     |
| `defaultBackend.extraEnvVars`                          | Array containing extra env vars to be added to all Contour containers                                           | `[]`                     |
| `defaultBackend.extraEnvVarsCM`                        | ConfigMap containing extra env vars to be added to all Contour containers                                       | `""`                     |
| `defaultBackend.extraEnvVarsSecret`                    | Secret containing extra env vars to be added to all Contour containers                                          | `""`                     |
| `defaultBackend.extraVolumes`                          | Array to add extra volumes                                                                                      | `[]`                     |
| `defaultBackend.extraVolumeMounts`                     | Array to add extra mounts (normally used with extraVolumes)                                                     | `[]`                     |
| `defaultBackend.initContainers`                        | Attach additional init containers to the http backend pods                                                      | `[]`                     |
| `defaultBackend.sidecars`                              | Add additional sidecar containers to the default backend                                                        | `[]`                     |
| `defaultBackend.containerPorts.http`                   | Set http port inside Contour pod                                                                                | `8001`                   |
| `defaultBackend.updateStrategy`                        | Strategy to use to update Pods                                                                                  | `{}`                     |
| `defaultBackend.command`                               | Override default command                                                                                        | `[]`                     |
| `defaultBackend.args`                                  | Override default args                                                                                           | `[]`                     |
| `defaultBackend.hostAliases`                           | Add deployment host aliases                                                                                     | `[]`                     |
| `defaultBackend.replicaCount`                          | Desired number of default backend pods                                                                          | `1`                      |
| `defaultBackend.podSecurityContext.enabled`            | Default backend Pod securityContext                                                                             | `true`                   |
| `defaultBackend.podSecurityContext.fsGroup`            | Set Default backend Pod's Security Context fsGroup                                                              | `1001`                   |
| `defaultBackend.containerSecurityContext.enabled`      | Default backend container securityContext                                                                       | `true`                   |
| `defaultBackend.containerSecurityContext.runAsUser`    | User ID for the Envoy container (to change this, http and https containerPorts must be set to >1024)            | `1001`                   |
| `defaultBackend.containerSecurityContext.runAsNonRoot` | Run as non root                                                                                                 | `true`                   |
| `defaultBackend.resources.limits`                      | The resources limits for the Default backend container                                                          | `{}`                     |
| `defaultBackend.resources.requests`                    | The requested resources for the Default backend container                                                       | `{}`                     |
| `defaultBackend.livenessProbe.enabled`                 | Enable livenessProbe                                                                                            | `true`                   |
| `defaultBackend.livenessProbe.httpGet`                 | Path, port and scheme for the livenessProbe                                                                     | `{}`                     |
| `defaultBackend.livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                                                         | `30`                     |
| `defaultBackend.livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                                                | `10`                     |
| `defaultBackend.livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                                               | `5`                      |
| `defaultBackend.livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                                             | `3`                      |
| `defaultBackend.livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                                             | `1`                      |
| `defaultBackend.readinessProbe.enabled`                | Enable readinessProbe                                                                                           | `true`                   |
| `defaultBackend.readinessProbe.httpGet`                | Path, port and scheme for the readinessProbe                                                                    | `{}`                     |
| `defaultBackend.readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                                                        | `0`                      |
| `defaultBackend.readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                                               | `5`                      |
| `defaultBackend.readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                                              | `5`                      |
| `defaultBackend.readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                                            | `6`                      |
| `defaultBackend.readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                                            | `1`                      |
| `defaultBackend.startupProbe.enabled`                  | Enable/disable the startup probe                                                                                | `false`                  |
| `defaultBackend.startupProbe.initialDelaySeconds`      | Delay before startup probe is initiated                                                                         | `15`                     |
| `defaultBackend.startupProbe.periodSeconds`            | How often to perform the probe                                                                                  | `10`                     |
| `defaultBackend.startupProbe.timeoutSeconds`           | When the probe times out                                                                                        | `5`                      |
| `defaultBackend.startupProbe.failureThreshold`         | Minimum consecutive failures for the probe to be considered failed after having succeeded.                      | `3`                      |
| `defaultBackend.startupProbe.successThreshold`         | Minimum consecutive successes for the probe to be considered successful after having failed.                    | `1`                      |
| `defaultBackend.customLivenessProbe`                   | Override default liveness probe, it overrides the default one (evaluated as a template)                         | `{}`                     |
| `defaultBackend.customReadinessProbe`                  | Override default readiness probe, it overrides the default one (evaluated as a template)                        | `{}`                     |
| `defaultBackend.customStartupProbe`                    | Override default startup probe                                                                                  | `{}`                     |
| `defaultBackend.podLabels`                             | Extra labels for Controller pods                                                                                | `{}`                     |
| `defaultBackend.podAnnotations`                        | Annotations for Controller pods                                                                                 | `{}`                     |
| `defaultBackend.priorityClassName`                     | Priority class assigned to the pods                                                                             | `""`                     |
| `defaultBackend.schedulerName`                         | Name of the k8s scheduler (other than default)                                                                  | `""`                     |
| `defaultBackend.terminationGracePeriodSeconds`         | In seconds, time the given to the default backend pod needs to terminate gracefully                             | `60`                     |
| `defaultBackend.topologySpreadConstraints`             | Topology Spread Constraints for pod assignment                                                                  | `[]`                     |
| `defaultBackend.podAffinityPreset`                     | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                             | `""`                     |
| `defaultBackend.podAntiAffinityPreset`                 | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                        | `soft`                   |
| `defaultBackend.nodeAffinityPreset.type`               | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                       | `""`                     |
| `defaultBackend.nodeAffinityPreset.key`                | Node label key to match. Ignored if `affinity` is set.                                                          | `""`                     |
| `defaultBackend.nodeAffinityPreset.values`             | Node label values to match. Ignored if `affinity` is set.                                                       | `[]`                     |
| `defaultBackend.affinity`                              | Affinity for pod assignment. Evaluated as a template.                                                           | `{}`                     |
| `defaultBackend.nodeSelector`                          | Node labels for pod assignment. Evaluated as a template.                                                        | `{}`                     |
| `defaultBackend.tolerations`                           | Tolerations for pod assignment. Evaluated as a template.                                                        | `[]`                     |
| `defaultBackend.service.type`                          | Service type                                                                                                    | `ClusterIP`              |
| `defaultBackend.service.ports.http`                    | Service port                                                                                                    | `80`                     |
| `defaultBackend.service.annotations`                   | Annotations to add to the service                                                                               | `{}`                     |
| `defaultBackend.pdb.create`                            | Enable Pod Disruption Budget configuration                                                                      | `false`                  |
| `defaultBackend.pdb.minAvailable`                      | Minimum number/percentage of Default backend pods that should remain scheduled                                  | `1`                      |
| `defaultBackend.pdb.maxUnavailable`                    | Maximum number/percentage of Default backend pods that should remain scheduled                                  | `""`                     |
| `ingress.enabled`                                      | Ingress configuration enabled                                                                                   | `false`                  |
| `ingress.apiVersion`                                   | Force Ingress API version (automatically detected if not set)                                                   | `""`                     |
| `ingress.certManager`                                  | Add annotations for cert-manager                                                                                | `false`                  |
| `ingress.annotations`                                  | Annotations to be added to the web ingress.                                                                     | `{}`                     |
| `ingress.hostname`                                     | Hostname for the Ingress object                                                                                 | `contour.local`          |
| `ingress.path`                                         | The Path to Concourse                                                                                           | `/`                      |
| `ingress.rulesOverride`                                | Ingress rules override                                                                                          | `[]`                     |
| `ingress.selfSigned`                                   | Create a TLS secret for this ingress record using self-signed certificates generated by Helm                    | `false`                  |
| `ingress.ingressClassName`                             | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)                                   | `""`                     |
| `ingress.extraPaths`                                   | Add additional arbitrary paths that may need to be added to the ingress under the main host.                    | `[]`                     |
| `ingress.tls`                                          | TLS configuration.                                                                                              | `false`                  |
| `ingress.pathType`                                     | Ingress Path type                                                                                               | `ImplementationSpecific` |
| `ingress.extraHosts`                                   | The list of additional hostnames to be covered with this ingress record.                                        | `[]`                     |
| `ingress.extraTls`                                     | The tls configuration for additional hostnames to be covered with this ingress record.                          | `[]`                     |
| `ingress.secrets`                                      | If you're providing your own certificates, please use this to add the certificates as secrets                   | `[]`                     |
| `ingress.extraRules`                                   | Additional rules to be covered with this ingress record                                                         | `[]`                     |

### Metrics parameters

| Name                                       | Description                                                                                                                          | Value                    |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------ | ------------------------ |
| `metrics.serviceMonitor.namespace`         | Specify if the servicemonitors will be deployed into a different namespace (blank deploys into same namespace as chart)              | `""`                     |
| `metrics.serviceMonitor.enabled`           | Specify if a servicemonitor will be deployed for prometheus-operator.                                                                | `false`                  |
| `metrics.serviceMonitor.jobLabel`          | Specify the jobLabel to use for the prometheus-operator                                                                              | `app.kubernetes.io/name` |
| `metrics.serviceMonitor.interval`          | Specify the scrape interval if not specified use default prometheus scrapeIntervall, the Prometheus default scrape interval is used. | `""`                     |
| `metrics.serviceMonitor.metricRelabelings` | Specify additional relabeling of metrics.                                                                                            | `[]`                     |
| `metrics.serviceMonitor.relabelings`       | Specify general relabeling.                                                                                                          | `[]`                     |
| `metrics.serviceMonitor.honorLabels`       | Specify honorLabels parameter to add the scrape endpoint                                                                             | `false`                  |
| `metrics.serviceMonitor.scrapeTimeout`     | The timeout after which the scrape is ended                                                                                          | `""`                     |
| `metrics.serviceMonitor.selector`          | Specify honorLabels parameter to add the scrape endpoint                                                                             | `{}`                     |
| `metrics.serviceMonitor.labels`            | Extra labels for the ServiceMonitor                                                                                                  | `{}`                     |

### Other parameters

| Name                | Description                                                                                                          | Value  |
| ------------------- | -------------------------------------------------------------------------------------------------------------------- | ------ |
| `rbac.create`       | Create the RBAC roles for API accessibility                                                                          | `true` |
| `rbac.rules`        | Custom RBAC rules to set                                                                                             | `[]`   |
| `tlsExistingSecret` | Name of the existingSecret to be use in both contour and envoy. If it is not nil `contour.certgen` will be disabled. | `""`   |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
helm install my-release \
  --set envoy.readinessProbe.successThreshold=5 \
    oci://registry-1.docker.io/bitnamicharts/contour
```

The above command sets the `envoy.readinessProbe.successThreshold` to `5`.

## Configuration and installation details

### [Rolling VS Immutable tags](https://docs.bitnami.com/containers/how-to/understand-rolling-tags-containers/)

It is strongly recommended to use immutable tags in a production environment. This ensures your deployment does not change automatically if the same tag is updated with a different image.

Bitnami will release a new chart updating its containers if a new version of the main container, significant changes, or critical vulnerabilities exist.

To configure [Contour](https://projectcontour.io) please look into the configuration section [Contour Configuration](https://projectcontour.io/docs/main/configuration/).

### Example Quickstart Contour Confiuration

```yaml
configInline:
  # should contour expect to be running inside a k8s cluster
  # incluster: true
  #
  # path to kubeconfig (if not running inside a k8s cluster)
  # kubeconfig: /path/to/.kube/config
  #
  # Client request timeout to be passed to Envoy
  # as the connection manager request_timeout.
  # Defaults to 0, which Envoy interprets as disabled.
  # Note that this is the timeout for the whole request,
  # not an idle timeout.
  # request-timeout: 0s
  # disable ingressroute permitInsecure field
  disablePermitInsecure: false
  tls:
  #   minimum TLS version that Contour will negotiate
  #   minimum-protocol-version: "1.1"
  # Defines the Kubernetes name/namespace matching a secret to use
  # as the fallback certificate when requests which don't match the
  # SNI defined for a vhost.
    fallback-certificate:
  #   name: fallback-secret-name
  #   namespace: projectcontour
  # The following config shows the defaults for the leader election.
  # leaderelection:
  #   configmap-name: leader-elect
  #   configmap-namespace: projectcontour
  ### Logging options
  # Default setting
  accesslog-format: envoy
  # To enable JSON logging in Envoy
  # accesslog-format: json
  # The default fields that will be logged are specified below.
  # To customise this list, just add or remove entries.
  # The canonical list is available at
  # https://godoc.org/github.com/projectcontour/contour/internal/envoy#JSONFields
  # json-fields:
  #   - "@timestamp"
  #   - "authority"
  #   - "bytes_received"
  #   - "bytes_sent"
  #   - "downstream_local_address"
  #   - "downstream_remote_address"
  #   - "duration"
  #   - "method"
  #   - "path"
  #   - "protocol"
  #   - "request_id"
  #   - "requested_server_name"
  #   - "response_code"
  #   - "response_flags"
  #   - "uber_trace_id"
  #   - "upstream_cluster"
  #   - "upstream_host"
  #   - "upstream_local_address"
  #   - "upstream_service_time"
  #   - "user_agent"
  #   - "x_forwarded_for"
  #
  # default-http-versions:
  # - "HTTP/2"
  # - "HTTP/1.1"
  #
  # The following shows the default proxy timeout settings.
  # timeouts:
  #   request-timeout: infinity
  #   connection-idle-timeout: 60s
  #   stream-idle-timeout: 5m
  #   max-connection-duration: infinity
  #   connection-shutdown-grace-period: 5s
```

### Deploying Contour with an AWS NLB

By default, Contour is launched with an AWS Classic ELB. To launch contour backed by a NLB, please set [these settings](https://github.com/projectcontour/contour/tree/master/examples/contour#deploying-with-host-networking-enabled-for-envoy):

```yaml
envoy:
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: nlb
      service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "https"
      service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "3600"
      service.beta.kubernetes.io/aws-load-balancer-ssl-cert: arn:aws:acm: arn:aws:acm:XX-XXXX-X:XXXXXXXXX:certificate/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXX

  containerPorts:
    http: 80
    https: 80
```

### Setting Pod's affinity

This chart allows you to set your custom affinity using the `XXX.affinity` parameter(s). Find more information about Pod's affinity in the [kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity).

As an alternative, you can use of the preset configurations for pod affinity, pod anti-affinity, and node affinity available at the [bitnami/common](https://github.com/bitnami/charts/tree/main/bitnami/common#affinities) chart. To do so, set the `XXX.podAffinityPreset`, `XXX.podAntiAffinityPreset`, or `XXX.nodeAffinityPreset` parameters.

## Troubleshooting

Find more information about how to deal with common errors related to Bitnami's Helm charts in [this troubleshooting guide](https://docs.bitnami.com/general/how-to/troubleshoot-helm-chart-issues).

## Upgrading

Please carefully read through the guide "Upgrading Contour" at <https://projectcontour.io/resources/upgrading/>.

### To 7.0.0

This major release renames several values in this chart and adds missing features, in order to be inline with the rest of assets in the Bitnami charts repository.

Affected values:

- `prometheus` renamed as `metrics`.
- `serviceMonitor.labels` renamed as `serviceMonitor.selector`.
- `service.port` renamed as `service.ports.xds`.
- `service.nodePort` renamed as `service.nodePorts.xds`.
- `contour.updateStrategy` and `worker.updateStrategy` changed from String type (previously default to 'rollingUpdate') to Object type, allowing users to configure other updateStrategy parameters, similar to other charts.

### To 6.0.0

This version updates the chart to use Contour's latest release, `1.19.0`. Among other features, this new version introduces support for new kinds of CRDs: `ContourConfiguration` and `ContourDeployment`. For further information on new features, please refer to the [official release notes](https://github.com/projectcontour/contour/releases/tag/v1.19.0) for this version.

Additionally, exisiting CRDs have been syncronised with the official [Contour repository](https://github.com/projectcontour/contour/blob/main/examples/render/contour.yaml)

#### Considerations when upgrading to this version

If you are installing a fresh chart, you can ignore this section.

If you are upgrading from 5.x of this Helm chart, this is a breaking change as the new CRDs will not overwrite the existing ones. Therefore, you will need to delete the CRDs and let the chart recreate them. Make sure to back up any existing CRs (`kubectl get -o yaml extensionservice,httpproxy,tlscertificatedelegation -A > backup.yaml`) unless you have other ways of recreating them.

### To 5.2.0

This version bumps the Envoy container from 1.17.X to 1.19.X; this Envoy version is officially supported by Contour since 1.18.0, see <https://github.com/projectcontour/contour/releases/tag/v1.18.0>

### To 5.0.0

In this version it was synchronized CRD with the official [Contour repository](https://github.com/projectcontour/contour/blob/main/examples/render/contour.yaml)

#### Considerations when upgrading to 5.0.0

If you are installing a fresh chart, you can ignore this section.

If you are upgrading from 4.x of this Helm chart, this is a breaking change as the new CRDs will not overwrite the existing ones. Therefore, you will need to delete the CRDs and let the chart recreate them. Make sure to back up any existing CRs (`kubectl get -o yaml extensionservice,httpproxy,tlscertificatedelegation -A > backup.yaml`) unless you have other ways of recreating them.

### To 4.0.0

The 4.0 version of this chart introduces changes to handle Contour CRD upgrades. While Helm 3.x introduced the `crd` folder to place CRDs, Helm explicitly does not handle the [CRD upgrade scenario](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#some-caveats-and-explanations).

#### What changes were introduced in 4.0.0?

- The `resources` directory was added that contains all the Contour CRDs, which are imported by the `templates/00-crds.yaml` manifest on installation and upgrade.
- If you do not wish for this chart to manage Contour CRDs, set the flag `contour.manageCRDs` to `false` when running Helm.

#### Considerations when upgrading to 4.0.0

If you are installing a fresh chart, or if you are upgrading from a 4.x version of this chart, you can ignore this section.

If you are upgrading from 3.x of this Helm chart, this is a breaking change as the new CRDs will not overwrite the existing ones. Therefore, you will need to delete the CRDs and let the chart recreate them. Make sure to back up any existing CRs (`kubectl get -o yaml extensionservice,httpproxy,tlscertificatedelegation -A > backup.yaml`) unless you have other ways of recreating them.

If required, back up your existing Custom Resources:

```console
kubectl get -o yaml extensionservice,httpproxy,tlscertificatedelegation -A > backup.yaml
```

Delete the existing Contour CRDs. Note that this step will *also delete* the associated CRs and impact availability until the upgrade is complete and the backup restored:

```console
kubectl delete extensionservices.projectcontour.io
kubectl delete httpproxies.projectcontour.io
kubectl delete tlscertificatedelegations.projectcontour.io
```

Upgrade the Contour chart with the release name `my-release`:

```console
helm upgrade my-release oci://registry-1.docker.io/bitnamicharts/contour
```

If you made a backup earlier, restore the objects:

```console
kubectl apply -f backup.yaml
```

### To 3.0.0

[On November 13, 2020, Helm v2 support was formally finished](https://github.com/helm/charts#status-of-the-project), this major version is the result of the required changes applied to the Helm Chart to be able to incorporate the different features added in Helm v3 and to be consistent with the Helm project itself regarding the Helm v2 EOL.

#### What changes were introduced in 3.0.0?

- Previous versions of this Helm Chart use `apiVersion: v1` (installable by both Helm 2 and 3), this Helm Chart was updated to `apiVersion: v2` (installable by Helm 3 only). [Here](https://helm.sh/docs/topics/charts/#the-apiversion-field) you can find more information about the `apiVersion` field.
- Move dependency information from the *requirements.yaml* to the *Chart.yaml*
- After running `helm dependency update`, a *Chart.lock* file is generated containing the same structure used in the previous *requirements.lock*
- The different fields present in the *Chart.yaml* file has been ordered alphabetically in a homogeneous way for all the Bitnami Helm Charts

#### Considerations when upgrading to 3.0.0

- If you want to upgrade to this version from a previous one installed with Helm v3, you shouldn't face any issues
- If you want to upgrade to this version using Helm v2, this scenario is not supported as this version doesn't support Helm v2 anymore
- If you installed the previous version with Helm v2 and wants to upgrade to this version with Helm v3, please refer to the [official Helm documentation](https://helm.sh/docs/topics/v2_v3_migration/#migration-use-cases) about migrating from Helm v2 to v3

#### Useful links

- <https://docs.bitnami.com/tutorials/resolve-helm2-helm3-post-migration-issues/>
- <https://helm.sh/docs/topics/v2_v3_migration/>
- <https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/>

### To 2.0.0

Most important changes are:

- Using helm hooks to generate new TLS certificates for gRPC calls between Contour and Envoy. This enables us to use the same container image for the contour controller and the certgen job without upgrade issues due to JobSpec immutability.
- Rename parameter `contour.createCustomResource` to `contour.installCRDs`
- Sync CRDs with [upstream project examples](https://github.com/projectcontour/contour/tree/main/examples/contour). Please remember that helm does not touch existing CRDs. As of today, the most reliable way to update the CRDs is, to do it outside helm (Use `--skip-crds` when using helm v3 and `--set contour.installCRDs=false` when using helm v2). Read [Upgrading Contour](https://projectcontour.io/resources/upgrading/) and execute the following `kubectl` command before helm upgrade:

```console
kubectl apply -f https://raw.githubusercontent.com/projectcontour/contour/release-{{version}}/examples/contour/01-crds.yaml
```

This version also introduces `bitnami/common`, a [library chart](https://helm.sh/docs/topics/library_charts/#helm) as a dependency. More documentation about this new utility could be found [here](https://github.com/bitnami/charts/tree/main/bitnami/common#bitnami-common-library-chart). Please, make sure that you have updated the chart dependencies before executing any upgrade.

## License

Copyright &copy; 2023 Bitnami

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.