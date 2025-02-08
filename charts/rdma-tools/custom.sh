#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

CURRENT_DIR_PATH=$(
    cd $(dirname ${BASH_SOURCE[0]})
    pwd
)

echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"
echo "CURRENT_DIR_PATH: " $CURRENT_DIR_PATH

#========================= add your customize bellow ====================
#===============================

set -o errexit
set -o pipefail
set -o nounset

if ! which yq &>/dev/null; then
    echo " 'yq' no found, try to install..."
    YQ_VERSION=v4.30.6
    YQ_BINARY="yq_$(uname | tr 'A-Z' 'a-z')_amd64"
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O /tmp/yq.tar.gz &&
        tar -xzf /tmp/yq.tar.gz -C /tmp &&
        mv /tmp/${YQ_BINARY} /usr/bin/yq
fi

OS=$(uname -s | tr 'A-Z' 'a-z')
if [ "${OS}" == "darwin" ]; then
    gsed -i "/requests:/i\    limits:" ${CHART_DIRECTORY}/values.yaml
    gsed -i "/requests:/i\      cpu: 500m" ${CHART_DIRECTORY}/values.yaml
    gsed -i "/requests:/i\      memory: 1024Mi" ${CHART_DIRECTORY}/values.yaml
else
    sed -i "/requests:/i\    limits:" ${CHART_DIRECTORY}/values.yaml
    sed -i "/requests:/i\      cpu: 500m" ${CHART_DIRECTORY}/values.yaml
    sed -i "/requests:/i\      memory: 1024Mi" ${CHART_DIRECTORY}/values.yaml
fi

export IMAGE_TAG=v$(cat ${CHART_DIRECTORY}/Chart.yaml | yq -r '.version')
echo "custom shell: IMAGE_TAG $IMAGE_TAG"

yq -i '
    .rdma-tools.image.tag=strenv(IMAGE_TAG) |
    .rdma-tools.image.registry="ghcr.m.daocloud.io"
' ${CHART_DIRECTORY}/values.yaml

exit 0
