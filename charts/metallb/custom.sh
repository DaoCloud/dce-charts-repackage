#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY: $(ls)"

#========================= add your customize bellow ====================
#===============================

set -o errexit
set -o pipefail
set -o nounset

if ! which yq &>/dev/null ; then
    echo " 'yq' no found, try to install..."
    YQ_VERSION=v4.30.6
    YQ_BINARY="yq_$(uname | tr 'A-Z' 'a-z')_amd64"
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O /tmp/yq.tar.gz &&
     tar -xzf /tmp/yq.tar.gz -C /tmp &&
     mv /tmp/${YQ_BINARY} /usr/bin/yq
fi

if ! which helm-docs &>/dev/null ; then
    echo " 'helm-docs' no found, try to install..."
    wget https://github.com/norwoodj/helm-docs/releases/download/v1.11.0/helm-docs_1.11.0_Linux_x86_64.tar.gz -O /tmp/helm-docs_1.11.0_Linux_x86_64.tar.gz &&
     tar -xzf /tmp/helm-docs_1.11.0_Linux_x86_64.tar.gz -C /tmp &&
     mv /tmp/helm-docs /usr/local/bin/helm-docs
fi

export CHART_VERSION=$(helm show chart charts/metallb | grep '^version' |grep -E '[0-9].*.[0-9]' | awk -F ':' '{print $2}' | tr -d ' ')
export IMAGE_VERSION="v${CHART_VERSION}"

echo "CHART_VERSION: ${CHART_VERSION}"
echo "IMAGE_VERSION: ${IMAGE_VERSION}"

yq -i '
   .metallb.prometheus.rbacProxy.repository="gcr.m.daocloud.io/kubebuilder/kube-rbac-proxy" |
   .metallb.controller.image.tag=strenv(IMAGE_VERSION) |
   .metallb.controller.image.repository="quay.m.daocloud.io/metallb/controller" |
   .metallb.controller.resources.requests.cpu="5m" |
   .metallb.controller.resources.requests.memory="50Mi" |
   .metallb.speaker.image.repository="quay.m.daocloud.io/metallb/speaker" |
   .metallb.speaker.image.tag=strenv(IMAGE_VERSION) |
   .metallb.speaker.resources.requests.cpu="40m" |
   .metallb.speaker.resources.requests.memory="80Mi" |
   .metallb.speaker.frr.image.repository="docker.m.daocloud.io/frrouting/frr"
' values.yaml

yq -i '
   .version=strenv(CHART_VERSION) |
   .appVersion=strenv(CHART_VERSION) |
   .dependencies[0].version=strenv(CHART_VERSION)
' Chart.yaml

# Auto README.md
mv README.md readme
helm-docs
LINE=$(cat README.md | grep -n 'helm-docs' | awk -F ':' '{print $1}')
eval sed '${LINE}d' README.md > README.tmp
echo "" >> README.tmp
cat readme >> README.tmp
# sed -n '$(LINE)p' README.md >> README.tmp

mv README.tmp README.md
rm readme

exit 0


