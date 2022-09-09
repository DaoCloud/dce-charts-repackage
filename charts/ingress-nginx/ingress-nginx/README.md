## Overview

Ingress controller for Kubernetes using NGINX as a reverse proxy and load balancer.

## Prerequisites

* Chart version 3.x.x: Kubernetes v1.16+
* Chart version 4.x.x and above: Kubernetes v1.19+

## Install

```shell
helm repo add daocloud-system https://release.daocloud.io/chartrepo/system
helm install ingress-nginx -f values.yml  daocloud-system/ingress-nginx
helm ls
```

## Operator

### Get helm installation values

```shell
helm get values ingress-nginx -n ingress-nginx
```

### Get nginx version

```shell
POD_NAMESPACE=ingress-nginx
POD_NAME=$(kubectl get pods -n $POD_NAMESPACE -l app.kubernetes.io/name=ingress-nginx --field-selector=status.phase=Running -o name)
kubectl exec $POD_NAME -n $POD_NAMESPACE -- /nginx-ingress-controller --version
```
