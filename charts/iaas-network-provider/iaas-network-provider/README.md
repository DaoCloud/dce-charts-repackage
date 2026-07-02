# iaas-network-provider

![Version: 0.1.0-rc1](https://img.shields.io/badge/Version-0.1.0--rc1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0-rc1](https://img.shields.io/badge/AppVersion-0.1.0--rc1-informational?style=flat-square)

IaaS Network Provider — IPAM bridge between Spiderpool and Huawei Cloud

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://ghcr.io/daocloud/charts | iaas-network-provider | 0.1.0-rc1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| iaas-network-provider.affinity | object | `{}` |  |
| iaas-network-provider.config.bindAddress | string | `":8443"` |  |
| iaas-network-provider.config.cache.iaasNetCacheTTLMinutes | int | `240` |  |
| iaas-network-provider.config.cache.preloadOnStartup | bool | `true` |  |
| iaas-network-provider.config.iaasProvider.auth.aksk.credentialsSecret | string | `"huawei-credentials"` |  |
| iaas-network-provider.config.iaasProvider.auth.mode | string | `"token"` |  |
| iaas-network-provider.config.iaasProvider.auth.token.agencyName | string | `""` |  |
| iaas-network-provider.config.iaasProvider.auth.token.iamDomain | string | `""` |  |
| iaas-network-provider.config.iaasProvider.auth.token.iamEndpoint | string | `""` |  |
| iaas-network-provider.config.iaasProvider.auth.token.password | string | `""` |  |
| iaas-network-provider.config.iaasProvider.auth.token.scEndpoint | string | `""` |  |
| iaas-network-provider.config.iaasProvider.auth.token.tokenRefreshBeforeExpiry | string | `"1h"` |  |
| iaas-network-provider.config.iaasProvider.auth.token.tokenRefreshFailThreshold | int | `3` |  |
| iaas-network-provider.config.iaasProvider.auth.token.tokenRefreshInterval | string | `"23h"` |  |
| iaas-network-provider.config.iaasProvider.auth.token.tokenRefreshRetryInterval | string | `"30s"` |  |
| iaas-network-provider.config.iaasProvider.auth.token.trustTenantName | string | `""` |  |
| iaas-network-provider.config.iaasProvider.auth.token.username | string | `""` |  |
| iaas-network-provider.config.iaasProvider.ecsEndpoint | string | `""` |  |
| iaas-network-provider.config.iaasProvider.endpoint | string | `""` |  |
| iaas-network-provider.config.iaasProvider.projectID | string | `""` |  |
| iaas-network-provider.config.iaasProvider.projectName | string | `""` |  |
| iaas-network-provider.config.iaasProvider.provider | string | `"huaweicloud"` |  |
| iaas-network-provider.config.iaasProvider.region | string | `""` |  |
| iaas-network-provider.config.iaasProvider.securityGroups | list | `[]` |  |
| iaas-network-provider.config.iaasProvider.vpcEndpoint | string | `""` |  |
| iaas-network-provider.config.k8sClientConfig.burst | int | `400` |  |
| iaas-network-provider.config.k8sClientConfig.qps | int | `200` |  |
| iaas-network-provider.config.leaderElection.enabled | bool | `true` |  |
| iaas-network-provider.config.leaderElection.leaseDurationSeconds | int | `60` |  |
| iaas-network-provider.config.leaderElection.leaseName | string | `"iaas-network-provider-leader"` |  |
| iaas-network-provider.config.leaderElection.leaseNamespace | string | `"{{ .Release.Namespace }}"` |  |
| iaas-network-provider.config.leaderElection.renewDeadlineSeconds | int | `40` |  |
| iaas-network-provider.config.leaderElection.retryPeriodSeconds | int | `15` |  |
| iaas-network-provider.config.logLevel | string | `"info"` |  |
| iaas-network-provider.config.rateLimit.maxTransactionTimeoutSeconds | int | `16` |  |
| iaas-network-provider.config.rateLimit.qps | int | `2` |  |
| iaas-network-provider.config.rateLimit.queueTimeoutSeconds | int | `30` |  |
| iaas-network-provider.config.tls.certFile | string | `"/etc/iaas-network-provider/tls/tls.crt"` |  |
| iaas-network-provider.config.tls.keyFile | string | `"/etc/iaas-network-provider/tls/tls.key"` |  |
| iaas-network-provider.hostAliases | list | `[]` |  |
| iaas-network-provider.image.pullPolicy | string | `"IfNotPresent"` |  |
| iaas-network-provider.image.registry | string | `"ghcr.m.daocloud.io"` |  |
| iaas-network-provider.image.repository | string | `"daocloud/iaas-network-provider/controller"` |  |
| iaas-network-provider.image.tag | string | `"v0.1.0-rc1"` |  |
| iaas-network-provider.nodeSelector | object | `{}` |  |
| iaas-network-provider.replicaCount | int | `1` |  |
| iaas-network-provider.resources.limits.cpu | string | `"500m"` |  |
| iaas-network-provider.resources.limits.memory | string | `"256Mi"` |  |
| iaas-network-provider.resources.requests.cpu | string | `"100m"` |  |
| iaas-network-provider.resources.requests.memory | string | `"128Mi"` |  |
| iaas-network-provider.service.nodePort.http | string | `""` |  |
| iaas-network-provider.service.nodePort.https | string | `""` |  |
| iaas-network-provider.service.port | int | `8080` |  |
| iaas-network-provider.service.tlsPort | int | `443` |  |
| iaas-network-provider.service.type | string | `"ClusterIP"` |  |
| iaas-network-provider.serviceAccount.create | bool | `true` |  |
| iaas-network-provider.serviceAccount.name | string | `"iaas-network-provider"` |  |
| iaas-network-provider.tls.autoGenerate | bool | `true` |  |
| iaas-network-provider.tls.certValidityDays | int | `36500` |  |
| iaas-network-provider.tls.enabled | bool | `true` |  |
| iaas-network-provider.tls.existingSecret | string | `""` |  |
| iaas-network-provider.tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
