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
# add image.registry field
os=$(uname)
echo $os
# basepath=$(cd `dirname $0`; pwd)
# echo $basepath
# cd $basepath
pwd
imageRegistry=`sed -n -e '/repository: registry/=' values.yaml`
if [ $os == "Darwin" ];then
    if [ $imageRegistry ];then
        line=`sed -n -e '/repository: registry/=' values.yaml`
        echo "line is:" $line
        sed -i "" "$line i\\
    registry: m.daocloud.io/docker.io/library
        " values.yaml
    fi
elif [ $os == "Linux" ];then
    if [ $imageRegistry ];then
            line=`sed -n -e '/repository: registry/=' values.yaml`
            echo "line is:" $line
            sed -i "$line i \    registry: m.daocloud.io/docker.io/library" values.yaml
    fi
fi

# sub charts
imageRegistry=`sed -n -e '/repository: registry/=' charts/docker-registry/values.yaml`
if [ $os == "Darwin" ];then
    if [ $imageRegistry ];then
        line=`sed -n -e '/repository: registry/=' charts/docker-registry/values.yaml`
        echo "line is:" $line
        sed -i "" "$line i\\
  registry: m.daocloud.io/docker.io/library
        " charts/docker-registry/values.yaml
    fi
elif [ $os == "Linux" ];then
    if [ $imageRegistry ];then
            line=`sed -n -e '/repository: registry/=' charts/docker-registry/values.yaml`
            echo "line is:" $line
            sed -i "$line i \  registry: m.daocloud.io/docker.io/library" charts/docker-registry/values.yaml
    fi
fi

# replace cronjob.yaml image url
if [ $os == "Darwin" ];then
#  image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
  sed -i "" "s/{{ .Values.image.repository }}:{{ .Values.image.tag }}/{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag }}/g" charts/docker-registry/templates/cronjob.yaml
  sed -i "" "s/{{ .Values.image.repository }}:{{ .Values.image.tag }}/{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag }}/g" charts/docker-registry/templates/deployment.yaml
elif [ $os == "Linux" ]; then
  sed -i "s/{{ .Values.image.repository }}:{{ .Values.image.tag }}/{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag }}/g" charts/docker-registry/templates/cronjob.yaml
  sed -i "s/{{ .Values.image.repository }}:{{ .Values.image.tag }}/{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag }}/g" charts/docker-registry/templates/deployment.yaml
fi

# keyword
echo "
keywords:
  - docker-registry
" >> Chart.yaml
echo "
keywords:
  - docker-registry
" >> charts/docker-registry/Chart.yaml