# Helm Chart for the F5 IPAM Controller

This chart simplifies repeatable, versioned deployment of the [F5 IPAM Controller](https://clouddocs.f5.com/containers/latest/userguide/ipam/).

### Prerequisites
- Refer to [CIS Prerequisites](https://clouddocs.f5.com/containers/latest/userguide/cis-helm.html#prerequisites) to install Container Ingress Services on Kubernetes or Openshift
- [Helm 3](https://helm.sh/docs/intro/) should be installed.


## Installing FIC Using Helm Charts

This is the simplest way to install the FIC on OpenShift/Kubernetes cluster. Helm is a package manager for Kubernetes. Helm is Kubernetes version of yum or apt. Helm deploys something called charts, which you can think of as a packaged application. It is a collection of all your versioned, pre-configured application resources which can be deployed as one unit. This chart creates a Deployment for one Pod containing the [F5 IPAM Controller](https://clouddocs.f5.com/containers/latest/userguide/ipam/), it's supporting RBAC, Service Account and Custom Resources Definition installations.

## Installing the Chart
 
- Create values.yaml as shown in [examples](https://github.com/F5Networks/f5-ipam-controller/tree/master/helm-charts/f5-ipam-controller/values.yaml):

- Install the Helm chart using the following command:
  
```helm install -f values.yaml <new-chart-name> f5-stable/f5-ipam-controller```

    
## Chart parameters:

| Parameter             | Required | Description                                                              | Default                       |
|-----------------------|----------|--------------------------------------------------------------------------|-------------------------------|
 | rbac.create           | Optional | Create ClusterRole and ClusterRoleBinding                                | true                          |
 | serviceAccount.name   | Optional | name of the ServiceAccount for FIC controller                            | <chatname>-f5-ipam-controller |
 | serviceAccount.create | Optional | Create service account for the FIC controller                            | true                          |
 | namespace             | Optional | name of namespace FIC lives and watches for IPAM resources               | kube-system                   |
 | image.user            | Optional | FIC Controller image repository username                                 | f5networks                    |
| image.repo            | Optional | FIC Controller image repository name                                     | f5-ipam-controller            |
| image.pullPolicy      | Optional | FIC Controller image pull policy                                         | Always                        |
| image.version         | Optional | FIC Controller image tag                                                 | NA                            |
 | volume.mountPath      | Required | Mount Path that the controller places the DB file                        | NA                            |
 | volume.mountName      | Required | Name of the volume mounted                                               | NA                            |
 | volume.pvc            | Required | Persistent volume claim, using which enables controller to access volume | NA                            |

See the FIC documentation for a full list of args supported for FIC [FIC Configuration Options](https://github.com/F5Networks/f5-ipam-controller/blob/main/README.md)

> **Note:** Helm value names cannot include the character `-` which is commonly used in the names of parameters passed to the controller. To accomodate Helm, the parameter names in `values.yaml` use `_` and then replace them with `-` when rendering.
> e.g. `args.ip_range` is rendered as `ip-range` as required by the FIC Controller.


If you have a specific use case for F5 products in the Kubernetes environment that would benefit from a curated chart, please [open an issue](https://github.com/F5Networks/f5-ipam-controller/issues) describing your use case and providing example resources.

## Uninstalling Helm Chart

Run the following command to uninstall the chart.

```helm uninstall <new-chart-name>```

