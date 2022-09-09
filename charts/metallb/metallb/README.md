# metallb

![Version: 0.13.4](https://img.shields.io/badge/Version-0.13.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.13.4](https://img.shields.io/badge/AppVersion-0.13.4-informational?style=flat-square)

A network load-balancer implementation for Kubernetes using standard routing protocols

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| <https://metallb.github.io/metallb> | metallb | 0.13.4 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| arp.ipAddressPools | list | `["default-address-pool"]` | list of ip-address pools via arp advertisement |
| arp.name | string | `"default-l2advertisement"` | default arp advertisement name |
| arp.nodeSelectors | object | `{}` |  |
| ipAddressPools.addresses | list | `["192.168.10.0/24"]` | list of addresses pool, include ipv4/ipv6 |
| ipAddressPools.name | string | `"default-address-pool"` | default ip-address pool name |
| metallb.controller.image.pullPolicy | string | `"IfNotPresent"` |  |
| metallb.controller.image.repository | string | `"quay.m.daocloud.io/metallb/controller"` |  |
| metallb.controller.image.tag | string | `v0.13.4` |  |
| metallb.controller.logLevel | string | `"info"` | Controller log level. Must be one of: `all`, `debug`, `info`, `warn`, `error` or `none` |
| metallb.controller.nodeSelector | object | `{}` |  |
| metallb.controller.resources | object | `{}` |  |
| metallb.prometheus.namespace | string | `"insight-system"` | the namespace where prometheus is deployed required when .Values.metallb.prometheus.podMonitor.enabled == true |
| metallb.prometheus.podMonitor.enabled | bool | `false` | enable support for Prometheus Operator |
| metallb.prometheus.prometheusRule.enabled | bool | `false` | enable alertmanager alerts |
| metallb.prometheus.serviceAccount | string | `"insight-agentls-kube-prometh-operator"` | the service account used by prometheus required when .Values.metallb.prometheus.podMonitor.enabled == true |
| metallb.speaker.image.pullPolicy | string | `"IfNotPresent"` |  |
| metallb.speaker.image.repository | string | `"quay.m.daocloud.io/metallb/speaker"` |  |
| metallb.speaker.image.tag | string | `v0.13.4` |  |
| metallb.speaker.logLevel | string | `"info"` | Speaker log level. Must be one of: `all`, `debug`, `info`, `warn`, `error` or `none` |
| metallb.speaker.nodeSelector | object | `{}` |  |
| metallb.speaker.resources | object | `{}` |  |

## Configuration and installation details

### Quick Install

```shell
helm repo add daocloud-system https://release.daocloud.io/chartrepo/system
helm install metallb daocloud-system/metallb  -n kube-system
```

### ARP Mode

ARP Mode can be enabled when helm installing. Please refer to the following command:

```shell
helm install metallb daocloud-system/metallb --set instances.enabled=true \
--set instances.ipAddressPools.addresses="{192.168.1.0/24,172.16.20.1-172.16.20.100}" \ 
-n kube-system \
--wait
```

- `instances.enabled`: enable init arp mode, Default to `false`.
- `ipAddressPools.addresses`: Configure the address pool list(Cidr,Range,IPv6). Metallb assign IP addresses from the pool list.

> **Note**: flag **--wait**  is required when the arp mode is enabled. Otherwise, It may fail to initialize arp mode.

### BGP Mode

BGP Mode requires with special hardware support, Such as BGP Router. If you want to enable bgp mode, In addition to having a BGP Router, You also need to configure  
`BGPAdvertisement` and `BGPPeer`. For more details, Please refer to the doc: [advanced_bgp_configuration](https://metallb.universe.tf/configuration/_advanced_bgp_configuration/).

### Prometheus Metrics

Prometheus metrics can be enabled when helm installing, Please refer to the following command:

````shell
helm install metallb daocloud-system/metallb \
--set metallb.prometheus.podMonitor.enabled=true \
--set metallb.prometheus.prometheusRule.enabled=true \
--set metallb.prometheus.serviceAccount=insight-agent-kube-prometh-operator \
--set metallb.prometheus.namespace=insight-system \
-n kube-system
````

- `metallb.prometheus.podMonitor.enabled`: Enable prometheus metrics, Default to false.
- `metallb.prometheus.prometheusRule.enabled`: Enable prometheus alert rules, Default to false.
- `metallb.prometheus.namespace`: The namespace where prometheus is deployed, Default to "insight-system".
- `metallb.prometheus.serviceAccount`: The service account used by prometheus, Default to "insight-agent-kube-prometh-operator".

> **Note**: when metallb.prometheus.podMonitor.enabled=true, Metallb requires that `namespace` and `serviceAccount` must be specified.

### Upgrade

If you want to upgrade **metallb**, Such as image version used. You should use the following command：

```shell
helm upgrade metallb daocloud-system/metallb  --set metallb.controller.image.tag=v0.13.4
```

> **Note**: There is no support at this time for upgrading or deleting CRDs using Helm. So if you enabled arp mode when helm installing. And also you want to upgrade the CR resources(update address pool),
Please update the CR resources directly instead of updating it via helm upgrade.
----------------------------------------------
