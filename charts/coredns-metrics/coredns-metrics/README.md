
## 概述

本chart 包用于安装CoreDNS 指标采集、监控告警及Grafana仪表板。


## 安装

默认不安装任何的资源，需要指定打开。其中除了ServiceMonitor需要在所有的集群都安装外，其余只需在管理集群安装。

```
helm repo add daocloud-system https://release.daocloud.io/chartrepo/addon
helm install coredns -f values.yml daocloud-system/coredns-metrics
helm ls
```


参数 | 说明 | 值
---|---|---
global.isInstallSM | 是否安装ServiceMonitor | false/true
global.isInstallPR | 是否安装PrometheusRule | false/true
global.isInstallGD | 是否安装GrafanaDashboard | false/true


由于CoreDNS与LocalDNSCache 区别只在缓存部分，两者的指标、监控及告警相关规则可共用同一套

## 卸载

```
helm uninstall coredn 
```
