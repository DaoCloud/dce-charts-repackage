## Overview

Contour is an open source Kubernetes ingress controller that works by deploying the Envoy proxy as a reverse proxy and load balancer.

## Prerequisites

* Kubernetes 1.19+
* Helm 3.2.0+
* An Operator for ServiceType: LoadBalancer like MetalLB

## Install

```shell
helm repo add daocloud-system https://release.daocloud.io/chartrepo/addon
helm install contour -f values.yml daocloud-system/contour
helm ls
```

## Uninstall

Execute the following command to back up all resources.

```shell
kubectl get -o yaml extensionservice,httpproxy,tlscertificatedelegation -A > backup-contour.yaml
```

Before uninstalling, first execute the following command to check whether all resources of cert-manager have been deleted.

```shell
kubectl delte extensionservice,httpproxy,tlscertificatedelegation
```

Delete application with helm.

```shell
helm uninstall contour-release
```
