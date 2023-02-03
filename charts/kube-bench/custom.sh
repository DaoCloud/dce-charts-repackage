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

#==============================
if [ "$(uname)" == "Darwin" ];then
  sed  -i '' 's?{{ .Values.image.repository }}:{{ .Values.image.tag }}?{{ .Values.image.registry }}:{{ .Values.image.repository }}:{{ .Values.image.tag }}?'  charts/kube-bench/templates/cron.yaml
  sed  -i '' 's?< 1.8-0?>=1.21-0?'  charts/kube-bench/templates/_helpers.tpl
  sed  -i '' 's?>=1.8-0?< 1.21-0?'  charts/kube-bench/templates/_helpers.tpl
  sed  -i '' 's?batch/v2alpha1?batch/v1?'  charts/kube-bench/templates/_helpers.tpl
else
  sed  -i  's?{{ .Values.image.repository }}:{{ .Values.image.tag }}?{{ .Values.image.registry }}:{{ .Values.image.repository }}:{{ .Values.image.tag }}?'   charts/kube-bench/templates/cron.yaml
  sed  -i  's?< 1.8-0?>=1.21-0?'  charts/kube-bench/templates/_helpers.tpl
  sed  -i  's?>=1.8-0?< 1.21-0?'  charts/kube-bench/templates/_helpers.tpl
  sed  -i  's?batch/v2alpha1?batch/v1?'  charts/kube-bench/templates/_helpers.tpl
fi

yq -i '
  .kube-bench.image.registry = "docker.io" |
  .kube-bench.image.repository = "aquasec/kube-bench"
' values.yaml
