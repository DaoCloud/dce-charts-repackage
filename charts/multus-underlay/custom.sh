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

export CHART_VERSION=$(helm show chart charts/meta-plugins | grep '^version' |grep -E '[0-9].*.[0-9]' | awk -F ':' '{print $2}' | tr -d ' ')
export IMAGE_VERSION=v${CHART_VERSION}
echo "CHART_VERSION: ${CHART_VERSION}"

yq -i '
    .appVersion=strenv(CHART_VERSION) |
    .version=strenv(CHART_VERSION)
' Chart.yaml

yq -i '.meta-plugins.image.tag=strenv(IMAGE_VERSION)' values.yaml

# keyWords to chart.yaml
cat <<EOF >> Chart.yaml
  - name: multus
    repository: file://charts/multus
    version: v3.9
  - name: sriov
    repository: file://charts/sriov
    version: 0.1.2
keywords:
  - networking
  - underlay
  - cni
EOF

helm-docs

exit 0


exit 0


