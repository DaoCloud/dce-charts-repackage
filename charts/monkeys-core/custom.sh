#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================
#===============================

set -o errexit
set -o pipefail
set -o nounset


yq -i '
  .core.images.server.registry = "m.daocloud.io/docker.io" |
  .core.images.web.registry = "m.daocloud.io/docker.io" |
  .core.images.web.registry = "m.daocloud.io/docker.io" |
  .core.images.admin.registry = "m.daocloud.io/docker.io" |
  .core.images.conductor.registry = "m.daocloud.io/docker.io" |
  .core.images.oneapi.registry = "m.daocloud.io/docker.io" |
  .core.images.busybox.registry = "m.daocloud.io/docker.io" |
  .core.images.busybox.tag = "1.36.0" |
  .core.images.clash.registry = "m.daocloud.io/docker.io" |
  .core.images.nginx.registry = "m.daocloud.io/docker.io" |
  .core.images.nginx.tag = "1.25.2-alpine" |
  .core.oneapi.enabled=false |
  .core.proxy.resources={"limits":{"cpu":"1000m","memory":"2048M"},"requests":{"cpu":"100m","memory":"125M"}} |
  .core.server.resources={"limits":{"cpu":"1000m","memory":"2048M"},"requests":{"cpu":"100m","memory":"125M"}} |
  .core.web.resources={"limits":{"cpu":"1000m","memory":"2048M"},"requests":{"cpu":"100m","memory":"125M"}} |
  .core.conductor.resources={"limits":{"cpu":"1000m","memory":"2048M"},"requests":{"cpu":"100m","memory":"125M"}} |
  .core.GProductNavigator.enabled=true |
  .core.postgresql.enabled=false |
  .core.externalPostgresql.enabled=true |
  .core.externalPostgresql.host="pg-svc.infra-drun.svc" |
  .core.externalPostgresql.port=5432 |
  .core.externalPostgresql.username="postgres" |
  .core.externalConductorPostgresql.enabled=true |
  .core.externalConductorPostgresql.host="pg-svc.infra-drun.svc" |
  .core.externalConductorPostgresql.port=5432 |
  .core.externalConductorPostgresql.username="postgres" |
  .core.redis.enabled=false |
  .core.externalRedis.enabled=true |
  .core.externalRedis.enabled=true |
  .core.externalRedis.url="redis://:password@redis-redis-svc.infra-drun.svc:6379/0" |
  .core.oneapi.enabled=false |
  .core.elasticsearch.enabled=false |
  .core.externalElasticsearch.enabled=true |
  .core.externalElasticsearch.url="http://es-es-http.infra-drun.svc:9200" |
  .core.externalElasticsearch.username="elastic" |
  .core.minio.enabled=false |
  .core.externalS3.enabled=true |
  .core.externalS3.endpoint="http://minio-svc.infra-drun.svc" |
  .core.externalS3.accessKeyId="minio" |
  .core.externalS3.region="us-east-1" |
  .core.service.type="NodePort" |
  .core.externalS3.bucket="monkeys" 
  

 ' values.yaml



yq -i '
   .dependencies |= map(select(.name != "elasticsearch")) |
   .dependencies |= map(select(.name != "postgresql")) |
   .dependencies |= map(select(.name != "redis")) |
   .dependencies |= map(select(.name != "minio")) |
   .name="monkeys-core" |
   .maintainers=[{"name":"inf-monkeys","url":"https://github.com/inf-monkeys/helm-charts"}] |
   .keywords=["infra"] |
   .home="https://github.com/inf-monkeys/helm-charts" |
   .sources[0]="https://github.com/inf-monkeys/helm-charts" |
   .name="monkeys-core" 
' Chart.yaml

cp charts/core/.relok8s-images.yaml .

sed 's@.images@.core.images@g' charts/core/.relok8s-images.yaml > .relok8s-images.yaml
sed -i '/oneapi/d' .relok8s-images.yaml
sed -i '/clash/d' .relok8s-images.yaml

rm -rf charts/core/.relok8s-images.yaml
rm -rf charts/core/charts/*
rm -rf charts/core/templates/tests/*


exit 0
