<!--- app-name: TestLink -->

# TestLink packaged by Bitnami

TestLink is test management software that facilitates software quality assurance. It suppors test cases, test suites, test plans, test projects and user management, and stats reporting.

[Overview of TestLink](http://www.testlink.org)

Trademarks: This software listing is packaged by Bitnami. The respective trademarks mentioned in the offering are owned by the respective companies, and use of them does not imply any affiliation or endorsement.
                           
## Azure-ready Charts with Containers from marketplace.azurecr.io

This Helm Chart has been configured to pull the Container Images from the Azure Marketplace Public Repository.
The following command allows you to download and install all the charts from this repository.
```bash
$ helm repo add bitnami-azure https://marketplace.azurecr.io/helm/v1/repo
```
## TL;DR

```console
$ helm repo add bitnami-azure https://marketplace.azurecr.io/helm/v1/repo
$ helm install my-release bitnami-azure/testlink
```

## Introduction

This chart bootstraps a [TestLink](https://github.com/bitnami/bitnami-docker-testlink) deployment on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

TestLink is developed and maintained by Teamtest. The platform offers support for test cases, test suites, test plans, test projects and user management, as well as various reports and statistics.

It also packages the [Bitnami MariaDB chart](https://github.com/bitnami/charts/tree/master/bitnami/mariadb) which is required for bootstrapping a MariaDB deployment for the database requirements of the TestLink application.

Bitnami charts can be used with [Kubeapps](https://kubeapps.com/) for deployment and management of Helm Charts in clusters. This chart has been tested to work with NGINX Ingress, cert-manager, fluentd and Prometheus on top of the [BKPR](https://kubeprod.io/).

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure
- ReadWriteMany volumes for deployment scaling

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install my-release bitnami-azure/testlink
```

The command deploys TestLink on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Global parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `global.imageRegistry`    | Global Docker image registry                    | `""`  |
| `global.imagePullSecrets` | Global Docker registry secret names as an array | `[]`  |
| `global.storageClass`     | Global StorageClass for Persistent Volume(s)    | `""`  |


### Common parameters

| Name                | Description                                                                                                  | Value |
| ------------------- | ------------------------------------------------------------------------------------------------------------ | ----- |
| `kubeVersion`       | Force target Kubernetes version (using Helm capabilities if not set)                                         | `""`  |
| `nameOverride`      | String to partially override testlink.fullname template (will maintain the release name)                     | `""`  |
| `fullnameOverride`  | String to fully override testlink.fullname template                                                          | `""`  |
| `commonAnnotations` | Common annotations to add to all TestLink resources (sub-charts are not considered). Evaluated as a template | `{}`  |
| `commonLabels`      | Common labels to add to all TestLink resources (sub-charts are not considered). Evaluated as a template      | `{}`  |
| `extraDeploy`       | Array with extra yaml to deploy with the chart. Evaluated as a template                                      | `[]`  |


### TestLink parameters

| Name                                    | Description                                                                               | Value                   |
| --------------------------------------- | ----------------------------------------------------------------------------------------- | ----------------------- |
| `image.registry`                        | TestLink image registry                                                                   | `docker.io`             |
| `image.repository`                      | TestLink image repository                                                                 | `bitnami/testlink`      |
| `image.tag`                             | TestLink Image tag (immutable tags are recommended)                                       | `1.9.20-debian-10-r607` |
| `image.pullPolicy`                      | TestLink image pull policy                                                                | `IfNotPresent`          |
| `image.pullSecrets`                     | Specify docker-registry secret names as an array                                          | `[]`                    |
| `image.debug`                           | Specify if debug logs should be enabled                                                   | `false`                 |
| `replicaCount`                          | Number of replicas (requires ReadWriteMany PVC support)                                   | `1`                     |
| `hostAliases`                           | Deployment pod host aliases                                                               | `[]`                    |
| `testlinkSkipInstall`                   | Skip TestLink installation wizard. Useful for migrations and restoring from SQL dump      | `false`                 |
| `testlinkUsername`                      | User of the application                                                                   | `user`                  |
| `testlinkPassword`                      | Application password                                                                      | `""`                    |
| `testlinkEmail`                         | Admin email                                                                               | `user@example.com`      |
| `testlinkLanguage`                      | Default language                                                                          | `en_US`                 |
| `allowEmptyPassword`                    | Allow DB blank passwords                                                                  | `true`                  |
| `command`                               | Override default container command (useful when using custom images)                      | `[]`                    |
| `args`                                  | Override default container args (useful when using custom images)                         | `[]`                    |
| `updateStrategy.type`                   | Update strategy - only really applicable for deployments with RWO PVs attached            | `RollingUpdate`         |
| `extraEnvVars`                          | An array to add extra environment variables                                               | `[]`                    |
| `extraEnvVarsCM`                        | ConfigMap containing extra environment variables                                          | `""`                    |
| `extraEnvVarsSecret`                    | Secret containing extra environment variables                                             | `""`                    |
| `extraVolumes`                          | Extra volumes to add to the deployment. Requires setting `extraVolumeMounts`              | `[]`                    |
| `extraVolumeMounts`                     | Extra volume mounts to add to the container. Normally used with `extraVolumes`            | `[]`                    |
| `initContainers`                        | Extra init containers to add to the deployment                                            | `[]`                    |
| `sidecars`                              | Extra sidecar containers to add to the deployment                                         | `[]`                    |
| `tolerations`                           | Tolerations for pod assignment. Evaluated as a template.                                  | `[]`                    |
| `priorityClassName`                     | TestLink pods' priorityClassName                                                          | `""`                    |
| `schedulerName`                         | Name of the k8s scheduler (other than default)                                            | `""`                    |
| `topologySpreadConstraints`             | Topology Spread Constraints for pod assignment                                            | `[]`                    |
| `existingSecret`                        | Use existing secret for the application password                                          | `""`                    |
| `smtpHost`                              | SMTP host                                                                                 | `""`                    |
| `smtpPort`                              | SMTP port                                                                                 | `""`                    |
| `smtpUser`                              | SMTP user                                                                                 | `""`                    |
| `smtpPassword`                          | SMTP password                                                                             | `""`                    |
| `smtpProtocol`                          | SMTP Protocol (options: ssl, tls, nil)                                                    | `""`                    |
| `containerPorts`                        | Container ports                                                                           | `{}`                    |
| `sessionAffinity`                       | Control where client requests go, to the same pod or round-robin                          | `None`                  |
| `persistence.enabled`                   | Enable persistence using PVC                                                              | `true`                  |
| `persistence.storageClass`              | TestLink Data Persistent Volume Storage Class                                             | `""`                    |
| `persistence.accessModes`               | PVC Access Mode for TestLink volume                                                       | `["ReadWriteOnce"]`     |
| `persistence.size`                      | PVC Storage Request for TestLink volume                                                   | `8Gi`                   |
| `persistence.existingClaim`             | An Existing PVC name                                                                      | `""`                    |
| `persistence.hostPath`                  | Host mount path for TestLink volume                                                       | `""`                    |
| `persistence.annotations`               | Persistent Volume Claim annotations                                                       | `{}`                    |
| `podAffinityPreset`                     | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`       | `""`                    |
| `podAntiAffinityPreset`                 | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`  | `soft`                  |
| `nodeAffinityPreset.type`               | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `""`                    |
| `nodeAffinityPreset.key`                | Node label key to match Ignored if `affinity` is set.                                     | `""`                    |
| `nodeAffinityPreset.values`             | Node label values to match. Ignored if `affinity` is set.                                 | `[]`                    |
| `affinity`                              | Affinity for pod assignment                                                               | `{}`                    |
| `nodeSelector`                          | Node labels for pod assignment. Evaluated as a template.                                  | `{}`                    |
| `resources.requests`                    | The requested resources for the container                                                 | `{}`                    |
| `resources.limits`                      | The resources limits for the container                                                    | `{}`                    |
| `podSecurityContext.enabled`            | Enable TestLink pods' Security Context                                                    | `true`                  |
| `podSecurityContext.fsGroup`            | TestLink pods' group ID                                                                   | `1001`                  |
| `containerSecurityContext.enabled`      | Enable TestLink containers' Security Context                                              | `true`                  |
| `containerSecurityContext.runAsUser`    | TestLink containers' Security Context runAsUser                                           | `1001`                  |
| `containerSecurityContext.runAsNonRoot` | TestLink containers' Security Context runAsNonRoot                                        | `true`                  |
| `startupProbe.enabled`                  | Enable startupProbe                                                                       | `false`                 |
| `startupProbe.path`                     | Request path for startupProbe                                                             | `/login.php`            |
| `startupProbe.initialDelaySeconds`      | Initial delay seconds for startupProbe                                                    | `120`                   |
| `startupProbe.periodSeconds`            | Period seconds for startupProbe                                                           | `10`                    |
| `startupProbe.timeoutSeconds`           | Timeout seconds for startupProbe                                                          | `5`                     |
| `startupProbe.failureThreshold`         | Failure threshold for startupProbe                                                        | `6`                     |
| `startupProbe.successThreshold`         | Success threshold for startupProbe                                                        | `1`                     |
| `livenessProbe.enabled`                 | Enable livenessProbe                                                                      | `true`                  |
| `livenessProbe.path`                    | Request path for livenessProbe                                                            | `/login.php`            |
| `livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                                   | `120`                   |
| `livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                          | `10`                    |
| `livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                         | `5`                     |
| `livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                       | `6`                     |
| `livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                       | `1`                     |
| `readinessProbe.enabled`                | Enable readinessProbe                                                                     | `true`                  |
| `readinessProbe.path`                   | Request path for readinessProbe                                                           | `/login.php`            |
| `readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                                  | `30`                    |
| `readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                         | `5`                     |
| `readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                        | `3`                     |
| `readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                      | `6`                     |
| `readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                      | `1`                     |
| `customStartupProbe`                    | Override default startup probe                                                            | `{}`                    |
| `customLivenessProbe`                   | Override default liveness probe                                                           | `{}`                    |
| `customReadinessProbe`                  | Override default readiness probe                                                          | `{}`                    |
| `lifecycleHooks`                        | Lifecycle hooks for the container to automate configuration before or after startup       | `{}`                    |
| `podAnnotations`                        | Pod annotations                                                                           | `{}`                    |
| `podLabels`                             | Pod extra labels                                                                          | `{}`                    |


### Traffic Exposure Parameters

| Name                               | Description                                                                                                                      | Value                    |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `service.type`                     | Kubernetes Service type                                                                                                          | `LoadBalancer`           |
| `service.ports.http`               | Service HTTP port                                                                                                                | `80`                     |
| `service.ports.https`              | Service HTTPS port                                                                                                               | `443`                    |
| `service.clusterIP`                | Service cluster IP                                                                                                               | `""`                     |
| `service.loadBalancerSourceRanges` | Control hosts connecting to "LoadBalancer" only                                                                                  | `[]`                     |
| `service.loadBalancerIP`           | Load balancer IP for the TestLink Service (optional, cloud specific)                                                             | `""`                     |
| `service.nodePorts.http`           | Kubernetes HTTP node port                                                                                                        | `""`                     |
| `service.nodePorts.https`          | Kubernetes HTTPS node port                                                                                                       | `""`                     |
| `service.externalTrafficPolicy`    | Enable client source IP preservation                                                                                             | `Cluster`                |
| `service.extraPorts`               | Extra ports to expose (normally used with the `sidecar` value)                                                                   | `[]`                     |
| `service.annotations`              | Additional custom annotations for TestLink service                                                                               | `{}`                     |
| `service.sessionAffinity`          | Session Affinity for Kubernetes service, can be "None" or "ClientIP"                                                             | `None`                   |
| `service.sessionAffinityConfig`    | Additional settings for the sessionAffinity                                                                                      | `{}`                     |
| `ingress.enabled`                  | Enable ingress controller resource                                                                                               | `false`                  |
| `ingress.pathType`                 | Ingress path type                                                                                                                | `ImplementationSpecific` |
| `ingress.apiVersion`               | Force Ingress API version (automatically detected if not set)                                                                    | `""`                     |
| `ingress.hostname`                 | Default host for the ingress resource                                                                                            | `testlink.local`         |
| `ingress.path`                     | Ingress path                                                                                                                     | `/`                      |
| `ingress.annotations`              | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. | `{}`                     |
| `ingress.tls`                      | Enable TLS configuration for the host defined at `ingress.hostname` parameter                                                    | `false`                  |
| `ingress.extraHosts`               | An array with additional hostname(s) to be covered with the ingress record                                                       | `[]`                     |
| `ingress.extraPaths`               | An array with additional arbitrary paths that may need to be added to the ingress under the main host                            | `[]`                     |
| `ingress.extraTls`                 | TLS configuration for additional hostname(s) to be covered with this ingress record                                              | `[]`                     |
| `ingress.secrets`                  | If you're providing your own certificates, please use this to add the certificates as secrets                                    | `[]`                     |
| `ingress.ingressClassName`         | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)                                                    | `""`                     |


### NetworkPolicy parameters

| Name                                                          | Description                                                                                                                  | Value   |
| ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ------- |
| `networkPolicy.enabled`                                       | Enable network policies                                                                                                      | `false` |
| `networkPolicy.metrics.enabled`                               | Enable network policy for metrics (prometheus)                                                                               | `false` |
| `networkPolicy.metrics.namespaceSelector`                     | Monitoring namespace selector labels. These labels will be used to identify the prometheus' namespace.                       | `{}`    |
| `networkPolicy.metrics.podSelector`                           | Monitoring pod selector labels. These labels will be used to identify the Prometheus pods.                                   | `{}`    |
| `networkPolicy.ingress.enabled`                               | Enable network policy for Ingress Proxies                                                                                    | `false` |
| `networkPolicy.ingress.namespaceSelector`                     | Ingress Proxy namespace selector labels. These labels will be used to identify the Ingress Proxy's namespace.                | `{}`    |
| `networkPolicy.ingress.podSelector`                           | Ingress Proxy pods selector labels. These labels will be used to identify the Ingress Proxy pods.                            | `{}`    |
| `networkPolicy.ingressRules.backendOnlyAccessibleByFrontend`  | Enable ingress rule that makes the backend (mariadb) only accessible by testlink's pods.                                     | `false` |
| `networkPolicy.ingressRules.customBackendSelector`            | Backend selector labels. These labels will be used to identify the backend pods.                                             | `{}`    |
| `networkPolicy.ingressRules.accessOnlyFrom.enabled`           | Enable ingress rule that makes testlink only accessible from a particular origin                                             | `false` |
| `networkPolicy.ingressRules.accessOnlyFrom.namespaceSelector` | Namespace selector label that is allowed to access testlink. This label will be used to identified the allowed namespace(s). | `{}`    |
| `networkPolicy.ingressRules.accessOnlyFrom.podSelector`       | Pods selector label that is allowed to access testlink. This label will be used to identified the allowed pod(s).            | `{}`    |
| `networkPolicy.ingressRules.customRules`                      | Custom network policy ingress rule                                                                                           | `{}`    |
| `networkPolicy.egressRules.denyConnectionsToExternal`         | Enable egress rule that denies outgoing traffic outside the cluster, except for DNS (port 53).                               | `false` |
| `networkPolicy.egressRules.customRules`                       | Custom network policy rule                                                                                                   | `{}`    |


### Database parameters

| Name                                        | Description                                                                              | Value               |
| ------------------------------------------- | ---------------------------------------------------------------------------------------- | ------------------- |
| `mariadb.enabled`                           | Whether to deploy a mariadb server to satisfy the applications database requirements     | `true`              |
| `mariadb.architecture`                      | MariaDB architecture. Allowed values: `standalone` or `replication`                      | `standalone`        |
| `mariadb.auth.rootPassword`                 | Password for the MariaDB `root` user                                                     | `""`                |
| `mariadb.auth.database`                     | Database name to create                                                                  | `bitnami_testlink`  |
| `mariadb.auth.username`                     | Database user to create                                                                  | `bn_testlink`       |
| `mariadb.auth.password`                     | Password for the database                                                                | `""`                |
| `mariadb.primary.persistence.enabled`       | Enable database persistence using PVC                                                    | `true`              |
| `mariadb.primary.persistence.storageClass`  | MariaDB primary persistent volume storage Class                                          | `""`                |
| `mariadb.primary.persistence.accessModes`   | Database Persistent Volume Access Modes                                                  | `["ReadWriteOnce"]` |
| `mariadb.primary.persistence.size`          | Database Persistent Volume Size                                                          | `8Gi`               |
| `mariadb.primary.persistence.hostPath`      | Set path in case you want to use local host path volumes (not recommended in production) | `""`                |
| `mariadb.primary.persistence.existingClaim` | Name of an existing `PersistentVolumeClaim` for MariaDB primary replicas                 | `""`                |
| `externalDatabase.host`                     | Host of the existing database                                                            | `""`                |
| `externalDatabase.port`                     | Port of the existing database                                                            | `3306`              |
| `externalDatabase.user`                     | Existing username in the external database                                               | `bn_testlink`       |
| `externalDatabase.password`                 | Password for the above username                                                          | `""`                |
| `externalDatabase.database`                 | Name of the existing database                                                            | `bitnami_testlink`  |
| `externalDatabase.existingSecret`           | Name of an existing secret resource containing the DB password                           | `""`                |


### Volume Permissions parameters

| Name                                   | Description                                                                                                                                               | Value                   |
| -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| `volumePermissions.enabled`            | Enable init container that changes volume permissions in the data directory (for cases where the default k8s `runAsUser` and `fsUser` values do not work) | `false`                 |
| `volumePermissions.image.registry`     | Init container volume-permissions image registry                                                                                                          | `docker.io`             |
| `volumePermissions.image.repository`   | Init container volume-permissions image repository                                                                                                        | `bitnami/bitnami-shell` |
| `volumePermissions.image.tag`          | Init container volume-permissions image tag (immutable tags are recommended)                                                                              | `10-debian-10-r305`     |
| `volumePermissions.image.pullPolicy`   | Init container volume-permissions image pull policy                                                                                                       | `IfNotPresent`          |
| `volumePermissions.image.pullSecrets`  | Specify docker-registry secret names as an array                                                                                                          | `[]`                    |
| `volumePermissions.resources.limits`   | The resources limits for the container                                                                                                                    | `{}`                    |
| `volumePermissions.resources.requests` | The requested resources for the container                                                                                                                 | `{}`                    |


### Metrics parameters

| Name                        | Description                                                | Value                     |
| --------------------------- | ---------------------------------------------------------- | ------------------------- |
| `metrics.enabled`           | Start a side-car prometheus exporter                       | `false`                   |
| `metrics.image.registry`    | Apache exporter image registry                             | `docker.io`               |
| `metrics.image.repository`  | Apache exporter image repository                           | `bitnami/apache-exporter` |
| `metrics.image.tag`         | Apache exporter image tag (immutable tags are recommended) | `0.11.0-debian-10-r23`    |
| `metrics.image.pullPolicy`  | Image pull policy                                          | `IfNotPresent`            |
| `metrics.image.pullSecrets` | Specify docker-registry secret names as an array           | `[]`                      |
| `metrics.resources`         | Metrics exporter resource requests and limits              | `{}`                      |
| `metrics.podAnnotations`    | Additional annotations for Metrics exporter pod            | `{}`                      |


### Certificate injection parameters

| Name                                                 | Description                                                          | Value                                    |
| ---------------------------------------------------- | -------------------------------------------------------------------- | ---------------------------------------- |
| `certificates.customCertificate.certificateSecret`   | Secret containing the certificate and key to add                     | `""`                                     |
| `certificates.customCertificate.chainSecret.name`    | Name of the secret containing the certificate chain                  | `""`                                     |
| `certificates.customCertificate.chainSecret.key`     | Key of the certificate chain file inside the secret                  | `""`                                     |
| `certificates.customCertificate.certificateLocation` | Location in the container to store the certificate                   | `/etc/ssl/certs/ssl-cert-snakeoil.pem`   |
| `certificates.customCertificate.keyLocation`         | Location in the container to store the private key                   | `/etc/ssl/private/ssl-cert-snakeoil.key` |
| `certificates.customCertificate.chainLocation`       | Location in the container to store the certificate chain             | `/etc/ssl/certs/mychain.pem`             |
| `certificates.customCAs`                             | Defines a list of secrets to import into the container trust store   | `[]`                                     |
| `certificates.command`                               | Override default container command (useful when using custom images) | `[]`                                     |
| `certificates.args`                                  | Override default container args (useful when using custom images)    | `[]`                                     |
| `certificates.extraEnvVars`                          | Container sidecar extra environment variables (eg proxy)             | `[]`                                     |
| `certificates.extraEnvVarsCM`                        | ConfigMap containing extra env vars                                  | `""`                                     |
| `certificates.extraEnvVarsSecret`                    | Secret containing extra env vars (in case of sensitive data)         | `""`                                     |
| `certificates.image.registry`                        | Container sidecar registry                                           | `docker.io`                              |
| `certificates.image.repository`                      | Container sidecar image repository                                   | `bitnami/bitnami-shell`                  |
| `certificates.image.tag`                             | Container sidecar image tag (immutable tags are recommended)         | `10-debian-10-r305`                      |
| `certificates.image.pullPolicy`                      | Container sidecar image pull policy                                  | `IfNotPresent`                           |
| `certificates.image.pullSecrets`                     | Container sidecar image pull secrets                                 | `[]`                                     |


The above parameters map to the env variables defined in [bitnami/testlink](https://github.com/bitnami/bitnami-docker-testlink). For more information please refer to the [bitnami/testlink](https://github.com/bitnami/bitnami-docker-testlink) image documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install my-release \
  --set testlinkUsername=admin,testlinkPassword=password,mariadb.auth.rootPassword=secretpassword \
    bitnami-azure/testlink
```

The above command sets the TestLink administrator account username and password to `admin` and `password` respectively. Additionally, it sets the MariaDB `root` user password to `secretpassword`.

> NOTE: Once this chart is deployed, it is not possible to change the application's access credentials, such as usernames or passwords, using Helm. To change these application credentials after deployment, delete any persistent volumes (PVs) used by the chart and re-deploy it, or use the application's built-in administrative tools if available.

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install my-release -f values.yaml bitnami-azure/testlink
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Configuration and installation details

### [Rolling VS Immutable tags](https://docs.bitnami.com/containers/how-to/understand-rolling-tags-containers/)

It is strongly recommended to use immutable tags in a production environment. This ensures your deployment does not change automatically if the same tag is updated with a different image.

Bitnami will release a new chart updating its containers if a new version of the main container, significant changes, or critical vulnerabilities exist.

### Image

The `image` parameter allows specifying which image will be pulled for the chart.

#### Private registry

If you configure the `image` value to one in a private registry, you will need to [specify an image pull secret](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod).

1. Manually create image pull secret(s) in the namespace. See [this YAML example reference](https://kubernetes.io/docs/concepts/containers/images/#creating-a-secret-with-a-docker-config). Consult your image registry's documentation about getting the appropriate secret.
2. Note that the `imagePullSecrets` configuration value cannot currently be passed to helm using the `--set` parameter, so you must supply these using a `values.yaml` file, such as:

```yaml
imagePullSecrets:
  - name: SECRET_NAME
```

3. Install the chart

### Setting Pod's affinity

This chart allows you to set your custom affinity using the `affinity` parameter. Find more information about Pod's affinity in the [kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity).

As an alternative, you can use of the preset configurations for pod affinity, pod anti-affinity, and node affinity available at the [bitnami/common](https://github.com/bitnami/charts/tree/master/bitnami/common#affinities) chart. To do so, set the `podAffinityPreset`, `podAntiAffinityPreset`, or `nodeAffinityPreset` parameters.

## Persistence

The [Bitnami TestLink](https://github.com/bitnami/bitnami-docker-testlink) image stores the TestLink data and configurations at the `/bitnami/testlink` path of the container.

Persistent Volume Claims are used to keep the data across deployments. This is known to work in GCE, AWS, and minikube.
See the [Parameters](#parameters) section to configure the PVC or to disable persistence.

### Existing PersistentVolumeClaim

1. Create the PersistentVolume
1. Create the PersistentVolumeClaim
1. Install the chart

```bash
$ helm install my-release --set persistence.existingClaim=PVC_NAME bitnami-azure/prestashop
```

### Host path

#### System compatibility

- The local filesystem accessibility to a container in a pod with `hostPath` has been tested on OSX/MacOS with xhyve, and Linux with VirtualBox.
- Windows has not been tested with the supported VM drivers. Minikube does however officially support [Mounting Host Folders](https://minikube.sigs.k8s.io/docs/handbook/mount/) per pod. Or you may manually sync your container whenever host files are changed with tools like [docker-sync](https://github.com/EugenMayer/docker-sync) or [docker-bg-sync](https://github.com/cweagans/docker-bg-sync).

#### Mounting steps

1. The specified `hostPath` directory must already exist (create one if it does not).
2. Install the chart

    ```bash
    $ helm install my-release --set persistence.hostPath=/PATH/TO/HOST/MOUNT bitnami-azure/prestashop
    ```

    This will mount the `prestashop-data` volume into the `hostPath` directory. The site data will be persisted if the mount path contains valid data, else the site data will be initialized at first launch.
3. Because the container cannot control the host machine's directory permissions, you must set the PrestaShop file directory permissions yourself and disable or clear PrestaShop cache.

## Troubleshooting

Find more information about how to deal with common errors related to Bitnami's Helm charts in [this troubleshooting guide](https://docs.bitnami.com/general/how-to/troubleshoot-helm-chart-issues).

## Upgrading

### To 10.0.0

This major release renames several values in this chart and adds missing features, in order to be inline with the rest of assets in the Bitnami charts repository.

Affected values:

- `service.port` was deprecated. We recommend using `service.ports.http` instead.
- `service.httpsPort` was deprecated. We recommend using `service.ports.https` instead.
- `ingress.hosts` was renamed as `ingress.extraHosts`
- `ingress.tls` is now a boolean flag to enable/disable ingress TLS. Previous `ingress.tls` was renamed as `ingress.extraTls`.

Additionally updates the MariaDB subchart to it newest major, 10.0.0, which contains similar changes. Check [MariaDB Upgrading Notes](https://github.com/bitnami/charts/tree/master/bitnami/mariadb#to-1000) for more information.

### To 9.0.0

[On November 13, 2020, Helm v2 support was formally finished](https://github.com/helm/charts#status-of-the-project), this major version is the result of the required changes applied to the Helm Chart to be able to incorporate the different features added in Helm v3 and to be consistent with the Helm project itself regarding the Helm v2 EOL.

**What changes were introduced in this major version?**

- Previous versions of this Helm Chart use `apiVersion: v1` (installable by both Helm 2 and 3), this Helm Chart was updated to `apiVersion: v2` (installable by Helm 3 only). [Here](https://helm.sh/docs/topics/charts/#the-apiversion-field) you can find more information about the `apiVersion` field.
- Move dependency information from the *requirements.yaml* to the *Chart.yaml*
- After running `helm dependency update`, a *Chart.lock* file is generated containing the same structure used in the previous *requirements.lock*
- The different fields present in the *Chart.yaml* file has been ordered alphabetically in a homogeneous way for all the Bitnami Helm Charts

**Considerations when upgrading to this version**

- If you want to upgrade to this version from a previous one installed with Helm v3, you shouldn't face any issues
- If you want to upgrade to this version using Helm v2, this scenario is not supported as this version doesn't support Helm v2 anymore
- If you installed the previous version with Helm v2 and wants to upgrade to this version with Helm v3, please refer to the [official Helm documentation](https://helm.sh/docs/topics/v2_v3_migration/#migration-use-cases) about migrating from Helm v2 to v3

**Useful links**

- https://docs.bitnami.com/tutorials/resolve-helm2-helm3-post-migration-issues/
- https://helm.sh/docs/topics/v2_v3_migration/
- https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/

### To 8.0.0

The [Bitnami TestLink](https://github.com/bitnami/bitnami-docker-testlink) image was migrated to a "non-root" user approach. Previously the container ran as the `root` user and the Apache daemon was started as the `daemon` user. From now on, both the container and the Apache daemon run as user `1001`. You can revert this behavior by setting the parameters `containerSecurityContext.runAsUser` to `root`.

Consequences:

- The HTTP/HTTPS ports exposed by the container are now `8080/8443` instead of `80/443`.
- Backwards compatibility is not guaranteed.

To upgrade to `8.0.0`, backup TestLink data and the previous MariaDB databases, install a new TestLink chart and import the backups and data, ensuring the `1001` user has the appropriate permissions on the migrated volume.

This upgrade also adapts the chart to the latest Bitnami good practices. Check the Parameters section for more information.

MariaDB dependency version was bumped to a new major version that introduces several incompatilibites. Therefore, backwards compatibility is not guaranteed unless an external database is used. Check [MariaDB Upgrading Notes](https://github.com/bitnami/charts/tree/master/bitnami/mariadb#to-800) for more information.

### To 7.0.0

Helm performs a lookup for the object based on its group (apps), version (v1), and kind (Deployment). Also known as its GroupVersionKind, or GVK. Changing the GVK is considered a compatibility breaker from Kubernetes' point of view, so you cannot "upgrade" those objects to the new GVK in-place. Earlier versions of Helm 3 did not perform the lookup correctly which has since been fixed to match the spec.

In https://github.com/helm/charts/pull/17311 the `apiVersion` of the deployment resources was updated to `apps/v1` in tune with the api's deprecated, resulting in compatibility breakage.

This major version signifies this change.

### To 3.0.0

Backwards compatibility is not guaranteed unless you modify the labels used on the chart's deployments.
Use the workaround below to upgrade from versions previous to 3.0.0. The following example assumes that the release name is testlink:

```console
$ kubectl patch deployment testlink-testlink --type=json -p='[{"op": "remove", "path": "/spec/selector/matchLabels/chart"}]'
$ kubectl delete statefulset testlink-mariadb --cascade=false
```

## License

Copyright &copy; 2022 Bitnami

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.