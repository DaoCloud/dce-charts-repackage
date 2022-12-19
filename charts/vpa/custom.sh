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
  sed  -i '' 's?{{ .Values.admissionController.certGen.image.repository }}:{{ .Values.admissionController.certGen.image.tag?{{ .Values.admissionController.certGen.image.registry }}/{{ .Values.admissionController.certGen.image.repository }}:{{ .Values.admissionController.certGen.image.tag?'  charts/vpa/templates/admission-controller-certgen.yaml
  sed  -i '' 's?{{ .Values.admissionController.cleanupOnDelete.image.repository }}:{{ .Values.admissionController.cleanupOnDelete.image.tag?{{ .Values.admissionController.cleanupOnDelete.image.registry }}/{{ .Values.admissionController.cleanupOnDelete.image.repository }}:{{ .Values.admissionController.cleanupOnDelete.image.tag?'  charts/vpa/templates/admission-controller-cleanup.yaml
  sed  -i '' 's?{{ .Values.admissionController.image.repository }}:{{ .Values.admissionController.image.tag?{{ .Values.admissionController.image.registry }}/{{ .Values.admissionController.image.repository }}:{{ .Values.admissionController.image.tag?'   charts/vpa/templates/admission-controller-deployment.yaml
  sed  -i '' 's?{{ .Values.recommender.image.repository }}:{{ .Values.recommender.image.tag?{{ .Values.recommender.image.registry }}/{{ .Values.recommender.image.repository }}:{{ .Values.recommender.image.tag?'  charts/vpa/templates/recommender-deployment.yaml
  sed  -i '' 's?{{ .Values.updater.image.repository }}:{{ .Values.updater.image.tag?{{ .Values.updater.image.registry }}/{{ .Values.updater.image.repository }}:{{ .Values.updater.image.tag?'   charts/vpa/templates/updater-deployment.yaml
else
  sed  -i  's?{{ .Values.admissionController.certGen.image.repository }}:{{ .Values.admissionController.certGen.image.tag?{{ .Values.admissionController.certGen.image.registry }}/{{ .Values.admissionController.certGen.image.repository }}:{{ .Values.admissionController.certGen.image.tag?'   charts/vpa/templates/admission-controller-certgen.yaml
  sed  -i  's?{{ .Values.admissionController.cleanupOnDelete.image.repository }}:{{ .Values.admissionController.cleanupOnDelete.image.tag?{{ .Values.admissionController.cleanupOnDelete.image.registry }}/{{ .Values.admissionController.cleanupOnDelete.image.repository }}:{{ .Values.admissionController.cleanupOnDelete.image.tag?'   charts/vpa/templates/admission-controller-cleanup.yaml
  sed  -i  's?{{ .Values.admissionController.image.repository }}:{{ .Values.admissionController.image.tag?{{ .Values.admissionController.image.registry }}/{{ .Values.admissionController.image.repository }}:{{ .Values.admissionController.image.tag?'   charts/vpa/templates/admission-controller-deployment.yaml
  sed  -i  's?{{ .Values.recommender.image.repository }}:{{ .Values.recommender.image.tag?{{ .Values.recommender.image.registry }}/{{ .Values.recommender.image.repository }}:{{ .Values.recommender.image.tag?'  charts/vpa/templates/recommender-deployment.yaml
  sed  -i  's?{{ .Values.updater.image.repository }}:{{ .Values.updater.image.tag?{{ .Values.updater.image.registry }}/{{ .Values.updater.image.repository }}:{{ .Values.updater.image.tag?' charts/vpa/templates/updater-deployment.yaml
fi
