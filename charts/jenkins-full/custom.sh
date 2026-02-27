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

echo "upgrade jenkins from " ${PREV_VERSION} "->" ${VERSION}
os=$(uname)

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
  .jenkins-full.image.registry = "ghcr.m.daocloud.io" |
  .jenkins-full.trace.image.registry = "ghcr.m.daocloud.io" |
  .jenkins-full.trace.enabled = true |
  .jenkins-full.eventProxy.image.registry = "release.daocloud.io"
' values.yaml

# update relok8s.yaml
if [ $os == "Darwin" ];then
  sed -i "" "s/${PREV_VERSION}/${VERSION}/g" .relok8s-images.yaml
  sed -i "" "s/${PREV_VERSION}/${VERSION}/g" ./charts/jenkins-full/.relok8s-images.yaml
else
  sed -i "s/${PREV_VERSION}/${VERSION}/g" .relok8s-images.yaml
  sed -i "s/${PREV_VERSION}/${VERSION}/g" ./charts/jenkins-full/.relok8s-images.yaml
fi

exit $?