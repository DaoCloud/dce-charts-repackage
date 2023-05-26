#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================

set -o errexit
set -o pipefail
set -o nounset

if ! which yq &>/dev/null ; then
    echo " 'yq' no found"
    if [ "$(uname)" == "Darwin" ];then
      exit 1
    fi
    echo "try to install..."
    YQ_VERSION=v4.30.6
    YQ_BINARY="yq_$(uname | tr 'A-Z' 'a-z')_amd64"
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O /tmp/yq.tar.gz &&
     tar -xzf /tmp/yq.tar.gz -C /tmp &&
     mv /tmp/${YQ_BINARY} /usr/bin/yq
fi

yq -i ' .name = "istio-istiod"' Chart.yaml

yq -i ' .istiod.global.hub = "docker.m.daocloud.io/istio" ' values.yaml
yq -i ' .istiod.global.defaultResources.requests.cpu = "10m" ' values.yaml
yq -i ' .istiod.global.defaultResources.requests.memory = "128Mi" ' values.yaml
yq -i ' .istiod.global.defaultResources.limits.cpu = "100m" ' values.yaml
yq -i ' .istiod.global.defaultResources.limits.memory = "200Mi" ' values.yaml

# add custom image
yq -i ' .istiod.grpcSimaple.hub = "docker.m.daocloud.io" ' values.yaml
yq -i ' .istiod.grpcSimaple.image = "busybox" ' values.yaml
yq -i ' .istiod.grpcSimaple.tag = "1.28" ' values.yaml

if [ "$(uname)" == "Darwin" ];then
  sed -i '' 's?busybox:1.28?{{ .Values.grpcSimaple.hub }}/{{ .Values.grpcSimaple.image }}:{{ .Values.grpcSimaple.tag }}?g' charts/istiod/files/grpc-simple.yaml
else
  sed -i 's?busybox:1.28?{{ .Values.grpcSimaple.hub }}/{{ .Values.grpcSimaple.image }}:{{ .Values.grpcSimaple.tag }}?g' charts/istiod/files/grpc-simple.yaml
fi

rm -rf values.schema.json
helm schema-gen values.yaml > ./values.schema.json
