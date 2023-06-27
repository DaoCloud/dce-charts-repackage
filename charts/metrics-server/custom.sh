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

#==============================
REPLACE_BY_DEFINE(){
  DEFINE="$1"
  OLD_DATA="$2"
  NEW_DATA="$3"

  LINE=`cat charts\/metrics-server\/templates\/_helpers.tpl | grep -n "$DEFINE"  | awk -F: '{print $1}' `
  [ -z "$LINE" ] && echo "failed to find define $DEFINE" && exit 1
  sed -i -e ''$((LINE+1))' s?'"${OLD_DATA}"'?'"${NEW_DATA}"'?' charts\/metrics-server\/templates\/_helpers.tpl
  (($?!=0)) && echo  echo "failed to sed " && exit 2
  return 0
}

REPLACE_BY_DEFINE  "metrics-server.image"   '{{- printf "%s:%s" .Values.image.repository (default (printf "v%s" .Chart.AppVersion) .Values.image.tag) }}'  '{{- printf "%s/%s:%s" .Values.image.registry .Values.image.repository (default (printf "v%s" .Chart.AppVersion) .Values.image.tag) }}'


# add required annotation
yq -i '
   .annotations["addon.kpanda.io/required"]="true"
' Chart.yaml
# use daocloud registry && set resources limit
yq -i '
  .metrics-server.image.registry = "k8s-gcr.m.daocloud.io" |
  .metrics-server.resources.limits.cpu="500m" |
  .metrics-server.resources.limits.memory="512Mi" |
  .metrics-server.resources.requests.cpu="20m" |
  .metrics-server.resources.requests.memory="150Mi"
' values.yaml