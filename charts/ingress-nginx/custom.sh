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

export CHART_VERSION=$(helm show chart charts/ingress-nginx | grep '^version' |grep -E '[0-9].*.[0-9]' | awk -F ':' '{print $2}' | tr -d ' ')

yq -i '
   .ingress-nginx.controller.replicaCount=2 |
   .ingress-nginx.controller.metrics.enabled=true |
   .ingress-nginx.controller.metrics.serviceMonitor.enabled=false |
   .ingress-nginx.controller.metrics.serviceMonitor.additionalLabels."operator.insight.io/managed-by"="insight" |
   .ingress-nginx.controller.resources.limits.cpu="500m" |
   .ingress-nginx.controller.resources.limits.memory="512Mi" |
   .ingress-nginx.controller.resources.requests.cpu="20m" |
   .ingress-nginx.controller.resources.requests.memory="150Mi" |
   .ingress-nginx.controller.service.ipFamilyPolicy="SingleStack" |
   .ingress-nginx.controller.service.type="LoadBalancer" |
   .ingress-nginx.controller.service.internal.externalTrafficPolicy="Cluster" |
   .ingress-nginx.controller.image.registry="k8s.m.daocloud.io" |
   .ingress-nginx.controller.image.pullPolicy="IfNotPresent" |
   .ingress-nginx.controller.image.digest="" |
   .ingress-nginx.controller.image.digestChroot="" |
   .ingress-nginx.controller.admissionWebhooks.patch.image.digest="" |
   .ingress-nginx.controller.admissionWebhooks.patch.enabled=true |
   .ingress-nginx.controller.admissionWebhooks.patch.image.registry="k8s.m.daocloud.io" |
   .ingress-nginx.controller.admissionWebhooks.patch.image.pullPolicy="IfNotPresent" |
   .ingress-nginx.controller.ingressClassResource.name="nginx" |
   .ingress-nginx.controller.ingressClassResource.default=false |
   .ingress-nginx.controller.ingressClass="nginx" |
   .ingress-nginx.controller.electionID="ingress-controller-leader" |
   .ingress-nginx.controller.affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight=100 |
   .ingress-nginx.controller.affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions[0].key="node-role.kubernetes.io/ingress" |
   .ingress-nginx.controller.affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].preference.matchExpressions[0].operator="Exists"
' values.yaml

yq -i '.version=strenv(CHART_VERSION)' Chart.yaml
yq -i '.keywords = ["networking"] + (.keywords)' Chart.yaml
