#!/bin/bash
set -x

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

#==============================
if [ "$(uname)" == "Darwin" ];then
  sed  -i '' 's?{{ .Values.image.repository }}:{{ .Values.image.tag?{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag?' charts/velero/templates/deployment.yaml

  sed  -i '' 's?{{ .Values.kubectl.image.repository }}:{{ .Values.kubectl.image.tag?{{ .Values.kubectl.image.registry }}/{{ .Values.kubectl.image.repository }}:{{ .Values.kubectl.image.tag?' charts/velero/templates/cleanup-crds.yaml

  sed  -i '' 's?{{ .Values.image.repository }}:{{ .Values.image.tag?{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag?' charts/velero/templates/upgrade-crds/upgrade-crds.yaml
  sed  -i '' 's?{{ .Values.kubectl.image.repository }}:{{ .Values.kubectl.image.tag?{{ .Values.kubectl.image.registry }}/{{ .Values.kubectl.image.repository }}:{{ .Values.kubectl.image.tag?' charts/velero/templates/upgrade-crds/upgrade-crds.yaml

  sed  -i '' 's?{{ .Values.image.repository }}:{{ .Values.image.tag?{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag?' charts/velero/templates/node-agent-daemonset.yaml
else
  sed  -i 's?{{ .Values.image.repository }}:{{ .Values.image.tag?{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag?' charts/velero/templates/deployment.yaml

  sed  -i 's?{{ .Values.kubectl.image.repository }}:{{ .Values.kubectl.image.tag?{{ .Values.kubectl.image.registry }}/{{ .Values.kubectl.image.repository }}:{{ .Values.kubectl.image.tag?' charts/velero/templates/cleanup-crds.yaml

  sed  -i 's?{{ .Values.image.repository }}:{{ .Values.image.tag?{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag?' charts/velero/templates/upgrade-crds/upgrade-crds.yaml
  sed  -i 's?{{ .Values.kubectl.image.repository }}:{{ .Values.kubectl.image.tag?{{ .Values.kubectl.image.registry }}/{{ .Values.kubectl.image.repository }}:{{ .Values.kubectl.image.tag?' charts/velero/templates/upgrade-crds/upgrade-crds.yaml

  sed  -i 's?{{ .Values.image.repository }}:{{ .Values.image.tag?{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag?' charts/velero/templates/node-agent-daemonset.yaml
fi

yq  -i '."velero"."image"+={"registry":"docker.io","repository":"velero/velero","pluginCSIRepository":"velero/velero-plugin-for-csi","pluginCSITag":"v0.4.0","pluginAWSRepository":"velero/velero-plugin-for-aws","pluginAWSTag":"v1.6.0","restoreHelperRepository":"velero/velero-restore-helper","restoreHelperTag":"v1.10.0"}' values.yaml
yq  -i '."velero"."kubectl"."image"+={"registry":"docker.io","repository":"bitnami/kubectl","tag":"1.21.0"}' values.yaml


yq -i '
  .velero.image.registry = "docker.m.daocloud.io" |
  .velero.kubectl.image.registry = "docker.m.daocloud.io" 
' values.yaml


if ! grep "keywords:" Chart.yaml &>/dev/null ; then
    echo "keywords:" >> Chart.yaml
    echo "  - velero" >> Chart.yaml
    echo "  - backup" >> Chart.yaml
fi
