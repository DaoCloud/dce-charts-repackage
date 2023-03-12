# multus

![Version: v3.9](https://img.shields.io/badge/Version-v3.9-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v3.9](https://img.shields.io/badge/AppVersion-v3.9-informational?style=flat-square)

Multus CNI enables attaching multiple network interfaces to pods in Kubernetes.

**Homepage:** <https://github.com/intel/multus-cni>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Network Plumbing Group |  |  |

## Source Code

* <https://github.com/intel/multus-cni>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| config.cni_conf.binDir | string | `"/opt/cni/bin"` |  |
| config.cni_conf.capabilities.bandwidth | bool | `true` |  |
| config.cni_conf.capabilities.portMappings | bool | `true` |  |
| config.cni_conf.clusterNetwork | string | `"calico"` |  |
| config.cni_conf.cniDir | string | `"/var/lib/cni/multus"` |  |
| config.cni_conf.cniVersion | string | `"0.3.1"` |  |
| config.cni_conf.confDir | string | `"/etc/cni/net.d"` |  |
| config.cni_conf.defaultNetwork | list | `[]` |  |
| config.cni_conf.delegates | list | `[]` |  |
| config.cni_conf.kubeconfig | string | `"/etc/cni/net.d/multus.d/multus.kubeconfig"` |  |
| config.cni_conf.logFile | string | `"/var/log/multus.log"` |  |
| config.cni_conf.logLevel | string | `"info"` |  |
| config.cni_conf.name | string | `"multus-cni-network"` |  |
| config.cni_conf.namespaceIsolation | bool | `false` |  |
| config.cni_conf.readinessindicatorfile | string | `""` |  |
| config.cni_conf.systemNamespaces[0] | string | `"kube-system"` |  |
| config.cni_conf.type | string | `"multus"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.registry | string | `"ghcr.io"` |  |
| image.repository | string | `"k8snetworkplumbingwg/multus-cni"` |  |
| image.tag | string | `"v3.9"` |  |
| labels.nodeSelector."kubernetes.io/os" | string | `"linux"` |  |
| manifests.clusterRole | bool | `true` |  |
| manifests.clusterRoleBinding | bool | `true` |  |
| manifests.configMap | bool | `true` |  |
| manifests.customResourceDefinition | bool | `true` |  |
| manifests.daemonSet | bool | `true` |  |
| manifests.serviceAccount | bool | `true` |  |
| pod.resources.enabled | bool | `false` |  |
| pod.resources.multus.limits.cpu | string | `"2000m"` |  |
| pod.resources.multus.limits.memory | string | `"1024Mi"` |  |
| pod.resources.multus.requests.cpu | string | `"250m"` |  |
| pod.resources.multus.requests.memory | string | `"128Mi"` |  |
| serviceAccount.name | string | `"multus"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)