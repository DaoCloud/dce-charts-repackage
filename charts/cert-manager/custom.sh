#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY: $(ls)"

#========================= add your customize bellow ====================

set -o errexit
set -o pipefail
set -o nounset

export CHART_VERSION=$(helm show chart charts/cert-manager | grep '^version' |grep -E '[0-9].*.[0-9]' | awk -F ':' '{print $2}' | tr -d ' ')
export IMAGE_VERSION="${CHART_VERSION}"

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
   .cert-manager.installCRDs=true |
   .cert-manager.resources.requests.cpu="10m" |
   .cert-manager.resources.requests.memory="32Mi" |
   .cert-manager.resources.limits.cpu="200m" |
   .cert-manager.resources.limits.memory="256Mi" |
   .cert-manager.image.repository="quay.m.daocloud.io/jetstack/cert-manager-controller" |
   .cert-manager.image.tag=strenv(IMAGE_VERSION) |
   .cert-manager.replicaCount=2 |
   .cert-manager.webhook.replicaCount=2 |
   .cert-manager.webhook.image.repository="quay.m.daocloud.io/jetstack/cert-manager-webhook" |
   .cert-manager.webhook.image.tag=strenv(IMAGE_VERSION) |
   .cert-manager.webhook.resources.requests.cpu="10m" |
   .cert-manager.webhook.resources.requests.memory="32Mi" |
   .cert-manager.webhook.resources.limits.cpu="200m" |
   .cert-manager.webhook.resources.limits.memory="256Mi" |
   .cert-manager.cainjector.enabled=true |
   .cert-manager.cainjector.replicaCount=2 |
   .cert-manager.cainjector.image.repository="quay.m.daocloud.io/jetstack/cert-manager-cainjector" |
   .cert-manager.cainjector.image.tag=strenv(IMAGE_VERSION) |
   .cert-manager.cainjector.resources.requests.cpu="10m" |
   .cert-manager.cainjector.resources.requests.memory="32Mi" |
   .cert-manager.cainjector.resources.limits.cpu="200m" |
   .cert-manager.cainjector.resources.limits.memory="256Mi" |
   .cert-manager.startupapicheck.enabled=false |
   .cert-manager.startupapicheck.image.repository="quay.m.daocloud.io/jetstack/cert-manager-ctl" |
   .cert-manager.startupapicheck.image.tag=strenv(IMAGE_VERSION) |
   .cert-manager.startupapicheck.resources.requests.cpu="10m" |
   .cert-manager.startupapicheck.resources.requests.memory="32Mi" |
   .cert-manager.startupapicheck.resources.limits.cpu="10m" |
   .cert-manager.startupapicheck.resources.limits.memory="32Mi" |
   .cert-manager.prometheus.enabled=true |
   .cert-manager.prometheus.servicemonitor.enabled=true
' values.yaml

yq -i '.appVersion=strenv(CHART_VERSION)' Chart.yaml
export CHART_VERSION="${CHART_VERSION#v}"
yq -i '.version=strenv(CHART_VERSION)' Chart.yaml
