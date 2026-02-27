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

export CHART_VERSION=$(helm show chart charts/contour | grep '^version' |grep -E '[0-9].*.[0-9]' | awk -F ':' '{print $2}' | tr -d ' ')
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
   .global.security.allowInsecureImages=true |
   .contour.contour.manageCRDs=true |
   .contour.contour.image.registry="docker.m.daocloud.io" |
   .contour.contour.image.repository="bitnamilegacy/contour" |
   .contour.contour.image.pullPolicy="IfNotPresent" |
   .contour.contour.replicaCount=2 |
   .contour.contour.ingressClass.name="contour" |
   .contour.contour.ingressClass.default=false |
   .contour.contour.extraArgs[0]="--envoy-service-http-address=::" |
   .contour.contour.extraArgs[1]="--envoy-service-https-address=::" |
   .contour.contour.debug=false |
   .contour.contour.resources.requests.cpu="15m" |
   .contour.contour.resources.requests.memory="30Mi" |
   .contour.envoy.resources.requests.cpu="15m" |
   .contour.envoy.resources.requests.memory="30Mi" |
   .contour.envoy.useHostPort.http=false |
   .contour.envoy.useHostPort.https=false |
   .contour.envoy.useHostPort.metrics=false |
   .contour.envoy.replicaCount=2 |
   .contour.envoy.image.registry="docker.m.daocloud.io" |
   .contour.envoy.image.repository="bitnamilegacy/envoy" |
   .contour.envoy.image.pullPolicy="IfNotPresent" |
   .contour.envoy.kind="deployment" |
   .contour.envoy.hostNetwork=false |
   .contour.envoy.logLevel="info" |
   .contour.envoy.service.type="LoadBalancer" |
   .contour.envoy.service.ipFamilyPolicy="SingleStack" |
   .contour.envoy.service.externalTrafficPolicy="Cluster" |
   .contour.envoy.affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight=100 |
   .contour.envoy.affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions[0].key="node-role.kubernetes.io/ingress" |
   .contour.envoy.affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions[0].operator="Exists" |
   .contour.envoy.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight=80 |
   .contour.envoy.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey="kubernetes.io/hostname" |
   .contour.envoy.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchLabels."app.kubernetes.io/instance"="metallb" |
   .contour.metrics.serviceMonitor.enabled=false |
   .contour.metrics.serviceMonitor.labels."operator.insight.io/managed-by"="insight"
' values.yaml

yq -i '.version=strenv(CHART_VERSION)' Chart.yaml
yq -i '.keywords = ["networking"] + (.keywords)' Chart.yaml
