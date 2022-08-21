#!/bin/bash

if ! which helm &>/dev/null ; then
    echo "error, please install 'helm'"
    exit 1
fi

PROJECT_NAME=$1
[ -n "$PROJECT_NAME" ] || { echo "error, empty PROJECT_NAME" ; exit 1 ; }

echo "generate helm chart for $PROJECT_NAME"

#=== prepare directory
CURRENT_FILENAME=$( basename $0 )
CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)
PROJECT_ROOT_PATH=$( cd ${CURRENT_DIR_PATH}/.. && pwd )

PROJECT_SRC_DIR=${PROJECT_ROOT_PATH}/charts/${PROJECT_NAME}
PROJECT_SRC_CONFIG_PATH=${PROJECT_SRC_DIR}/config
[ -d "$PROJECT_SRC_DIR" ] || { echo "error, failed to find project directory: $PROJECT_SRC_DIR" ; exit 2 ; }
CHART_DEST_DIR=${PROJECT_SRC_DIR}/${PROJECT_NAME}

if [ ! -f "$PROJECT_SRC_CONFIG_PATH" ] ; then
  echo "failed to find project config: $PROJECT_SRC_CONFIG_PATH, ignore package $PROJECT_NAME "
  exit 0
fi


BUILD_DIR=${PROJECT_ROOT_PATH}/build/${PROJECT_NAME}
CHART_BUILD_DIR=${BUILD_DIR}/${PROJECT_NAME}
rm -rf $BUILD_DIR &>/dev/null
mkdir -p ${BUILD_DIR}


#=== load config

echo "load config from $PROJECT_SRC_CONFIG_PATH "
source $PROJECT_SRC_CONFIG_PATH

#=========
if [ "$USE_OPENSOURCE_CHART" == true ] ; then
    echo "generate $PROJECT_NAME chart from opensource chart"
    rm -rf $CHART_DEST_DIR
    helm repo add $REPO_NAME $REPO_URL
    helm repo update $REPO_NAME
    cd ${PROJECT_SRC_DIR}
    helm pull ${REPO_NAME}/${CHART_NAME} --untar --version $VERSION
    echo "succeeded to generate chart to $CHART_DEST_DIR"
    exit 0
fi

#======

echo "generate $PROJECT_NAME chart from custom chart "
helm repo add $REPO_NAME $REPO_URL
(($?!=0)) && echo "error, failed to add repo" && exit 7
helm repo update $REPO_NAME

cd $BUILD_DIR
helm pull ${REPO_NAME}/${CHART_NAME} --untar --version $VERSION
(($?!=0)) && echo "error, failed to helm pull" && exit 8

mv ${BUILD_DIR}/$(ls ${BUILD_DIR} )  ${BUILD_DIR}/child
DOWNLOAD_CHART_DIR=${BUILD_DIR}/child

mkdir -p $CHART_BUILD_DIR
mkdir -p ${CHART_BUILD_DIR}/charts

cd ${CHART_BUILD_DIR}/charts
helm pull ${REPO_NAME}/${CHART_NAME} --untar --version $VERSION
(($?!=0)) && echo "error, failed to helm pull" && exit 8

for FILE in README.md Chart.yaml values.schema.json ; do
    [ ! -f ${DOWNLOAD_CHART_DIR}/${FILE} ] && continue
    cp ${DOWNLOAD_CHART_DIR}/${FILE}  ${CHART_BUILD_DIR}
done

echo "generate values.yaml"
# make parent values.yaml to export child values.yaml
echo "# child values" > ${CHART_BUILD_DIR}/values.yaml
echo "${CHART_NAME}:" >> ${CHART_BUILD_DIR}/values.yaml
# add 2 blank for each line
sed -E 's/(.*)/  \1/g' ${DOWNLOAD_CHART_DIR}/values.yaml >> ${CHART_BUILD_DIR}/values.yaml


echo "auto inject dependencies to original Chart.yaml"
cat <<EOF >> ${CHART_BUILD_DIR}/Chart.yaml
dependencies:
  - name: $CHART_NAME
    version: "${VERSION}"
    repository: "${REPO_URL}"
EOF

if [ -n "${APPEND_VALUES_FILE}" ] && [ -s ${PROJECT_SRC_DIR}/${APPEND_VALUES_FILE} ] ; then
    echo "append ${APPEND_VALUES_FILE} to opensource values.yaml"
    cat ${PROJECT_SRC_DIR}/${APPEND_VALUES_FILE} >> ${CHART_BUILD_DIR}/values.yaml
fi

if [ -d "${PROJECT_SRC_DIR}/parent" ] ;then
    echo "overwrite /chart to parent chart"
    cp -rf ${PROJECT_SRC_DIR}/parent/*  ${CHART_BUILD_DIR}
fi

if [ ! -f ${CHART_BUILD_DIR}/values.schema.json ] ; then
    echo "auto generate values.schema.json"
    if ! helm schema-gen -h &>/dev/null ; then
        echo "install helm-schema-gen "
        helm plugin install https://github.com/karuppiah7890/helm-schema-gen.git
    fi
    cd  ${CHART_BUILD_DIR}
    helm schema-gen values.yaml > values.schema.json
    (($?!=0)) && echo "error, failed to call schema-gen" && exit 9
fi

if [ -n "$CUSTOM_SHELL" ] && [ -s ${PROJECT_SRC_DIR}/${CUSTOM_SHELL} ] ; then
    echo "--------- call custom script: ${PROJECT_SRC_DIR}/${CUSTOM_SHELL} ${CHART_BUILD_DIR} "
    chmod +x ${PROJECT_SRC_DIR}/${CUSTOM_SHELL}
    ${PROJECT_SRC_DIR}/${CUSTOM_SHELL} ${CHART_BUILD_DIR}
    (($?!=0)) && echo "error, failed to call ${PROJECT_SRC_DIR}/${CUSTOM_SHELL}" && exit 10
    echo "--------- finish custom script "
fi

# maybe fail owing to shema.json
#echo "helm lint "
#helm lint ${CHART_BUILD_DIR}  --debug
#(($?!=0)) && echo "error, failed to call helm lint " && exit 11

cd ${BUILD_DIR}
helm package ${CHART_BUILD_DIR}
(($?!=0)) && echo "error, failed to call helm package " && exit 12

rm -rf $CHART_DEST_DIR
cp -rf ${CHART_BUILD_DIR} ${CHART_DEST_DIR}

exit 0
