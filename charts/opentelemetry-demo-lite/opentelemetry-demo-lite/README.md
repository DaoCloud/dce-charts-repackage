# OpenTelemetry Demo Lite Helm Chart

This chart is an extension of [OpenTelemetry Demo](https://github.com/open-telemetry/opentelemetry-demo) and
[OpenTelemetry Demo Chart](https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-demo).

## Architecture

This chart only retains those core services to ensure the shopping flow. Below is the current service diagram:

```mermaid
graph TD
subgraph Service Diagram
adservice(Ad Service):::java
dataservice(Data Service):::java
cache[(Cache<br/>&#40redis&#41)]
cartservice(Cart Service):::dotnet
checkoutservice-v2(Checkout Service):::golang
frontend(Frontend):::typescript
loadgenerator([Load Generator]):::python
paymentservice(Payment Service):::javascript
productcatalogservice(Product Catalog Service):::golang
quoteservice(Quote Service):::php
shippingservice(Shipping Service):::rust
adstore[(DataService Store<br/>&#40Mysql DB&#41)]

Internet -->|HTTP| frontend

loadgenerator -->|HTTP| frontend

checkoutservice-v2 --->|gRPC| cartservice -->|TCP| cache
checkoutservice-v2 --->|gRPC| productcatalogservice
checkoutservice-v2 --->|gRPC| paymentservice
checkoutservice-v2 -->|gRPC| shippingservice

frontend -->|gRPC| adservice
frontend -->|gRPC| cartservice
frontend -->|gRPC| productcatalogservice
frontend -->|gRPC| checkoutservice-v2
frontend -->|gRPC| shippingservice -->|HTTP| quoteservice

adservice -->|HTTP| dataservice
dataservice ---> |TCP| adstore

end

classDef dotnet fill:#178600,color:white;
classDef golang fill:#00add8,color:black;
classDef java fill:#b07219,color:white;
classDef javascript fill:#f1e05a,color:black;
classDef php fill:#4f5d95,color:white;
classDef python fill:#3572A5,color:white;
classDef rust fill:#dea584,color:black;
classDef typescript fill:#e98516,color:black;
```

```mermaid
graph TD
subgraph Service Legend
  dotnetsvc(.NET):::dotnet
  golangsvc(Go):::golang
  javasvc(Java):::java
  javascriptsvc(JavaScript):::javascript
  phpsvc(PHP):::php
  pythonsvc(Python):::python
  rustsvc(Rust):::rust
  typescriptsvc(TypeScript):::typescript
end

classDef dotnet fill:#178600,color:white;
classDef golang fill:#00add8,color:black;
classDef java fill:#b07219,color:white;
classDef javascript fill:#f1e05a,color:black;
classDef php fill:#4f5d95,color:white;
classDef python fill:#3572A5,color:white;
classDef rust fill:#dea584,color:black;
classDef typescript fill:#e98516,color:black;
```

## Changelog

We have made certain modifications to the official demo, and the following are the specific details of the modifications.

### Re-implement components

#### [Adservice](https://github.com/openinsight-proj/opentelemetry-demo/tree/daocloud/src/adservice-v2#note-the-overall-helm-chart)

- integrate nacos
- integrate sentinel
- support grpcurl
- [expose Prometheus metrics](https://github.com/openinsight-proj/adservice#metrics)
- [mock latency](https://github.com/openinsight-proj/adservice#mock-latency)
- [50% error rate](https://github.com/openinsight-proj/adservice#mock-error)
- call Dataservice to get Ad data

#### [Checkoutservice](https://github.com/openinsight-proj/opentelemetry-demo/tree/daocloud/src/checkoutservice-v2#checkout-service)

- doesn't depend Emailservice
- doesn't depend Currencyservice
- doesn't depend Kafka

### Added components

#### [Dataservice](https://github.com/openinsight-proj/opentelemetry-demo/tree/daocloud/src/dataservice)

This service only used by Adservice. It will accept Adservice's http request then response Ad data from mysql.

### Official chart re-configuration

1. Close all none business services, such as Opentelemetry collector, Prometheus, Jaeger, Grafana,
   all service's telemetry data will fellow this data flow: `Components --> Insight-agent OTel collector`。

2. Support deploying Redis instance from a  Redis operator(Make sure Redis operator already works).

## Install

_Note：make sure Insight agent already works(If`--set .global.middleware.redis.deployBy=redisCR`, make sure Redis 
operator already works)_

```shell
helm repo add open-insight https://openinsight-proj.github.io/openinsight-helm-charts

helm install webstore-demo open-insight/opentelemetry-demo-lite -n webstore-demo --create-namespace
```

## Common chart param

Please use `values.schema.json` to get to know how to control the deployment behavior of this chart(use 
[json schema editor](https://form.lljj.me/#/demo?ui=VueElementForm&type=Test) to parse the schema and use 
[json-to-yaml](https://codebeautify.org/json-to-yaml) to generate values.yaml).



