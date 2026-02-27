# kgateway

![Version: v2.2.1](https://img.shields.io/badge/Version-v2.2.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.2.1](https://img.shields.io/badge/AppVersion-v2.2.1-informational?style=flat-square)

A Helm chart for the kgateway project

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Set affinity rules for pod scheduling, such as 'nodeAffinity:'. |
| controller | object | `{"extraEnv":{},"image":{"pullPolicy":"","registry":"","repository":"kgateway","tag":""},"logLevel":"info","podDisruptionBudget":{},"replicaCount":1,"service":{"ports":{"grpc":9977,"health":9093,"metrics":9092},"type":"ClusterIP"},"strategy":{},"xds":{"tls":{"enabled":false}}}` | Configure the kgateway control plane deployment. |
| controller.extraEnv | object | `{}` | Add extra environment variables to the controller container. |
| controller.image | object | `{"pullPolicy":"","registry":"","repository":"kgateway","tag":""}` | Configure the controller container image. |
| controller.image.pullPolicy | string | `""` | Set the image pull policy for the controller. |
| controller.image.registry | string | `""` | Set the image registry for the controller. |
| controller.image.repository | string | `"kgateway"` | Set the image repository for the controller. |
| controller.image.tag | string | `""` | Set the image tag for the controller. |
| controller.logLevel | string | `"info"` | Set the log level for the controller. |
| controller.podDisruptionBudget | object | `{}` | Set pod disruption budget for the controller. Note that this does not    affect the data plane. E.g.:  podDisruptionBudget:   minAvailable: 100% |
| controller.replicaCount | int | `1` | Set the number of controller pod replicas. |
| controller.service | object | `{"ports":{"grpc":9977,"health":9093,"metrics":9092},"type":"ClusterIP"}` | Configure the controller service. |
| controller.service.ports | object | `{"grpc":9977,"health":9093,"metrics":9092}` | Set the service ports for gRPC and health endpoints. |
| controller.service.type | string | `"ClusterIP"` | Set the service type for the controller. |
| controller.strategy | object | `{}` | Change the rollout strategy from the Kubernetes default of a RollingUpdate with 25% maxUnavailable, 25% maxSurge. E.g., to recreate pods, minimizing resources for the rollout but causing downtime: strategy:   type: Recreate E.g., to roll out as a RollingUpdate but with non-default parameters: strategy:   type: RollingUpdate   rollingUpdate:     maxSurge: 100% |
| controller.xds | object | `{"tls":{"enabled":false}}` | Configure TLS settings for the xDS gRPC servers. |
| controller.xds.tls.enabled | bool | `false` | Enable TLS encryption for xDS communication. When enabled, both the main xDS server (port 9977) and agent gateway xDS server (port 9978) will use TLS. When TLS is enabled, you must create a Secret named 'kgateway-xds-cert' in the kgateway installation namespace. The Secret must be of type 'kubernetes.io/tls' with 'tls.crt', 'tls.key', and 'ca.crt' data fields present. |
| deploymentAnnotations | object | `{}` | Add annotations to the kgateway deployment. |
| discoveryNamespaceSelectors | list | `[]` | List of namespace selectors (OR'ed): each entry can use 'matchLabels' or 'matchExpressions' (AND'ed within each entry if used together). Kgateway includes the selected namespaces in config discovery. For more information, see the docs https://kgateway.dev/docs/latest/install/advanced/#namespace-discovery. |
| fullnameOverride | string | `""` | Override the full name of resources created by the Helm chart, which is 'kgateway'. If you set 'fullnameOverride: "foo", the full name of the resources that the Helm release creates become 'foo', such as the deployment, service, and service account for the kgateway control plane in the kgateway-system namespace. |
| gatewayClassParametersRefs | object | `{}` | Map of GatewayClass names to GatewayParameters references that will be set on    the default GatewayClasses managed by kgateway. Each entry must define both the    name and namespace of the GatewayParameters resource.    The default GatewayClasses managed by kgateway are:    - kgateway    - kgateway-waypoint    Example:    gatewayClassParametersRefs:      kgateway:        name: shared-gwp        namespace: kgateway-system |
| image | object | `{"pullPolicy":"IfNotPresent","registry":"cr.kgateway.dev/kgateway-dev","tag":""}` | Configure the default container image for the components that Helm deploys. You can override these settings for each particular component in that component's section, such as 'controller.image' for the kgateway control plane. If you use your own private registry, make sure to include the imagePullSecrets. |
| image.pullPolicy | string | `"IfNotPresent"` | Set the default image pull policy. |
| image.registry | string | `"cr.kgateway.dev/kgateway-dev"` | Set the default image registry. |
| image.tag | string | `""` | Set the default image tag. |
| imagePullSecrets | list | `[]` | Set a list of image pull secrets for Kubernetes to use when pulling container images from your own private registry instead of the default kgateway registry. |
| nameOverride | string | `""` | Add a name to the default Helm base release, which is 'kgateway'. If you set 'nameOverride: "foo", the name of the resources that the Helm release creates become 'kgateway-foo', such as the deployment, service, and service account for the kgateway control plane in the kgateway-system namespace. |
| nodeSelector | object | `{}` | Set node selector labels for pod scheduling, such as 'kubernetes.io/arch: amd64'. |
| podAnnotations | object | `{"prometheus.io/scrape":"true"}` | Add annotations to the kgateway pods. |
| podSecurityContext | object | `{}` | Set the pod-level security context. For example, 'fsGroup: 2000' sets the filesystem group to 2000. |
| policyMerge | object | `{}` | Policy merging settings. Currently, TrafficPolicy's extAuth, extProc, and transformation policies support deep merging. E.g., to enable deep merging of extProc policy in TrafficPolicy: policyMerge:   trafficPolicy:     extProc: DeepMerge |
| resources | object | `{}` | Configure resource requests and limits for the container, such as 'limits.cpu: 100m' or 'requests.memory: 128Mi'. |
| securityContext | object | `{}` | Set the container-level security context, such as 'runAsNonRoot: true'. |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Configure the service account for the deployment. |
| serviceAccount.annotations | object | `{}` | Add annotations to the service account. |
| serviceAccount.create | bool | `true` | Specify whether a service account should be created. |
| serviceAccount.name | string | `""` | Set the name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| tolerations | list | `[]` | Set tolerations for pod scheduling, such as 'key: "nvidia.com/gpu"'. |
| validation | object | `{"level":"standard"}` | Configure validation behavior for route and policy safety checks in the control plane.    This setting determines how invalid configuration is handled to prevent security bypasses    and to maintain multi-tenant isolation. |
| validation.level | string | `"standard"` | Validation level. Accepted values: "standard" or "strict" (case-insensitive).    Standard replaces invalid routes with a direct 500 response and continues applying valid configuration.    Strict adds xDS preflight validation and blocks snapshots that would NACK in Envoy.    Default is "standard". |
| waypoint | object | `{"enabled":false}` | Enable the waypoint integration. This enables kgateway to translate istio waypoints and use kgateway as a waypoint in an Istio Ambient service mesh setup. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
