#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

CURRENT_DIR_PATH=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)

echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"
echo "CURRENT_DIR_PATH: " $CURRENT_DIR_PATH

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

driverVersion=$(yq eval '.ofed-driver.image.driverVersion' ${CHART_DIRECTORY}/values.yaml)
OSName=$(yq eval '.ofed-driver.image.OSName' ${CHART_DIRECTORY}/values.yaml)
OSVer=$(yq eval '.ofed-driver.image.OSVer' ${CHART_DIRECTORY}/values.yaml)
Arch=$(yq eval '.ofed-driver.image.Arch' ${CHART_DIRECTORY}/values.yaml)

yq -i '.ofed-driver.image.registry="nvcr.m.daocloud.io"' ${CHART_DIRECTORY}/values.yaml
tag="${driverVersion}-${OSName}${OSVer}-${Arch}"
yq eval ".ofed-driver.image.tag = \"${tag}\"" -i ${CHART_DIRECTORY}/values.yaml

exit 0