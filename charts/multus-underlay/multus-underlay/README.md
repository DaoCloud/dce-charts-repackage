# multus-underlay

![Version: 0.2.4](https://img.shields.io/badge/Version-0.2.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.2.4](https://img.shields.io/badge/AppVersion-0.2.4-informational?style=flat-square)

Multi-underlay enables attaching multiple network interfaces to pods in Kubernetes.

## Source Code

* <https://github.com/spidernet-io/cni-plugins>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://charts/multus | multus | v3.9 |
| file://charts/sriov | sriov | 0.1.2 |
| https://spidernet-io.github.io/cni-plugins | meta-plugins | 0.2.4 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cluster_subnet.pod_subnet[0] | string | `"10.233.64.0/18"` |  |
| cluster_subnet.rp_filter.set_host | bool | `true` |  |
| cluster_subnet.rp_filter.value | int | `0` |  |
| cluster_subnet.service_subnet.ipv4 | string | `"10.233.0.0/18"` |  |
| cluster_subnet.service_subnet.ipv6 | string | `""` |  |
| fullnameOverride | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| macvlan.custom_route[0] | string | `"169.254.25.10/32"` |  |
| macvlan.enable | bool | `true` |  |
| macvlan.master | string | `"ens192"` |  |
| macvlan.migrate_route | int | `-1` |  |
| macvlan.name | string | `"macvlan-overlay-vlan0"` |  |
| macvlan.overlayInterface | string | `"eth0"` |  |
| macvlan.skip_call | bool | `false` |  |
| macvlan.type | string | `"macvlan-overlay"` |  |
| macvlan.vlanID | int | `0` |  |
| meta-plugins.image.registry | string | `"ghcr.m.daocloud.io"` |  |
| meta-plugins.image.repository | string | `"spidernet-io/cni-plugins/meta-plugins"` |  |
| meta-plugins.image.tag | string | `"v0.2.4"` |  |
| multus.config.cni_conf.binDir | string | `"/opt/cni/bin"` |  |
| multus.config.cni_conf.capabilities.bandwidth | bool | `true` |  |
| multus.config.cni_conf.capabilities.portMappings | bool | `true` |  |
| multus.config.cni_conf.clusterNetwork | string | `"calico"` | calico or cilium |
| multus.config.cni_conf.cniDir | string | `"/var/lib/cni/multus"` |  |
| multus.config.cni_conf.cniVersion | string | `"0.3.1"` |  |
| multus.config.cni_conf.confDir | string | `"/etc/cni/net.d"` |  |
| multus.config.cni_conf.defaultNetwork | list | `[]` |  |
| multus.config.cni_conf.delegates | list | `[]` |  |
| multus.config.cni_conf.kubeconfig | string | `"/etc/cni/net.d/multus.d/multus.kubeconfig"` |  |
| multus.config.cni_conf.logFile | string | `"/var/log/multus.log"` |  |
| multus.config.cni_conf.logLevel | string | `"info"` | info,debug,error,verbose,panic |
| multus.config.cni_conf.name | string | `"multus-cni-network"` |  |
| multus.config.cni_conf.namespaceIsolation | bool | `false` |  |
| multus.config.cni_conf.readinessindicatorfile | string | `""` |  |
| multus.config.cni_conf.systemNamespaces[0] | string | `"kube-system"` |  |
| multus.config.cni_conf.type | string | `"multus"` |  |
| multus.image.registry | string | `"ghcr.m.daocloud.io"` |  |
| multus.image.repository | string | `"k8snetworkplumbingwg/multus-cni"` |  |
| multus.image.tag | string | `"v3.9"` |  |
| multus.labels.nodeSelector."kubernetes.io/os" | string | `"linux"` |  |
| multus.pod.resources.enabled | bool | `false` |  |
| multus.pod.resources.multus.limits.cpu | string | `"2000m"` |  |
| multus.pod.resources.multus.limits.memory | string | `"1024Mi"` |  |
| multus.pod.resources.multus.requests.cpu | string | `"250m"` |  |
| multus.pod.resources.multus.requests.memory | string | `"128Mi"` |  |
| nameOverride | string | `""` |  |
| overlay_crds.calico.enable | bool | `true` |  |
| overlay_crds.calico.name | string | `"calico"` |  |
| overlay_crds.cilium.enable | bool | `true` |  |
| overlay_crds.cilium.name | string | `"cilium"` |  |
| overlay_crds.k8s-pod-network.enable | bool | `true` |  |
| overlay_crds.k8s-pod-network.name | string | `"k8s-pod-network"` |  |
| sriov.config.scMountPaths.cnibin | string | `"/host/opt/cni/bin"` |  |
| sriov.config.sdpMountPaths.configVolume | string | `"/etc/pcidp/"` |  |
| sriov.config.sdpMountPaths.deviceInfoPath | string | `"/var/run/k8s.cni.cncf.io/devinfo/dp"` |  |
| sriov.config.sdpMountPaths.deviceSock | string | `"/var/lib/kubelet"` |  |
| sriov.config.sdpMountPaths.log | string | `"/var/log"` |  |
| sriov.config.sriov_device_plugin.devices[0] | string | `"154c"` |  |
| sriov.config.sriov_device_plugin.drivers | list | `[]` |  |
| sriov.config.sriov_device_plugin.name | string | `"sriov_netdevice"` |  |
| sriov.config.sriov_device_plugin.pfNames | list | `[]` |  |
| sriov.config.sriov_device_plugin.resourcePrefix | string | `"intel.com"` |  |
| sriov.config.sriov_device_plugin.vendors[0] | string | `"8086"` |  |
| sriov.images.pullPolicy | string | `"IfNotPresent"` |  |
| sriov.images.sriovCni.registry | string | `"ghcr.m.daocloud.io"` |  |
| sriov.images.sriovCni.repository | string | `"k8snetworkplumbingwg/sriov-cni"` |  |
| sriov.images.sriovCni.tag | string | `"v2.7.0"` |  |
| sriov.images.sriovDevicePlugin.registry | string | `"ghcr.m.daocloud.io"` |  |
| sriov.images.sriovDevicePlugin.repository | string | `"k8snetworkplumbingwg/sriov-network-device-plugin"` |  |
| sriov.images.sriovDevicePlugin.tag | string | `"v3.5.1"` |  |
| sriov.labels.nodeSelector."kubernetes.io/os" | string | `"linux"` |  |
| sriov.manifests.configMap_sriov_device_plugin | bool | `true` |  |
| sriov.manifests.daemonSet_sriov_cni | bool | `true` |  |
| sriov.manifests.daemonSet_sriov_device_plugin | bool | `true` |  |
| sriov.manifests.enable | bool | `false` |  |
| sriov.manifests.serviceAccount | bool | `true` |  |
| sriov.pod.resources.enabled | bool | `true` |  |
| sriov.pod.resources.sriov_cni.limits.cpu | string | `"100m"` |  |
| sriov.pod.resources.sriov_cni.limits.memory | string | `"50Mi"` |  |
| sriov.pod.resources.sriov_cni.requests.cpu | string | `"100m"` |  |
| sriov.pod.resources.sriov_cni.requests.memory | string | `"50Mi"` |  |
| sriov.serviceAccount.name | string | `"sriov-device-plugin-test"` |  |
| sriov.sriov_crd.custom_route[0] | string | `"169.254.25.10/32"` |  |
| sriov.sriov_crd.migrate_route | int | `-1` |  |
| sriov.sriov_crd.name | string | `"sriov-overlay-vlan0"` |  |
| sriov.sriov_crd.overlayInterface | string | `"eth0"` |  |
| sriov.sriov_crd.skip_call | bool | `false` |  |
| sriov.sriov_crd.type | string | `"sriov-overlay"` |  |
| sriov.sriov_crd.vlanId | int | `0` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
