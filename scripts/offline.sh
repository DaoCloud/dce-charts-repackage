#/bin/bash

# generate amd or arm

CURRENT_FILENAME=$( basename $0 )
CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)
PROJECT_ROOT_PATH=$( cd ${CURRENT_DIR_PATH}/.. && pwd )

CHART_DIRECTORY="${PROJECT_ROOT_PATH}/charts"

OUTPUT_DIR="${PROJECT_ROOT_PATH}/build/offline"
rm -rf ${OUTPUT_DIR}
mkdir -p ${OUTPUT_DIR}

IGNORE_IMAGE_PRO=" coredns-metrics "

CHART_LIST=$( ls ${CHART_DIRECTORY} )
cd ${OUTPUT_DIR}
for PRO in ${CHART_LIST} ; do
    CHART_DIR=${CHART_DIRECTORY}/${PRO}/${PRO}
    if [ ! -d "${CHART_DIR}" ] ; then
      continue
    fi
    echo "-------- package for ${PRO} "
    helm package ${CHART_DIR}
    (( $? != 0 )) && echo "error, failed to package chart ${CHART_DIR}" && exit 1

    grep " ${PRO} " <<< "$IGNORE_IMAGE_PRO" &>/dev/null && continue

    IMAGE_LIST=$( helm template ${CHART_DIR} | grep " image: " | awk '{print $2}' | sort  | uniq | tr -d '"' )
    if [ -z "$IMAGE_LIST" ] ; then
        echo "failed to get image from ${CHART_DIR}"
        exit 1
    else
        echo "${IMAGE_LIST}"
    fi

    for IMAGE in ${IMAGE_LIST} ; do
        docker pull ${IMAGE}
        (( $? != 0 )) && echo "error, failed to pull image ${IMAGE}" && exit 1
        TAR_NAME=${IMAGE//\//-}
        TAR_NAME=${TAR_NAME//:/_}
        docker save -o ${TAR_NAME}.tar  $IMAGE
        (( $? != 0 )) && echo "error, failed to save image ${IMAGE}" && exit 1
    done

done

exit 0
