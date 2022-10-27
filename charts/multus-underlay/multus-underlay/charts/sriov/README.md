# sriov

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

SR-IOV CNI Helm chart for Kubernetes

**Homepage:** <https://github.com/intel/sriov-network-device-plugin>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Network Plumbing Group |  |  |

## Source Code

* <https://github.com/intel/sriov-network-device-plugin>
* <https://github.com/intel/sriov-cni>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| config.netAttachDef.dpdk.cniVersion | string | `"0.3.1"` |  |
| config.netAttachDef.dpdk.name | string | `"sriov-dpdk-network"` |  |
| config.netAttachDef.dpdk.spoofchk | string | `"off"` |  |
| config.netAttachDef.dpdk.trust | string | `"on"` |  |
| config.netAttachDef.dpdk.type | string | `"sriov"` |  |
| config.netAttachDef.dpdk.vlan | int | `1000` |  |
| config.netAttachDef.dpdkName | string | `"30-intel-sriov-dpdk"` |  |
| config.netAttachDef.dpdkResourceName | string | `"intel.com/intel_sriov_dpdk"` |  |
| config.netAttachDef.netdevice.cniVersion | string | `"0.3.1"` |  |
| config.netAttachDef.netdevice.gateway | string | `"10.10.10.1"` |  |
| config.netAttachDef.netdevice.ipam.rangeEnd | string | `"10.10.10.100"` |  |
| config.netAttachDef.netdevice.ipam.rangeStart | string | `"10.10.10.51"` |  |
| config.netAttachDef.netdevice.ipam.routes[0].dst | string | `"0.0.0.0/0"` |  |
| config.netAttachDef.netdevice.ipam.subnet | string | `"10.10.10.0/24"` |  |
| config.netAttachDef.netdevice.ipam.type | string | `"host-local"` |  |
| config.netAttachDef.netdevice.name | string | `"sriov-network"` |  |
| config.netAttachDef.netdevice.type | string | `"sriov"` |  |
| config.netAttachDef.netdeviceName | string | `"20-intel-sriov-netdevice"` |  |
| config.netAttachDef.netdeviceResourceName | string | `"intel.com/intel_sriov_netdevice"` |  |
| config.scMountPaths.cnibin | string | `"/host/opt/cni/bin"` |  |
| config.sdpMountPaths.configVolume | string | `"/etc/pcidp/"` |  |
| config.sdpMountPaths.deviceInfoPath | string | `"/var/run/k8s.cni.cncf.io/devinfo/dp"` |  |
| config.sdpMountPaths.deviceSock | string | `"/var/lib/kubelet"` |  |
| config.sdpMountPaths.log | string | `"/var/log"` |  |
| config.sriov_device_plugin.resourceList[0].resourceName | string | `"intel_sriov_netdevice"` |  |
| config.sriov_device_plugin.resourceList[0].selectors.devices[0] | string | `"154c"` |  |
| config.sriov_device_plugin.resourceList[0].selectors.devices[1] | string | `"10ed"` |  |
| config.sriov_device_plugin.resourceList[0].selectors.devices[2] | int | `1889` |  |
| config.sriov_device_plugin.resourceList[0].selectors.drivers[0] | string | `"i40evf"` |  |
| config.sriov_device_plugin.resourceList[0].selectors.drivers[1] | string | `"ixgbevf"` |  |
| config.sriov_device_plugin.resourceList[0].selectors.drivers[2] | string | `"iavf"` |  |
| config.sriov_device_plugin.resourceList[0].selectors.vendors[0] | string | `"8086"` |  |
| config.sriov_device_plugin.resourceList[1].resourceName | string | `"intel_sriov_dpdk"` |  |
| config.sriov_device_plugin.resourceList[1].selectors.devices[0] | string | `"154c"` |  |
| config.sriov_device_plugin.resourceList[1].selectors.devices[1] | string | `"10ed"` |  |
| config.sriov_device_plugin.resourceList[1].selectors.devices[2] | int | `1889` |  |
| config.sriov_device_plugin.resourceList[1].selectors.drivers[0] | string | `"vfio-pci"` |  |
| config.sriov_device_plugin.resourceList[1].selectors.pfNames[0] | string | `"enp67s0f1#8-31"` |  |
| config.sriov_device_plugin.resourceList[1].selectors.pfNames[1] | string | `"enp68s0f0#8-31"` |  |
| config.sriov_device_plugin.resourceList[1].selectors.vendors[0] | string | `"8086"` |  |
| config.sriov_device_plugin.resourceList[2].isRdma | bool | `true` |  |
| config.sriov_device_plugin.resourceList[2].resourceName | string | `"mlnx_sriov_rdma"` |  |
| config.sriov_device_plugin.resourceList[2].selectors.devices[0] | string | `"1018"` |  |
| config.sriov_device_plugin.resourceList[2].selectors.drivers[0] | string | `"mlx5_ib"` |  |
| config.sriov_device_plugin.resourceList[2].selectors.drivers[1] | string | `"mlx5_core"` |  |
| config.sriov_device_plugin.resourceList[2].selectors.vendors[0] | string | `"15b3"` |  |
| images.pullPolicy | string | `"IfNotPresent"` |  |
| images.registry | string | `"docker.io"` |  |
| images.sriovCni.repository | string | `"ghcr.io/k8snetworkplumbingwg/sriov-cni"` |  |
| images.sriovCni.tag | string | `"v2.6.3"` |  |
| images.sriovDevicePlugin.repository | string | `"ghcr.io/k8snetworkplumbingwg/sriov-network-device-plugin"` |  |
| images.sriovDevicePlugin.tag | string | `"v3.5.1"` |  |
| labels.nodeSelector."kubernetes.io/arch" | string | `"amd64"` |  |
| manifests.configMap_sriov_device_plugin | bool | `true` |  |
| manifests.daemonSet_sriov_cni | bool | `true` |  |
| manifests.daemonSet_sriov_device_plugin | bool | `true` |  |
| manifests.enable | bool | `false` |  |
| manifests.net_attach_def_dpdk | bool | `false` |  |
| manifests.net_attach_def_netdev | bool | `false` |  |
| manifests.serviceAccount | bool | `true` |  |
| manifests.test_dpdk | bool | `false` |  |
| manifests.test_netdevice | bool | `false` |  |
| pod.resources.enabled | bool | `true` |  |
| pod.resources.sriov_cni.limits.cpu | string | `"100m"` |  |
| pod.resources.sriov_cni.limits.memory | string | `"50Mi"` |  |
| pod.resources.sriov_cni.requests.cpu | string | `"100m"` |  |
| pod.resources.sriov_cni.requests.memory | string | `"50Mi"` |  |
| securityContext.privileged | bool | `true` |  |
| serviceAccount.name | string | `"sriov-device-plugin-test"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
