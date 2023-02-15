#!/bin/bash
set -ex

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

yq -i '
    .kuberhealthy.image.registry="docker.m.daocloud.io" |
    .kuberhealthy.image.tag="v2.7.1" |
    .kuberhealthy.check.daemonset.image.registry="docker.m.daocloud.io" |
    .kuberhealthy.check.deployment.image.registry="docker.m.daocloud.io" |
    .kuberhealthy.check.dnsInternal.image.registry="docker.m.daocloud.io" |
    .kuberhealthy.check.dnsExternal.image.registry="docker.m.daocloud.io" |
    .kuberhealthy.check.podRestarts.image.registry="docker.m.daocloud.io" |
    .kuberhealthy.check.podStatus.image.registry="docker.m.daocloud.io" |
    .kuberhealthy.check.storage.image.registry="docker.m.daocloud.io" |
    .kuberhealthy.check.networkConnection.image.registry="docker.m.daocloud.io" 
' values.yaml
