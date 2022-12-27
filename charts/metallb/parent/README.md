## Configuration and installation details

### Quick Install

```shell
helm repo add daocloud-system https://release.daocloud.io/chartrepo/addon
helm install metallb daocloud-system/metallb  -n kube-system
```

### ARP Mode

ARP Mode can be enabled when helm installing. Please refer to the following command:

#### Init ARP Mode

```shell
helm install metallb daocloud-system/metallb --set instances.enabled=true \
--set instances.ipAddressPools.addresses="{192.168.1.0/24,172.16.20.1-172.16.20.100}" \
-n kube-system \
--wait
```

- `instances.enabled`: enable init arp mode, Default to `false`.
- `ipAddressPools.addresses`: Configure the address pool list(Cidr,Range,IPv6). Metallb assign IP addresses from the pool list.

> **Note**: flag **--wait**  is required when the arp mode is enabled. Otherwise, It may fail to initialize arp mode.

#### Specify interface for announce lb IPs

```shell
helm install metallb daocloud-system/metallb --set instances.enabled=true \
--set instances.ipAddressPools.addresses="{192.168.1.0/24,172.16.20.1-172.16.20.100}" \
--set instances.arp.interfaces="{ens192}"
-n kube-system \
--wait
```

`--set instances.arp.interfaces="{ens192}"`: The LB IP will be announced only from interface 'ens192'.

### BGP Mode

BGP Mode requires with special hardware support, Such as BGP Router. If you want to enable bgp mode, In addition to having a BGP Router, You also need to configure
`BGPAdvertisement` and `BGPPeer`. For more details, Please refer to the doc: [advanced_bgp_configuration](https://metallb.universe.tf/configuration/_advanced_bgp_configuration/).

### Upgrade

If you want to upgrade **metallb**, Such as image version used. You should use the following command：

```shell
helm upgrade metallb daocloud-system/metallb  --set metallb.controller.image.tag=0.13.7
```

> **Note**: There is no support at this time for upgrading or deleting CRDs using Helm. So if you enabled arp mode when helm installing. And also you want to upgrade the CR resources(update address pool),
Please update the CR resources directly instead of updating it via helm upgrade.
