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

yq -i ' .name = "istio-cni"' Chart.yaml

yq -i ' .cni.global.hub = "docker.m.daocloud.io" ' values.yaml
yq -i ' .cni.cni.image = "istio/install-cni" ' values.yaml
yq -i ' .cni.cni.resources.requests.cpu = "10m" ' values.yaml
yq -i ' .cni.cni.resources.requests.memory = "100Mi" ' values.yaml
yq -i ' .cni.cni.resources.limits.cpu = "100m" ' values.yaml
yq -i ' .cni.cni.resources.limits.memory = "200Mi" ' values.yaml
