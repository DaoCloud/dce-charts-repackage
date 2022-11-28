# multus-underlay

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.1.6](https://img.shields.io/badge/AppVersion-0.1.6-informational?style=flat-square)

Multus-underlay works with underlay-cni and enables attaching multiple network interfaces to pods in Kubernetes.


## Requirements

| Repository | Name | Version |
|------------|------|---------|
| <https://github.com/intel/multus-cni> | multus | v3.9 |
| <https://github.com/intel/sriov-network-device-plugin> | sriov | 0.1.2 |
| <https://spidernet-io.github.io/cni-plugins> | meta-plugins | 0.2.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fullnameOverride | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| macvlan.custom_route | list | `[]` |  |
| macvlan.enable | bool | `true` |  |
| macvlan.hijack_overlay_reponse | bool | `true` |  |
| macvlan.master | string | `"ens192"` |  |
| macvlan.name | string | `"macvlan-vlan0"` |  |
| macvlan.overlayInterface | string | `"eth0"` |  |
| macvlan.skip_call | bool | `false` |  |
| macvlan.type | string | `"macvlan-overlay"` |  |
| macvlan.vlanID | int | `0` |  |
| meta-plugins.image.repository | string | `"ghcr.m.daocloud.io/spidernet-io/cni-plugins/meta-plugins"` |  |
| meta-plugins.image.tag | string | `"v0.1.8"` |  |
| multus.config.cni_conf.binDir | string | `"/opt/cni/bin"` |  |
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
| multus.image.repository | string | `"ghcr.m.daocloud.io/k8snetworkplumbingwg/multus-cni"` |  |
| multus.image.tag | string | `"v3.9"` |  |
| multus.labels.nodeSelector."kubernetes.io/arch" | string | `"amd64"` |  |
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
| overlay_subnet.pod_subnet.ipv4[0] | string | `"10.233.64.0/18"` |  |
| overlay_subnet.pod_subnet.ipv6 | list | `[]` |  |
| overlay_subnet.rp_filter.set_host | bool | `true` |  |
| overlay_subnet.rp_filter.value | int | `2` |  |
| overlay_subnet.service_subnet.ipv4 | string | `"10.233.0.0/18"` |  |
| overlay_subnet.service_subnet.ipv6 | string | `""` |  |
| sriov.config.scMountPaths.cnibin | string | `"/host/opt/cni/bin"` |  |
| sriov.config.sdpMountPaths.configVolume | string | `"/etc/pcidp/"` |  |
| sriov.config.sdpMountPaths.deviceInfoPath | string | `"/var/run/k8s.cni.cncf.io/devinfo/dp"` |  |
| sriov.config.sdpMountPaths.deviceSock | string | `"/var/lib/kubelet"` |  |
| sriov.config.sdpMountPaths.log | string | `"/var/log"` |  |
| sriov.config.sriov_device_plugin.resourceList[0].resourceName | string | `"intel_sriov_netdevice"` |  |
| sriov.config.sriov_device_plugin.resourceList[0].selectors.devices[0] | string | `"154c"` |  |
| sriov.config.sriov_device_plugin.resourceList[0].selectors.devices[1] | string | `"10ed"` |  |
| sriov.config.sriov_device_plugin.resourceList[0].selectors.devices[2] | string | `"1889"` |  |
| sriov.config.sriov_device_plugin.resourceList[0].selectors.drivers[0] | string | `"i40evf"` |  |
| sriov.config.sriov_device_plugin.resourceList[0].selectors.drivers[1] | string | `"ixgbevf"` |  |
| sriov.config.sriov_device_plugin.resourceList[0].selectors.drivers[2] | string | `"iavf"` |  |
| sriov.config.sriov_device_plugin.resourceList[0].selectors.vendors[0] | string | `"8086"` |  |
| sriov.config.sriov_device_plugin.resourceList[1].resourceName | string | `"intel_sriov_dpdk"` |  |
| sriov.config.sriov_device_plugin.resourceList[1].selectors.devices[0] | string | `"154c"` |  |
| sriov.config.sriov_device_plugin.resourceList[1].selectors.devices[1] | string | `"10ed"` |  |
| sriov.config.sriov_device_plugin.resourceList[1].selectors.devices[2] | string | `"1889"` |  |
| sriov.config.sriov_device_plugin.resourceList[1].selectors.drivers[0] | string | `"vfio-pci"` |  |
| sriov.config.sriov_device_plugin.resourceList[1].selectors.pfNames[0] | string | `"enp67s0f1#8-31"` |  |
| sriov.config.sriov_device_plugin.resourceList[1].selectors.pfNames[1] | string | `"enp68s0f0#8-31"` |  |
| sriov.config.sriov_device_plugin.resourceList[1].selectors.vendors[0] | string | `"8086"` |  |
| sriov.config.sriov_device_plugin.resourceList[2].isRdma | bool | `true` |  |
| sriov.config.sriov_device_plugin.resourceList[2].resourceName | string | `"mlnx_sriov_rdma"` |  |
| sriov.config.sriov_device_plugin.resourceList[2].selectors.devices[0] | string | `"1018"` |  |
| sriov.config.sriov_device_plugin.resourceList[2].selectors.drivers[0] | string | `"mlx5_ib"` |  |
| sriov.config.sriov_device_plugin.resourceList[2].selectors.drivers[1] | string | `"mlx5_core"` |  |
| sriov.config.sriov_device_plugin.resourceList[2].selectors.vendors[0] | string | `"15b3"` |  |
| sriov.images.pullPolicy | string | `"IfNotPresent"` |  |
| sriov.images.registry | string | `"docker.io"` |  |
| sriov.images.sriovCni.repository | string | `"ghcr.m.daocloud.io/k8snetworkplumbingwg/sriov-cni"` |  |
| sriov.images.sriovCni.tag | string | `"v2.6.3"` |  |
| sriov.images.sriovDevicePlugin.repository | string | `"ghcr.m.daocloud.io/k8snetworkplumbingwg/sriov-network-device-plugin"` |  |
| sriov.images.sriovDevicePlugin.tag | string | `"v3.5.1"` |  |
| sriov.labels.nodeSelector."kubernetes.io/arch" | string | `"amd64"` |  |
| sriov.manifests.configMap_sriov_device_plugin | bool | `true` |  |
| sriov.manifests.daemonSet_sriov_cni | bool | `true` |  |
| sriov.manifests.daemonSet_sriov_device_plugin | bool | `true` |  |
| sriov.manifests.enable | bool | `false` |  |
| sriov.manifests.net_attach_def_dpdk | bool | `false` |  |
| sriov.manifests.net_attach_def_netdev | bool | `false` |  |
| sriov.manifests.serviceAccount | bool | `true` |  |
| sriov.manifests.test_dpdk | bool | `false` |  |
| sriov.manifests.test_netdevice | bool | `false` |  |
| sriov.pod.resources.enabled | bool | `true` |  |
| sriov.pod.resources.sriov_cni.limits.cpu | string | `"100m"` |  |
| sriov.pod.resources.sriov_cni.limits.memory | string | `"50Mi"` |  |
| sriov.pod.resources.sriov_cni.requests.cpu | string | `"100m"` |  |
| sriov.pod.resources.sriov_cni.requests.memory | string | `"50Mi"` |  |
| sriov.serviceAccount.name | string | `"sriov-device-plugin-test"` |  |
| sriov.sriov_crd.custom_route | list | `[]` |  |
| sriov.sriov_crd.hijack_overlay_reponse | bool | `true` |  |
| sriov.sriov_crd.name | string | `"sriov-vlan0"` |  |
| sriov.sriov_crd.overlayInterface | string | `"eth0"` |  |
| sriov.sriov_crd.resourceName | string | `""` |  |
| sriov.sriov_crd.skip_call | bool | `false` |  |
| sriov.sriov_crd.type | string | `"sriov-overlay"` |  |
| sriov.sriov_crd.vlanID | int | `0` |  |

## Configuration and installation details

### Install

Multus requires that you have first installed a Kubernetes CNI plugin to serve as your pod-to-pod network(calico or cilium), which we
refer to as your "default CNI" (a network interface that every pod will be created with).

### Install List

- Multus(required)
- multus network-attachment-definition CRs(Macvlan、Sriov)(default is true)
- Sriov-cni and Sriov-device-plugin(default not to installed)
- Underlay meta cni-plugins(veth、router plugins)(default is true)

### Quick Start

```shell
helm repo add daocloud-system https://release.daocloud.io/chartrepo/addon
helm install multus-underlay daocloud-system/multus-underlay -n kube-system
````

#### Calico as the default CNI

```shell
helm repo add daocloud-system https://release.daocloud.io/chartrepo/addon
helm install multus-underlay daocloud-system/multus-underlay -n kube-system \
--set multus.config.cni_conf.clusterNetwork="calico" 
```

- *multus.config.cni_conf.clusterNetwork="calico"*: Note: The given value must be match the value for name key in the config file (e.g. "name": "k8s-pod-network" in "/etc/cni/net.d/10-calico.conflist")

#### Cilium as the default CNI

```shell
helm repo add daocloud-system https://release.daocloud.io/chartrepo/addon
helm install multus-underlay daocloud-system/multus-underlay -n kube-system \
--set multus.config.cni_conf.clusterNetwork=cilium \
```

- `multus.config.cni_conf.clusterNetwork`: Note: The given value must be match the value for name key in the config file (e.g. "name": "cilium" in "/etc/cni/net.d/05-cilium.conf")

#### Macvlan CNI Settings

You can configure Macvlan-CNI with the following command:

```shell
helm install multus-underlay daocloud-system/multus-underlay -n kube-system \
--set overlay_subnet.service_subnet.ipv4="10.233.0.0/18" \
--set overlay_subnet.service_subnet.ipv6="fc02::/108" \
--set overlay_subnet.pod_subnet.ipv4="10.233.64.0/18" \
--set overlay_subnet.pod_subnet.ipv6="fc01::/48" \
--set macvlan.type="macvlan-overlay" \
--set macvlan.name="macvlan-vlan0" \
--set macvlan.master="ens192" \ 
--set macvlan.vlanID=0 
```

- *overlay_subnet.service_subnet.ipv4*: Service CIDR(ipv4) in cluster.
- *overlay_subnet.service_subnet.ipv6*: Service CIDR(ipv6) in cluster.
- *overlay_subnet.pod_subnet.ipv4*: Default-CNI(calico or cilium) pod CIDR(ipv4).
- *overlay_subnet.pod_subnet.ipv6*: Default-CNI(calico or cilium) pod CIDR(ipv6).
- *macvlan.master*: Macvlan Master Interface(The master interface must exist on the host).

#### Install SRIOV

By default, SRIOV not to be installed. You can install SRIOV by following command:

```shell
helm repo add daocloud-system https://release.daocloud.io/chartrepo/addon
helm install multus-underlay daocloud-system/multus-underlay \
--set sriov.manifests.enable=true \
-n kube-system
```

### Upgrade

- Update image version:

```shell
helm upgrade multus-underlay daocloud-system/multus-underlay --set multus.image.tag=v3.9.1 -n kube-system
```

- Update log level:

```shell
helm upgrade multus-underlay daocloud-system/multus-underlay --set multus.config.cni_conf.logLevel=debug -n kube-system
```

- Update Multus CRDs

If you want to update the config of Macvlan-CNI, You should  directly to update the CRD instance instead of via `helm upgrade`.

### Uninstall

```shell
helm uninstall multus-underlay daocloud-system/multus-underlay -n kube-system
```

> NOTE!: After uninstalling multus, you should also clear the multus cni configuration file on each node (path: /etc/cni/net.d/00-multus.conf).

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
