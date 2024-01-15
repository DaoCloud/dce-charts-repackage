## Overview

The Knative Operator defines custom resources for the Knative components, including serving and eventing, enabling users to configure, install, upgrade and maintain these components over their lifecycle through a simple API.

## Install

```shell
helm repo add daocloud-addon https://release.daocloud.io/chartrepo/addon
helm install knative-operator -f values.yml --wait --debug daocloud-addon/knative-operator
helm ls
```
## Parameters

### operator parameters

| Name                              | Description                                                                               | Value                                                       |
| --------------------------------- | ----------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| `operator.image.registry`         | The image registry of operator                                                            | `m.daocloud.io`                                             |
| `operator.image.repository`       | The image repository of operator                                                          | `gcr.io/knative-releases/knative.dev/operator/cmd/operator` |
| `operator.image.pullPolicy`       | The image pull policy of operator                                                         | `IfNotPresent`                                              |
| `operator.image.digest`           | The image digest of operator, which takes preference over tag                             | `""`                                                        |
| `operator.image.tag`              | The image tag of operator, overrides the image tag whose default is the chart appVersion. | `v1.12.1`                                                   |
| `operator.image.imagePullSecrets` | the image pull secrets of operator                                                        | `[]`                                                        |

### operatorWebhook parameters

| Name                                     | Description                                                                                       | Value                                                      |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `operatorWebhook.image.registry`         | The image registry of operator-webhook                                                            | `m.daocloud.io`                                            |
| `operatorWebhook.image.repository`       | The image repository of operator-webhook                                                          | `gcr.io/knative-releases/knative.dev/operator/cmd/webhook` |
| `operatorWebhook.image.pullPolicy`       | The image pull policy of operator-webhook                                                         | `IfNotPresent`                                             |
| `operatorWebhook.image.digest`           | The image digest of operator-webhook, which takes preference over tag                             | `""`                                                       |
| `operatorWebhook.image.tag`              | The image tag of operator-webhook, overrides the image tag whose default is the chart appVersion. | `v1.12.1`                                                  |
| `operatorWebhook.image.imagePullSecrets` | the image pull secrets of operator-webhook                                                        | `[]`                                                       |

### serving parameters

| Name                                                          | Description                                                                 | Value                                                                                  |
| ------------------------------------------------------------- | --------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| `serving.enable`                                              | The enabling flag for Knative Serving                                       | `true`                                                                                 |
| `serving.installNamespace`                                    | The namespace where Knative Serving is installed                            | `knative-serving`                                                                      |
| `serving.registry.override.kourier-gateway`                   | The image location for kourier-gateway                                      | `docker.m.daocloud.io/envoyproxy/envoy:v1.25-latest`                                   |
| `serving.registry.override.activator`                         | The image location for activator                                            | `m.daocloud.io/gcr.io/knative-releases/knative.dev/serving/cmd/activator:v1.12.2`      |
| `serving.registry.override.autoscaler`                        | The image location for autoscaler                                           | `m.daocloud.io/gcr.io/knative-releases/knative.dev/serving/cmd/autoscaler:v1.12.2`     |
| `serving.registry.override.autoscaler-hpa`                    | The image location for autoscaler-hpa                                       | `m.daocloud.io/gcr.io/knative-releases/knative.dev/serving/cmd/autoscaler-hpa:v1.12.2` |
| `serving.registry.override.controller`                        | The image location for controller                                           | `m.daocloud.io/gcr.io/knative-releases/knative.dev/serving/cmd/controller:v1.12.2`     |
| `serving.registry.override.net-kourier-controller/controller` | The image location for net-kourier-controller                               | `m.daocloud.io/gcr.io/knative-releases/knative.dev/net-kourier/cmd/kourier:v1.12.1`    |
| `serving.registry.override.webhook`                           | The image location for webhook                                              | `m.daocloud.io/gcr.io/knative-releases/knative.dev/serving/cmd/webhook:v1.12.2`        |
| `serving.ingress.kourier.enabled`                             | The enabling flag for the Kourier ingress                                   | `true`                                                                                 |
| `serving.config.network.ingress-class`                        | The ingress class used for Knative Serving networking                       | `kourier.ingress.networking.knative.dev`                                               |
| `serving.high-availability.replicas`                          | The number of replicas that HA parts of the control plane will be scaled to | `2`                                                                                    |

### configLogging parameters

| Name                              | Description                                                              | Value |
| --------------------------------- | ------------------------------------------------------------------------ | ----- |
| `configLogging.zap-logger-config` | The configuration for the zap logger used by Knative operator components | `{}`  |

### magicDNS parameters

| Name                        | Description                                                                               | Value                                                            |
| --------------------------- | ----------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| `magicDNS.enable`           | enable magic DNS                                                                          | `false`                                                          |
| `magicDNS.image.registry`   | The image registry of operator                                                            | `m.daocloud.io`                                                  |
| `magicDNS.image.repository` | The image repository of operator                                                          | `gcr.io/knative-releases/knative.dev/serving/cmd/default-domain` |
| `magicDNS.image.tag`        | The image tag of operator, overrides the image tag whose default is the chart appVersion. | `v1.12.3`                                                        |
| `magicDNS.image.pullPolicy` | The image pull policy of operator                                                         | `IfNotPresent`                                                   |

