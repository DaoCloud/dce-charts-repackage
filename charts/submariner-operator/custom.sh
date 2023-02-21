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

# change origin chart template:
if [ "$(uname)" == "Darwin" ];then
  gsed  -i  's?{{ .Values.operator.image.repository }}?{{ .Values.operator.image.registry }}/{{ .Values.operator.image.repository }}?'   charts/submariner-operator/templates/operator-deployment.yaml
  gsed  -i  's?{{ .Values.submariner.images.repository }}?{{ .Values.submariner.images.registry }}/{{ .Values.submariner.images.repository }}?'   charts/submariner-operator/templates/submariner.yaml
  gsed  -i  '/^[[:space:]]*resources:/i\        {{- with .Values.operator.resources }}' charts/submariner-operator/templates/operator-deployment.yaml
  gsed  -i  '/^[[:space:]]*resources:/a\        {{- end }}' charts/submariner-operator/templates/operator-deployment.yaml
  gsed  -i  '/^[[:space:]]*resources:/a\          {{- toYaml . | nindent 10 }}' charts/submariner-operator/templates/operator-deployment.yaml
  gsed  -i 's?resources: {}?resources:?'   charts/submariner-operator/templates/operator-deployment.yaml
  gsed -i  '/---/d' values.yaml
else
  sed  -i  's?{{ .Values.operator.image.repository }}?{{ .Values.operator.image.registry }}/{{ .Values.operator.image.repository }}?'   charts/submariner-operator/templates/operator-deployment.yaml
  sed  -i  's?{{ .Values.submariner.images.repository }}?{{ .Values.submariner.images.registry }}/{{ .Values.submariner.images.repository }}?'   charts/submariner-operator/templates/submariner.yaml
  sed  -i  '/^[[:space:]]*resources:/i\        {{- with .Values.operator.resources }}' charts/submariner-operator/templates/operator-deployment.yaml
  sed  -i  '/^[[:space:]]*resources:/a\        {{- end }}' charts/submariner-operator/templates/operator-deployment.yaml
  sed  -i  '/^[[:space:]]*resources:/a\          {{- toYaml . | nindent 10 }}' charts/submariner-operator/templates/operator-deployment.yaml
  sed  -i 's?resources: {}?resources:?'   charts/submariner-operator/templates/operator-deployment.yaml
  sed -i '/---/d' values.yaml
fi

export CHART_VERSION=$(helm show chart . | grep '^version' |grep -E '[0-9].*.[0-9]' | awk -F ':' '{print $2}' | tr -d ' ')
echo "CHART_VERSION: ${CHART_VERSION}"

yq -i '
   .submariner-operator.submariner.images.registry="quay.m.daocloud.io" |
   .submariner-operator.submariner.images.repository="submariner" |
   .submariner-operator.submariner.images.tag=strenv(CHART_VERSION) |
   .submariner-operator.operator.image.registry="quay.m.daocloud.io" |
   .submariner-operator.operator.image.repository="submariner/submariner-operator" |
   .submariner-operator.operator.image.tag=strenv(CHART_VERSION) |
   .submariner-operator.operator.resources.requests.cpu="30m" |
   .submariner-operator.operator.resources.requests.memory="50M" |
   .submariner-operator.operator.resources.limits.cpu="250m" |
   .submariner-operator.operator.resources.limits.memory="300M"
' values.yaml


# keyWords to chart.yaml
cat <<EOF >> Chart.yaml
keywords:
  - networking
EOF


exit 0


