# Helm Chart for the F5 IPAM Controller

This chart simplifies repeatable, versioned deployment of the [F5 IPAM Controller](https://clouddocs.f5.com/containers/latest/userguide/ipam/).

### Prerequisites
- Refer to [CIS Prerequisites](https://clouddocs.f5.com/containers/latest/userguide/cis-helm.html#prerequisites) to install Container Ingress Services on Kubernetes or Openshift
- [Helm 3](https://helm.sh/docs/intro/) should be installed.
- For Infoblox as provider configure Infoblox with network and netview  Refer [Infoblox documentation](https://www.infoblox.com/products/ipam-dhcp/) 
- Create persistent volume and persistent volume claim  for static f5-ipam provider as follows:

    ```oc apply -f https://raw.githubusercontent.com/F5Networks/f5-ipam-controller/main/docs/config_examples/f5-ip-provider/localstorage-pv-pvc-example.yaml```
## Installing FIC Using Helm Charts

This is the simplest way to install the FIC on OpenShift/Kubernetes cluster. Helm is a package manager for Kubernetes. Helm is Kubernetes version of yum or apt. Helm deploys something called charts, which you can think of as a packaged application. It is a collection of all your versioned, pre-configured application resources which can be deployed as one unit. This chart creates a Deployment for one Pod containing the [F5 IPAM Controller](https://clouddocs.f5.com/containers/latest/userguide/ipam/), it's supporting RBAC, Service Account and Custom Resources Definition installations.

## Installing the Chart
- Add the FIC chart repository in Helm using following command:

    ```helm repo add f5-ipam-stable https://f5networks.github.io/f5-ipam-controller/helm-charts/stable```
 
- Create values.yaml as shown in [examples](https://github.com/F5Networks/f5-ipam-controller/tree/master/helm-charts/f5-ipam-controller/values.yaml):

- Install the Helm chart using the following command:
  
    ```helm install -f values.yaml <new-chart-name> f5-ipam-stable/f5-ipam-controller```

    
## Chart parameters:

| Parameter             | Required  | Description                                                | Default                        |
|-----------------------|-----------|------------------------------------------------------------|--------------------------------|
 | rbac.create           | Optional  | Create ClusterRole and ClusterRoleBinding                  | true                           |
 | serviceAccount.name   | Optional  | name of the ServiceAccount for FIC controller              | <chatname>-f5-ipam-controller  |
 | serviceAccount.create | Optional  | Create service account for the FIC controller              | true                           |
 | namespace             | Optional  | name of namespace FIC lives and watches for IPAM resources | kube-system                    |
 | image.user            | Optional  | FIC Controller image repository username                   | f5networks                     |
| image.repo            | Optional  | FIC Controller image repository name                       | f5-ipam-controller             |
| image.pullPolicy      | Optional  | FIC Controller image pull policy                           | Always                         |
| image.version         | Optional  | FIC Controller image tag                                   | NA                             |
| pvc.name              | Optional  | Name of the persistent volume claim for FIC controller     | <chartname>-f5-ipam-controller |
| pvc.create            | Optional  | Create persistent volume claim for FIC controller          | false                          |
| pvc.storageClassName  | Optional  | Name of the storage class                                  | NA                             |
| pvc.accessMode        | Optional  | Access Mode for the volume                                 | ReadWriteOnce                             |
| pvc.storage           | Optional  | Required storage for FIC controller volume                 | NA                             |
| volume.mountPath      | Optional  | Mount Path that the controller places the DB file          | NA                             |
| volume.mountName      | Optional  | Name of the volume mounted                                 | NA                             |
| nodeSelector	         | Optional	 | dictionary of Node selector labels	                        | empty                          
| tolerations	          | Optional	 | Array of labels	                                           | empty                          
| limits_cpu	           | Optional	 | CPU limits for the pod	                                    | 100m                           
| limits_memory	        | Optional	 | Memory limits for the pod                                  | 512Mi                          
| requests_cpu	         | Optional  | CPU request for the pod                                    | 100m                           
| requests_memory	      | Optional	 | Memory request for the pod                                 | 512Mi                          
| affinity	             | Optional	 | Dictionary of affinity                                     | empty                          
| securityContext	      | Optional	 | Dictionary of securityContext	                             | empty    
| args.infoblox_login_secret   | Optional | Secret that contains infoblox login credentials             | empty                        |

See the FIC documentation for a full list of args supported for FIC [FIC Configuration Options](https://github.com/F5Networks/f5-ipam-controller/blob/main/README.md)

> **Note:** Helm value names cannot include the character `-` which is commonly used in the names of parameters passed to the controller. To accomodate Helm, the parameter names in `values.yaml` use `_` and then replace them with `-` when rendering.
> e.g. `args.ip_range` is rendered as `ip-range` as required by the FIC Controller.


If you have a specific use case for F5 products in the Kubernetes environment that would benefit from a curated chart, please [open an issue](https://github.com/F5Networks/f5-ipam-controller/issues) describing your use case and providing example resources.

## Uninstalling Helm Chart

Run the following command to uninstall the chart.

```helm del <new-chart-name>```

## Known Issues

* Unable to pass multiple Infoblox labels to FIC Helm charts and OpenShift Operator.

