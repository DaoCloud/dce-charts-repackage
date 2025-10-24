# topohub

![Version: 0.4.2](https://img.shields.io/badge/Version-0.4.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.4.2](https://img.shields.io/badge/AppVersion-0.4.2-informational?style=flat-square)

Topohub is a set of Kubernetes components for managing infrastructure, including hosts, switches, and more.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://infrastructure-io.github.io/topohub | topohub | 0.4.2 |

## Values

| Key                                      | Type   | Default       | Description                                                        |
|------------------------------------------|--------|---------------|--------------------------------------------------------------------|
| topohub.replicaCount                     | int    | `1`           | Number of replicas for topohub                                      |
| topohub.registryOverride                 | string | `""`          | Registry override for topohub                                      |
| topohub.imagePullSecrets                 | list   | `[]`          | List of image pull secrets                                          |
| topohub.nameOverride                     | string | `""`          | Override for the topohub name                                      |
| topohub.fullnameOverride                 | string | `""`          | Override for the full name of topohub                              |
| topohub.image.registry                   | string | `"ghcr.m.daocloud.io"` | Image registry address                                           |
| topohub.image.repository                 | string | `"infrastructure-io/topohub"` | Image repository name                                            |
| topohub.image.pullPolicy                 | string | `"IfNotPresent"` | Image pull policy                                                |
| topohub.image.tag                        | string | `"v0.4.2"`    | Image tag, overridden by version from Chart.yaml                  |
| topohub.resources.limits.cpu             | string | `"500m"`      | CPU limit for topohub                                             |
| topohub.resources.limits.memory          | string | `"512Mi"`     | Memory limit for topohub                                          |
| topohub.resources.requests.cpu            | string | `"100m"`      | CPU request for topohub                                           |
| topohub.resources.requests.memory         | string | `"128Mi"`     | Memory request for topohub                                        |
| topohub.defaultConfig.redfish.port       | int    | `443`         | Port for the Redfish endpoint                                      |
| topohub.defaultConfig.redfish.https      | bool   | `true`        | Enable HTTPS for Redfish                                           |
| topohub.defaultConfig.redfish.username    | string | `"admin"`     | Username for Redfish authentication                                 |
| topohub.defaultConfig.redfish.password    | string | `"secret"`    | Password for Redfish authentication                                 |
| topohub.defaultConfig.redfish.hostStatusUpdateInterval | int | `60`   | Status update interval in seconds for Redfish                     |
| topohub.defaultConfig.dhcpServer.interface | string | `""`         | Host network interface for DHCP server                             |
| topohub.defaultConfig.dhcpServer.expireTime | string | `"1d"`       | Expiration time for DHCP leases in the format of 1 day           |
| topohub.defaultConfig.httpServer.enabled   | bool   | `true`       | Enable HTTP server for ISO and ZTP in DHCP subnet                 |
| topohub.defaultConfig.httpServer.port      | int    | `80`         | Port for the HTTP server                                           |
| topohub.storage.type                      | string | `"hostPath"`  | Storage type for lease and config files                            |
| topohub.storage.pvc.storageClass          | string | `""`          | Storage class for PVCs                                            |
| topohub.storage.pvc.size                  | string | `"10Gi"`     | Storage size for new PVCs                                         |
| topohub.storage.pvc.accessModes           | list   | `["ReadWriteOnce"]` | Access modes for PVC                                       |
| topohub.storage.hostPath.path             | string | `"/var/lib/topohub"` | Path on the host for HostPath storage                  |
| topohub.logLevel                         | string | `"info"`      | Log level configuration                                            |
| topohub.metricsPort                      | int    | `8083`        | Port for the metrics probes                                             |
| topohub.webhook.webhookPort              | int    | `8082`        | Port for the webhook server                                        |
| topohub.webhook.timeoutSeconds            | int    | `5`           | Timeout for webhook calls in seconds                              |
| topohub.webhook.failurePolicy             | string | `"Fail"`      | Failure policy for webhook                                         |
| topohub.webhook.certificate.validityDays | int    | `36500`       | Validity duration of the webhook certificate in days              |
| topohub.serviceAccount.create             | bool   | `true`        | Specifies whether to create a service account                      |
| topohub.serviceAccount.name               | string | `""`          | Name of the service account, generated if not set                 |
| topohub.podAnnotations                    | object | `{}`          | Annotations to add to the pod                                      |
----------------------------------------------

## Configuration and installation details

### Quick Install

```bash
helm repo add topohub https://infrastructure-io.github.io/topohub
helm repo update

# Create configuration file
cat << EOF > values.yaml
replicaCount: 1

# For users in China, you can use the following Chinese mirror source
#image:
#  registry: "ghcr.m.daocloud.io"

defaultConfig:
  redfish:
    # Default username to connect to the host BMC
    username: "<<BmcDefaultUsername>>"
    # Default password to connect to the host BMC
    password: "<<BmcDefaultPassword>>"
  dhcpServer:
    # The network interface name that can access all management device networks on the node, which is connected to the switch in trunk mode
    interface: "eth1"

storage:
  # Use hostPath for POC scenarios; please use PVC in production environments
  type: "hostPath"

fileBrowser:
  # Enable filebrowser service, which provides a web UI to manage configuration files and ISO files
  enabled: true

  # For users in China, you can use the following Chinese mirror source
  #image:
  #  registry: "docker.m.daocloud.io"
EOF

# Install Topohub components
helm install topohub topohub/topohub \
    --namespace topohub  --create-namespace  --wait \
    -f values.yaml
```
