# multus

![Version: v3.9](https://img.shields.io/badge/Version-v3.9-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v3.9](https://img.shields.io/badge/AppVersion-v3.9-informational?style=flat-square)

Multi-cni enables attaching multiple network interfaces to pods in Kubernetes. Including multus and veth-plugin.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| <https://spidernet-io.github.io/cni-plugins> | plugins | v0.1.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| $schema | string | `"http://json-schema.org/schema#"` |  |
| properties.multus.properties.config.properties.cni_conf.properties.clusterNetwork.default | string | `"calico"` |  |
| properties.multus.properties.config.properties.cni_conf.properties.clusterNetwork.description | string | `"Multus requires that you have first installed a Kubernetes CNI plugin to serve as your pod-to-pod network(calico or cilium)"` |  |
| properties.multus.properties.config.properties.cni_conf.properties.clusterNetwork.enum[0] | string | `"calico"` |  |
| properties.multus.properties.config.properties.cni_conf.properties.clusterNetwork.enum[1] | string | `"cilium"` |  |
| properties.multus.properties.config.properties.cni_conf.properties.clusterNetwork.title | string | `"Default CNI"` |  |
| properties.multus.properties.config.properties.cni_conf.properties.clusterNetwork.type | string | `"string"` |  |
| properties.multus.properties.config.properties.cni_conf.type | string | `"object"` |  |
| properties.multus.properties.config.type | string | `"object"` |  |
| properties.multus.properties.image.properties.repository.default | string | `"ghcr.m.daocloud.io/k8snetworkplumbingwg/multus-cni"` |  |
| properties.multus.properties.image.properties.repository.title | string | `"Repository"` |  |
| properties.multus.properties.image.properties.repository.type | string | `"string"` |  |
| properties.multus.properties.image.properties.tag.default | string | `"v3.9"` |  |
| properties.multus.properties.image.properties.tag.title | string | `"Tag"` |  |
| properties.multus.properties.image.properties.tag.type | string | `"string"` |  |
| properties.multus.properties.image.title | string | `"Image Configuration"` |  |
| properties.multus.properties.image.type | string | `"object"` |  |
| properties.multus.title | string | `"Multus Configuration"` |  |
| properties.multus.type | string | `"object"` |  |
| properties.plugins.properties.image.properties.repository.default | string | `"ghcr.m.daocloud.io/spidernet-io/cni-plugins/veth"` |  |
| properties.plugins.properties.image.properties.repository.title | string | `"Repository"` |  |
| properties.plugins.properties.image.properties.repository.type | string | `"string"` |  |
| properties.plugins.properties.image.properties.tag.default | string | `"v0.1.1"` |  |
| properties.plugins.properties.image.properties.tag.title | string | `"Tag"` |  |
| properties.plugins.properties.image.properties.tag.type | string | `"string"` |  |
| properties.plugins.properties.image.title | string | `"Image Configuration"` |  |
| properties.plugins.properties.image.type | string | `"object"` |  |
| properties.plugins.title | string | `"Underlay CNI Plugins"` |  |
| properties.plugins.type | string | `"object"` |  |
| properties.underlay_crds.properties.calico_subnet.properties.ipv4.title | string | `"*IPv4"` |  |
| properties.underlay_crds.properties.calico_subnet.properties.ipv4.type | string | `"string"` |  |
| properties.underlay_crds.properties.calico_subnet.properties.ipv6.description | string | `"Calico IPv6 Subnet(optional)"` |  |
| properties.underlay_crds.properties.calico_subnet.properties.ipv6.title | string | `"IPv6"` |  |
| properties.underlay_crds.properties.calico_subnet.properties.ipv6.type | string | `"string"` |  |
| properties.underlay_crds.properties.calico_subnet.type | string | `"object"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_overlay.properties.custom_route.title | string | `"Custom Route(optional)"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_overlay.properties.custom_route.type | string | `"string"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_overlay.properties.enable.default | bool | `true` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_overlay.properties.enable.tile | string | `"Enable"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_overlay.properties.enable.type | string | `"boolean"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_overlay.properties.name.default | string | `"macvlan-overlay"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_overlay.properties.name.title | string | `"Name"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_overlay.properties.name.type | string | `"string"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_overlay.title | string | `"Macvlan Overlay"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_overlay.type | string | `"object"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_standalone.properties.custom_route.title | string | `"Custom Route(optional)"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_standalone.properties.custom_route.type | string | `"string"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_standalone.properties.enable.default | bool | `true` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_standalone.properties.enable.tile | string | `"Enable"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_standalone.properties.enable.type | string | `"boolean"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_standalone.properties.name.default | string | `"macvlan-standalone"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_standalone.properties.name.title | string | `"Name"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_standalone.properties.name.type | string | `"string"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_standalone.title | string | `"Macvlan Standalone"` |  |
| properties.underlay_crds.properties.macvlan.properties.macvlan_standalone.type | string | `"object"` |  |
| properties.underlay_crds.properties.macvlan.title | string | `"Macvlan CRD Configuration"` |  |
| properties.underlay_crds.properties.macvlan.type | string | `"object"` |  |
| properties.underlay_crds.properties.nodePortNodeIPs.type | string | `"array"` |  |
| properties.underlay_crds.properties.service_subnet.properties.ipv4.title | string | `"*IPv4"` |  |
| properties.underlay_crds.properties.service_subnet.properties.ipv4.type | string | `"string"` |  |
| properties.underlay_crds.properties.service_subnet.properties.ipv6.description | string | `"Service IPv6 Subnet(optional)"` |  |
| properties.underlay_crds.properties.service_subnet.properties.ipv6.title | string | `"IPv6"` |  |
| properties.underlay_crds.properties.service_subnet.properties.ipv6.type | string | `"string"` |  |
| properties.underlay_crds.properties.service_subnet.title | string | `"Service Subnet"` |  |
| properties.underlay_crds.properties.service_subnet.type | string | `"object"` |  |
| properties.underlay_crds.properties.sriov.properties.macvlan_overlay.properties.custom_route.title | string | `"Custom Route(optional)"` |  |
| properties.underlay_crds.properties.sriov.properties.macvlan_overlay.properties.custom_route.type | string | `"string"` |  |
| properties.underlay_crds.properties.sriov.properties.macvlan_overlay.properties.enable.default | bool | `true` |  |
| properties.underlay_crds.properties.sriov.properties.macvlan_overlay.properties.enable.tile | string | `"Enable"` |  |
| properties.underlay_crds.properties.sriov.properties.macvlan_overlay.properties.enable.type | string | `"boolean"` |  |
| properties.underlay_crds.properties.sriov.properties.macvlan_overlay.properties.name.default | string | `"sriov-overlay"` |  |
| properties.underlay_crds.properties.sriov.properties.macvlan_overlay.properties.name.title | string | `"Name"` |  |
| properties.underlay_crds.properties.sriov.properties.macvlan_overlay.properties.name.type | string | `"string"` |  |
| properties.underlay_crds.properties.sriov.properties.macvlan_overlay.title | string | `"SRIOV Overlay"` |  |
| properties.underlay_crds.properties.sriov.properties.macvlan_overlay.type | string | `"object"` |  |
| properties.underlay_crds.properties.sriov.properties.sriov_standalone.properties.custom_route.title | string | `"Custom Route(optional)"` |  |
| properties.underlay_crds.properties.sriov.properties.sriov_standalone.properties.custom_route.type | string | `"string"` |  |
| properties.underlay_crds.properties.sriov.properties.sriov_standalone.properties.enable.default | bool | `true` |  |
| properties.underlay_crds.properties.sriov.properties.sriov_standalone.properties.enable.tile | string | `"Enable"` |  |
| properties.underlay_crds.properties.sriov.properties.sriov_standalone.properties.enable.type | string | `"boolean"` |  |
| properties.underlay_crds.properties.sriov.properties.sriov_standalone.properties.name.default | string | `"sriov-standalone"` |  |
| properties.underlay_crds.properties.sriov.properties.sriov_standalone.properties.name.title | string | `"Name"` |  |
| properties.underlay_crds.properties.sriov.properties.sriov_standalone.properties.name.type | string | `"string"` |  |
| properties.underlay_crds.properties.sriov.properties.sriov_standalone.title | string | `"SRIOV Standalone"` |  |
| properties.underlay_crds.properties.sriov.properties.sriov_standalone.type | string | `"object"` |  |
| properties.underlay_crds.properties.sriov.title | string | `"SRIOV CRD Configuration"` |  |
| properties.underlay_crds.properties.sriov.type | string | `"object"` |  |
| properties.underlay_crds.title | string | `"Multus Underlay CRDs Configuration"` |  |
| properties.underlay_crds.type | string | `"object"` |  |
| type | string | `"object"` |  |

## Configuration and installation details

### Install

Multus requires that you have first installed a Kubernetes CNI plugin to serve as your pod-to-pod network(calico or cilium), which we
refer to as your "default CNI" (a network interface that every pod will be created with).

### Install List

- multus(required)
- multus network-attachment-definition CRs(Macvlan、Sriov)(default is true)
- Sriov-cni and Sriov-device-plugin(default not to installed) 
- Underlay meta cni-plugins(veth、router plugins)(default is true)

### Quick Start

```shell
helm repo add daocloud-system https://release.daocloud.io/chartrepo/daocloud-system
helm install multus-underlay-underlay-underlay daocloud-system/multus-underlay-underlay-underlay -n kube-system
````

#### Cilium as the default CNI

```shell
helm repo add daocloud-system https://release.daocloud.io/chartrepo/daocloud-system
helm install multus-underlay-underlay-underlay daocloud-system/multus-underlay-underlay-underlay \
--set crd_conf.calico.default_cni=false \
--set crd_conf.cilium.default_cni=true  \
--set multus-underlay-underlay-underlay.config.cni_conf.clusterNetwork=cilium \
-n kube-system
```

- `crd_conf.calico.default_cni`: Mark default cni is not calico, Default to true.
- `crd_conf.cilium.default_cni`: Mark default cni is cilium, Default to false.
- `multus.config.cni_conf.clusterNetwork`: Tell multus that default cni is cilium, Default to "calico".

#### Install SRIOV

By default, SRIOV not to be installed. You can install SRIOV by following command:

```shell
helm repo add daocloud-system https://release.daocloud.io/chartrepo/daocloud-system
helm install multus-underlay-underlay-underlay daocloud-system/multus-underlay-underlay-underlay \
--set sriov.manifests.enable=true \
-n kube-system
```

#### Meta-Plugins Configuration

```shell
helm repo add daocloud-system https://release.daocloud.io/chartrepo/daocloud-system
helm install multus-underlay-underlay-underlay daocloud-system/multus-underlay-underlay-underlay \
--set underlay_crds.service_subnet.ipv4="10.244.0.0/18" \ 
--set underlay_crds.calico_subnet.ipv6="10.244.64.0/18" \ 
--set underlay_crds.nodePortNodeIPs='{172.17.8.110,172.17.8.120,fed0:abcd::1}'
```

- `underlay_crds.nodePortNodeIPs`: All NodePort node IPs, Including IPv4 and IPv6(if required).

### Upgrade

- Update image version:

```shell
helm upgrade multus-underlay-underlay-underlay daocloud-system/dce-multus-underlay-underlay-underlay --set multus-underlay-underlay-underlay.image.tag=v3.9 -n kube-system
```

- Update log level:

```shell
helm upgrade multus-underlay-underlay-underlay daocloud-system/multus-underlay-underlay-underlay --set multus-underlay-underlay-underlay.config.cni_conf.logLevel=debug -n kube-system
```

### Uninstall

```shell
helm uninstall multus-underlay-underlay-underlay -n kube-system 
```

> NOTE: After uninstalling multus, you should also clear the multus cni configuration file on each node (path: etc/cni/net.d/00-multus.conf)
----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
