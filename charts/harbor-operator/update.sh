#!/bin/bash

set -x 
set -o errexit
set -o nounset
set -o pipefail


CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

cd $CURRENT_DIR_PATH
if [ ! -d "chart-harbor-operator" ]; then
    git clone https://github.com/goharbor/harbor-operator.git chart-harbor-operator
fi
cd chart-harbor-operator && git checkout $VERSION && cd ../
cp -rf chart-harbor-operator/charts/harbor-operator . && rm -rf chart-harbor-operator
ls -lh

cp .relok8s-images.yaml ./harbor-operator/

# add image.registry field
imageRegistry=`sed -n -e 'registry: release.daocloud.io' harbor-operator/values.yaml`
os=$(uname)
echo $os

if [ $os == "Darwin" ];then
    if [ ! $imageRegistry ];then
        line=`sed -n -e '/# image.repository/=' harbor-operator/values.yaml`
        echo "line is:" $line
        sed -i "" "$line i\\
  registry: release.daocloud.io
        " harbor-operator/values.yaml
    fi
elif [ $os == "Linux" ];then
    if [ ! $imageRegistry ];then
            line=`sed -n -e '/# image.repository/=' harbor-operator/values.yaml`
            echo "line is:" $line
            sed -i "$line i \  registry: release.daocloud.io" harbor-operator/values.yaml
    fi
fi

# add harbor every compose repository and harbor tag version
echo "
harbor:
  tag: ${HARBOR_VERSION}
  core:
    repository: goharbor/harbor-core
  nginx:
     repository: goharbor/nginx-photon
  chartmuseum:
     repository: goharbor/chartmuseum-photon
  jobservice:
     repository: goharbor/harbor-jobservice
  registryctl:
     repository: goharbor/harbor-registryctl
  distribution:
     repository: goharbor/registry-photon
  portal:
     repository: goharbor/harbor-portal
  trivy:
     repository: goharbor/trivy-adapter-photon
" >> harbor-operator/values.yaml

pwd
if [ ! -f ./harbor-operator/values.schema.json ] ; then
    echo "auto generate values.schema.js on"
    if ! helm schema-gen -h &>/dev/null ; then
        echo "install helm-schema-gen "
        helm plugin install https://github.com/karuppiah7890/helm-schema-gen.git
    fi
    cd  ./harbor-operator
    ls -lh
    helm schema-gen values.yaml > ./values.schema.json
    (($?!=0)) && echo "error, failed to call schema-gen" && exit 9
    cd ../
fi

# echo $VERSION
ChartVersion=`echo ${VERSION}|sed 's/v//' | sed 's/-rc1//'`
if [ $os == "Linux" ];then
    sed -i "s/version: 0.1.0/version: ${ChartVersion}/g" harbor-operator/Chart.yaml
elif [ $os == "Darwin" ];then
    sed -i "" "s/version: 0.1.0/version: ${ChartVersion}/g" harbor-operator/Chart.yaml
fi

startLine=`sed -n -e '/dependencies:/=' harbor-operator/Chart.yaml`
if [ ! $startLine ];then
    echo "not found"
    exit 0
fi
endLine=`sed -n -e '/- database/=' harbor-operator/Chart.yaml`
if [ $os == "Linux" ];then
    sed -i "$startLine","$endLine"d harbor-operator/Chart.yaml
elif [ $os == "Darwin" ];then
    sed -i '' "$startLine","$endLine"d harbor-operator/Chart.yaml
fi

# replace image url
if [ $os == "Linux" ];then
  sed -i "s/'{{.Values.image.repository}}:{{.Values.image.tag|default .Chart.AppVersion}}'/\"{{ .Values.image.registry }}\/{{.Values.image.repository}}:{{.Values.image.tag|default .Chart.AppVersion}}\"/g" harbor-operator/templates/deployment.yaml
elif [ $os == "Darwin" ];then
  sed -i "" "s/'{{.Values.image.repository}}:{{.Values.image.tag|default .Chart.AppVersion}}'/\"{{ .Values.image.registry }}\/{{.Values.image.repository}}:{{.Values.image.tag|default .Chart.AppVersion}}\"/g" harbor-operator/templates/deployment.yaml
fi

# send keyword to Chart.yaml
echo "
keywords:
  - harbor-operator
" >> harbor-operator/Chart.yaml

# remove README.md
rm -rf harbor-operator/README.md
rm -rf harbor-operator/README.md.gotmpl

# update installCRDs: true
if [ $os == "Linux" ];then
    sed -i "s/installCRDs: false/installCRDs: true/g" harbor-operator/values.yaml
elif [ $os == "Darwin" ];then
    sed -i "" "s/installCRDs: false/installCRDs: true/g" harbor-operator/values.yaml
fi

# replace values.schema.json
cp ./parent/values.schema.json ./harbor-operator/values.schema.json


yq -i '
   .annotations["addon.kpanda.io/namespace"]="kangaroo-system"|
   .annotations["addon.kpanda.io/release-name"]="harbor-operator"
' harbor-operator/Chart.yaml