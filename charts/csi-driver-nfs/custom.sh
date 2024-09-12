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

sed -i "s/registry.k8s.io\///g" values.yaml

yq -i '.csi-driver-nfs.image.baseRepo="k8s.m.daocloud.io"' values.yaml

yq -i '.keywords.[0]="storage"' Chart.yaml

sed -i 's/image: "{{ .Values.image.baseRepo }}/image: "/g' charts/csi-driver-nfs/templates/csi-nfs-node.yaml
sed -i 's/image: "{{ .Values.image.baseRepo }}/image: "/g' charts/csi-driver-nfs/templates/csi-nfs-controller.yaml
sed -i 's/image: "{{ .Values.image.baseRepo }}/image: "/g' charts/csi-driver-nfs/templates/csi-snapshot-controller.yaml

sed -i 's/image: "{{ /image: "{{ .Values.image.baseRepo }}\/{{/g' charts/csi-driver-nfs/templates/csi-nfs-node.yaml
sed -i 's/image: "{{ /image: "{{ .Values.image.baseRepo }}\/{{/g' charts/csi-driver-nfs/templates/csi-nfs-controller.yaml
sed -i 's/image: "{{ /image: "{{ .Values.image.baseRepo }}\/{{/g' charts/csi-driver-nfs/templates/csi-snapshot-controller.yaml


exit $?