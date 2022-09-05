# Helm Chart for the F5 Container Ingress Services

This chart simplifies repeatable, versioned deployment of the [Container Ingress Services](https://clouddocs.f5.com/containers/latest/).

## compatibility

the f5-bigip-ctlr version is 0.0.21

the f5-ipam-controller version is 0.1.5

Refer to [compatibility](https://clouddocs.f5.com/containers/latest/userguide/what-is.html#container-ingress-service-compatibility), must require:

- Kubernetes: v1.13-v1.23

- BIG-IP version(s): v12.x-v16.x

- AS3：v3.13-v3.36

## Prerequisites

- BIG-IP must have installed [AS3](https://github.com/F5Networks/f5-appsvcs-extension/releases)

- Create a BIG-IP partition to manage Kubernetes objects. This partition can be created either via the GUI (System > Users > Partition List)

## reference

<https://clouddocs.f5.com/containers/latest/userguide/cis-installation.html>
