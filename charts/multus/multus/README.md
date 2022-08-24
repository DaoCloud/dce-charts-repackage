# dce-multus

![Version: v3.9](https://img.shields.io/badge/Version-v3.9-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v3.9](https://img.shields.io/badge/AppVersion-v3.9-informational?style=flat-square)

Multus CNI enables attaching multiple network interfaces to pods in Kubernetes.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://charts/multus | multus | v3.9 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| multus.config.cni_conf.clusterNetwork | string | `"calico"` |  |
| multus.config.cni_conf.logLevel | string | `"info"` |  |
| multus.image.repository | string | `"ghcr.m.daocloud.io/k8snetworkplumbingwg/multus-cni"` |  |
| multus.image.tag | string | `"v3.9"` |  |

## Configuration and installation details

### Install

Multus requires that you have first installed a Kubernetes CNI plugin to serve as your pod-to-pod network(calico or cilium), which we 
refer to as your "default CNI" (a network interface that every pod will be created with). So there are two case:

- Calico as the default CNI:

```shell
helm repo add daocloud-system https://release.daocloud.io/chartrepo/daocloud-system
helm install multus daocloud-system/dce-multus -n kube-system
```

- Cilium as the default CNI:

```shell
helm repo add daocloud-system https://release.daocloud.io/chartrepo/daocloud-system
helm install multus daocloud-system/dce-multus \
--set crd_conf.calico.default_cni=false \
--set crd_conf.cilium.default_cni=true  \
--set multus.config.cni_conf.clusterNetwork=cilium \
-n kube-system
```

- `crd_conf.calico.default_cni`: Mark default cni is not calico, Default to true. 
- `crd_conf.cilium.default_cni`: Mark default cni is cilium, Default to false. 
- `multus.config.cni_conf.clusterNetwork`: Tell multus that default cni is cilium, Default to "calico".

### Upgrade

- Update image version:

```shell
helm upgrade multus daocloud-system/dce-multus --set multus.image.tag=v3.9 -n kube-system
```

- Update log level:

```shell
helm upgrade multus daocloud-system/dce-multus --set multus.config.cni_conf.logLevel=debug -n kube-system
```

----------------------------------------------
