#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

set -o errexit
set -o nounset

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
SED_COMMAND="sed"
if [ "${OS}" == "darwin" ]; then
    SED_COMMAND="gsed"
fi

#==============================
echo "insert custom resources"

FILEBROWSER_IMAGE_TAG=$(yq e '.fileBrowser.image.tag' $CHART_DIRECTORY/charts/topohub/values.yaml | tr -d '\n' | tr -d '\r')
TOPOHUB_IMAGE_TAG=$(cat $CHART_DIRECTORY/Chart.yaml | grep appVersion | awk '{print $2}')


yq -i "
  .topohub.image.tag = \"v$TOPOHUB_IMAGE_TAG\" |
  .topohub.fileBrowser.image.tag = \"$FILEBROWSER_IMAGE_TAG\" 
" values.yaml


yq -i '
  .topohub.image.registry = "ghcr.m.daocloud.io" |
  .topohub.image.repository = "infrastructure-io/topohub" |
  .topohub.fileBrowser.enabled = true |
  .topohub.fileBrowser.image.registry = "docker.m.daocloud.io" |
  .topohub.fileBrowser.image.repository = "filebrowser/filebrowser"
' values.yaml

exit 0
