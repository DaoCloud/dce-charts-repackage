# Helm Chart for the F5 Container Ingress Services

This chart simplifies repeatable, versioned deployment of the [Container Ingress Services](https://clouddocs.f5.com/containers/latest/).

## version

CIS chart: 0.0.22

CIS version: v2.10.0

IPAM chart: 0.0.2

IPAM version: 0.1.8

## compatibility

Refer to [compatibility](https://clouddocs.f5.com/containers/latest/userguide/what-is.html#container-ingress-service-compatibility) and [IPAM](https://github.com/F5Networks/k8s-bigip-ctlr/blob/master/docs/upgradeProcess.md) must require:

- CIS for Kubernetes : v1.14.1, v2.0.x-v2.10.0 ( v2.10.0 for this chart)

- Kubernetes: v1.13-v1.24

- BIG-IP version(s): v12.x-v16.x

- AS3：v3.13-v3.38

## Prerequisites

- BIG-IP must have installed [AS3](https://github.com/F5Networks/f5-appsvcs-extension/releases)

- Create a BIG-IP partition to manage Kubernetes objects. This partition can be created either via the GUI (System > Users > Partition List)

## reference

<https://clouddocs.f5.com/containers/latest/userguide/cis-installation.html>

## for nodeport and cluster mode

[mode introduction] <https://clouddocs.f5.com/containers/latest/userguide/config-options.html>

[cluster mode for calico configuration]<https://clouddocs.f5.com/containers/latest/userguide/calico-config.html>

## create loadbalancer service

example:

    apiVersion: v1
    kind: Service
    metadata:
      name: example
      Annotation
        cis.f5.com/ipamLabel: $IpamLabel
        cis.f5.com/health: '{"interval": 10, "timeout": 31}'
    spec:
      type: LoadBalancer
    ....
