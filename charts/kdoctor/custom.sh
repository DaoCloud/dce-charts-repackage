#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"


if ! which yq &>/dev/null ; then
    echo " 'yq' no found, try to install..."
    YQ_VERSION=v4.30.6
    YQ_BINARY="yq_$(uname | tr 'A-Z' 'a-z')_amd64"
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O /tmp/yq.tar.gz &&
     tar -xzf /tmp/yq.tar.gz -C /tmp &&
     mv /tmp/${YQ_BINARY} /usr/bin/yq
fi

#========================= add your customize bellow ====================
#===============================

set -o errexit
set -o pipefail
set -o nounset


APP_VERSION=` cat charts/kdoctor/Chart.yaml | grep appVersion | awk '{print $2}'`
sed -iE "s?tag:.*?tag: \"v${APP_VERSION}\"?g" values.yaml

yq -i '
    .kdoctor.global.imageRegistryOverride="ghcr.m.daocloud.io" |
    .kdoctor.kdoctorAgent.service.type="NodePort"
' values.yaml

rm -f values.yamlE || true

