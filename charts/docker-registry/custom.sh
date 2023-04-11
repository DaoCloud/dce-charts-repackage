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
    registry: m.daocloud.io/docker.io
        " values.yaml
    fi
    sed -i "" "s/repository: registry/repository: library\/registry/g" values.yaml
elif [ $os == "Linux" ];then
    if [ $imageRegistry ];then
            line=`sed -n -e '/repository: registry/=' values.yaml`
            echo "line is:" $line
            sed -i "$line i \    registry: m.daocloud.io/docker.io" values.yaml
    fi
    sed -i "s/repository: registry/repository: library\/registry/g" values.yaml
fi

# sub charts
imageRegistry=`sed -n -e '/repository: registry/=' charts/docker-registry/values.yaml`
if [ $os == "Darwin" ];then
    if [ $imageRegistry ];then
        line=`sed -n -e '/repository: registry/=' charts/docker-registry/values.yaml`
        echo "line is:" $line
        sed -i "" "$line i\\
  registry: m.daocloud.io/docker.io
        " charts/docker-registry/values.yaml
    fi
    sed -i "" "s/repository: registry/repository: library\/registry/g" charts/docker-registry/values.yaml
elif [ $os == "Linux" ];then
    if [ $imageRegistry ];then
            line=`sed -n -e '/repository: registry/=' charts/docker-registry/values.yaml`
            echo "line is:" $line
            sed -i "$line i \  registry: m.daocloud.io/docker.io" charts/docker-registry/values.yaml
    fi
    sed -i "s/repository: registry/repository: library\/registry/g" charts/docker-registry/values.yaml
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

# open resources
if [ $os == "Darwin" ];then
           sed -i "" "s/resources: {}/resources: /g" values.yaml
          sed -i "" "s/# limits:/limits:/g" values.yaml
          sed -i "" "s/#  cpu: 100m/  cpu: 100m/g" values.yaml
          sed -i "" "s/#  memory: 128Mi/  memory: 128Mi/g" values.yaml
          sed -i "" "s/# requests:/requests:/g" values.yaml

      sed -i "" "s/resources: {}/resources: /g" charts/docker-registry/values.yaml
      sed -i "" "s/# limits:/limits:/g" charts/docker-registry/values.yaml
      sed -i "" "s/#  cpu: 100m/  cpu: 100m/g" charts/docker-registry/values.yaml
      sed -i "" "s/#  memory: 128Mi/  memory: 128Mi/g" charts/docker-registry/values.yaml
      sed -i "" "s/# requests:/requests:/g" charts/docker-registry/values.yaml
elif [ $os == "Linux" ]; then
    sed -i "s/resources: {}/resources: /g" values.yaml
    sed -i "s/# limits:/limits:/g" values.yaml
    sed -i "s/#  cpu: 100m/  cpu: 100m/g" values.yaml
    sed -i "s/#  memory: 128Mi/  memory: 128Mi/g" values.yaml
    sed -i "s/# requests:/requests:/g" values.yaml

    sed -i "s/resources: {}/resources: /g" charts/docker-registry/values.yaml
    sed -i "s/# limits:/limits:/g" charts/docker-registry/values.yaml
    sed -i "s/#  cpu: 100m/  cpu: 100m/g" charts/docker-registry/values.yaml
    sed -i "s/#  memory: 128Mi/  memory: 128Mi/g" charts/docker-registry/values.yaml
    sed -i "s/# requests:/requests:/g" charts/docker-registry/values.yaml
fi