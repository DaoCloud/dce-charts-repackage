# SR-IOV Network Operator Helm Chart

SR-IOV Network Operator Helm Chart provides an easy way to install, configure and manage
the lifecycle of SR-IOV network operator.

## SR-IOV Network Operator
SR-IOV Network Operator leverages [Kubernetes CRDs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
and [Operator SDK](https://github.com/operator-framework/operator-sdk) to configure and manage SR-IOV networks in a Kubernetes cluster.

SR-IOV Network Operator features:
- Initialize the supported SR-IOV NIC types on selected nodes.
- Provision/upgrade SR-IOV device plugin executable on selected node.
- Provision/upgrade SR-IOV CNI plugin executable on selected nodes.
- Manage configuration of SR-IOV device plugin on host.
- Generate net-att-def CRs for SR-IOV CNI plugin
- Supports operation in a virtualized Kubernetes deployment
  - Discovers VFs attached to the Virtual Machine (VM)
  - Does not require attached of associated PFs
  - VFs can be associated to SriovNetworks by selecting the appropriate PciAddress as the RootDevice in the SriovNetworkNodePolicy

## QuickStart

### Prerequisites

- Kubernetes v1.17+
- Helm v3

### Install Helm

Helm provides an install script to copy helm binary to your system:
```
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
$ chmod 500 get_helm.sh
$ ./get_helm.sh
```

For additional information and methods for installing Helm, refer to the official [helm website](https://helm.sh/)

### Deploy SR-IOV Network Operator

```
# Install Operator
$ helm install -n sriov-network-operator --create-namespace --wait sriov-network-operator ./

# View deployed resources
$ kubectl -n sriov-network-operator get pods
```

In the case that [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/) is enabled, the sriov network operator namespace will require a security level of 'privileged'
```
$ kubectl label ns sriov-network-operator pod-security.kubernetes.io/enforce=privileged
```

## Chart parameters

In order to tailor the deployment of the network operator to your cluster needs
We have introduced the following Chart parameters.

| Name | Type | Default | description |
| ---- |------|---------|-------------|
| `imagePullSecrets` | list | `[]` | An optional list of references to secrets to use for pulling any of the SR-IOV Network Operator image |

### Operator parameters

| Name | Type | Default | description |
| ---- | ---- | ------- | ----------- |
| `operator.resourcePrefix` | string | `spidernet.io` | Device plugin resource prefix |
| `operator.enableAdmissionController` | bool | `false` | Enable SR-IOV network resource injector and operator webhook |
| `operator.cniBinPath` | string | `/opt/cni/bin` | Path for CNI binary |
| `operator.clusterType` | string | `kubernetes` | Cluster environment type |

### Images parameters

| Name | description | default |
| ---- | ----------- | ------- |
| `images.operator.registry` | sriov-network-operator global image registry | ghcr.m.daocloud.io |
| `images.operator.repository` | Operator controller image repository | k8snetworkplumbingwg/sriov-network-operator |
| `images.operator.tag` | Operator controller image tag | latest |
| `images.sriovConfigDaemon.repository` | Daemon node agent image repository | k8snetworkplumbingwg/sriov-network-operator-config-daemon |
| `images.sriovConfigDaemon.tag` | Daemon node agent image tag | latest |
| `images.sriovCni.repository` | SR-IOV CNI image repository | k8snetworkplumbingwg/sriov-cni |
| `images.sriovCni.tag` | SR-IOV CNI image tag | latest |
| `images.ibSriovCni.repository` | InfiniBand SR-IOV CNI image repository | k8snetworkplumbingwg/ib-sriov-cni |
| `images.ibSriovCni.tag` | InfiniBand SR-IOV CNI image tag | latest |
| `images.sriovDevicePlugin.repository` | SR-IOV device plugin image repository | k8snetworkplumbingwg/sriov-network-device-plugin |
| `images.sriovDevicePlugin.tag` | SR-IOV device plugin image tag | latest |
| `images.resourcesInjector.repository` | Resources Injector image repository | k8snetworkplumbingwg/network-resources-injector |
| `images.resourcesInjector.tag` | Resources Injector image tag | latest |
| `images.webhook.repository` | Operator Webhook image repository | k8snetworkplumbingwg/sriov-network-operator-webhook |
| `images.webhook.tag` | Operator Webhook image tag | latest |
| `sriovNetworkNodePolicy.name` | default sriovNetworkNodePolicy CRD instance name | default-nodepolicy |
| `sriovNetworkNodePolicy.resourceName` | sriov device plugin resourceName | sriov_netdevice |
| `sriovNetworkNodePolicy.pfNames` | sriov device plugin PF name, Must be a NIC present on the node and capable of SR-IVO feature | "" |
| `sriovNetworkNodePolicy.numVfs` | number of sriov device plugin VFs | 0 |
| `sriovNetworkNodePolicy.nodeSelector.labelKey` | the label key of nodes that support the SR-IOV feature | "node-role.kubernetes.io/worker" |
| `sriovNetworkNodePolicy.nodeSelector.labelValue` | the label value of nodes that support the SR-IOV feature | "" |
