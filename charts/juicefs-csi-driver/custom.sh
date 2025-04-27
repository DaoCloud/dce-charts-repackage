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

# get image from values.yaml
yq -i '.juicefs-csi-driver.image.registry="m.daocloud.io/docker.io"' values.yaml
yq -i '.juicefs-csi-driver.dashboardImage.registry="m.daocloud.io/docker.io"' values.yaml

sed -i "s/registry.k8s.io\///g" values.yaml

yq -i '.juicefs-csi-driver.sidecars.livenessProbeImage.registry="m.daocloud.io/registry.k8s.io"' values.yaml
yq -i '.juicefs-csi-driver.sidecars.nodeDriverRegistrarImage.registry="m.daocloud.io/registry.k8s.io"' values.yaml
yq -i '.juicefs-csi-driver.sidecars.csiProvisionerImage.registry="m.daocloud.io/registry.k8s.io"' values.yaml
yq -i '.juicefs-csi-driver.sidecars.csiResizerImage.registry="m.daocloud.io/registry.k8s.io"' values.yaml

# default create storageClass
yq -i '.juicefs-csi-driver.storageClasses[] |= (select(.name == "juicefs-sc") .enabled = true)' values.yaml
yq -i '.juicefs-csi-driver.storageClasses[] |= (select(.name == "juicefs-sc") | .existingSecretName = .existingSecret | del(.existingSecret))' values.yaml

yq -i '
.juicefs-csi-driver.mountPodImage = {
  "eeMountImage": {
    "registry": "m.daocloud.io/docker.io",
    "repository": "juicedata/mount",
    "tag": "ee-5.0.17-0c63dc5"
  },
  "ceMountImage": {
    "registry": "m.daocloud.io/docker.io",
    "repository": "juicedata/mount",
    "tag": "ce-v1.2.1"
  }
}
' values.yaml

yq -i '.keywords.[0]="storage"' Chart.yaml

# make sure use gnu-sed if run in mac
# change origin chart template
sed  -i 's?{{ .Values.image.repository }}?{{ .Values.image.registry }}/{{ .Values.image.repository }}?'   charts/juicefs-csi-driver/templates/controller.yaml
sed  -i 's?{{ printf "%s:%s" .Values.sidecars.csiProvisionerImage.repository .Values.sidecars.csiProvisionerImage.tag }}?{{ printf "%s/%s:%s" .Values.sidecars.csiProvisionerImage.registry .Values.sidecars.csiProvisionerImage.repository .Values.sidecars.csiProvisionerImage.tag }}?' charts/juicefs-csi-driver/templates/controller.yaml
sed  -i 's?{{ printf "%s:%s" .Values.sidecars.csiResizerImage.repository .Values.sidecars.csiResizerImage.tag }}?{{ printf "%s/%s:%s" .Values.sidecars.csiResizerImage.registry .Values.sidecars.csiResizerImage.repository .Values.sidecars.csiResizerImage.tag }}?' charts/juicefs-csi-driver/templates/controller.yaml
sed  -i 's?{{ printf "%s:%s" .Values.sidecars.livenessProbeImage.repository .Values.sidecars.livenessProbeImage.tag }}?{{ printf "%s/%s:%s" .Values.sidecars.livenessProbeImage.registry .Values.sidecars.livenessProbeImage.repository .Values.sidecars.livenessProbeImage.tag }}?' charts/juicefs-csi-driver/templates/controller.yaml
sed  -i 's?{{ printf "%s:%s" .Values.sidecars.nodeDriverRegistrarImage.repository .Values.sidecars.nodeDriverRegistrarImage.tag }}?{{ printf "%s/%s:%s" .Values.sidecars.nodeDriverRegistrarImage.registry .Values.sidecars.nodeDriverRegistrarImage.repository .Values.sidecars.nodeDriverRegistrarImage.tag }}?' charts/juicefs-csi-driver/templates/controller.yaml

sed  -i 's?{{ .Values.image.repository }}?{{ .Values.image.registry }}/{{ .Values.image.repository }}?'   charts/juicefs-csi-driver/templates/daemonset.yaml
sed  -i 's?{{ printf "%s:%s" .Values.sidecars.nodeDriverRegistrarImage.repository .Values.sidecars.nodeDriverRegistrarImage.tag }}?{{ printf "%s/%s:%s" .Values.sidecars.nodeDriverRegistrarImage.registry .Values.sidecars.nodeDriverRegistrarImage.repository .Values.sidecars.nodeDriverRegistrarImage.tag }}?' charts/juicefs-csi-driver/templates/daemonset.yaml
sed  -i 's?{{ printf "%s:%s" .Values.sidecars.livenessProbeImage.repository .Values.sidecars.livenessProbeImage.tag }}?{{ printf "%s/%s:%s" .Values.sidecars.livenessProbeImage.registry .Values.sidecars.livenessProbeImage.repository .Values.sidecars.livenessProbeImage.tag }}?' charts/juicefs-csi-driver/templates/daemonset.yaml

sed  -i 's?{{ .Values.dashboardImage.repository }}?{{ .Values.dashboardImage.registry }}/{{ .Values.dashboardImage.repository }}?'   charts/juicefs-csi-driver/templates/deployment.yaml

sed -i 's/\bsc\.existingSecret\b/sc.existingSecretName/g' charts/juicefs-csi-driver/templates/storageclass.yaml


# shellcheck disable=SC2016
sed -i '/{{- toYaml \$val | nindent 4 }}/a\
    mountPodPatch:\
      - eeMountImage: {{ printf "%s/%s:%s" .Values.mountPodImage.eeMountImage.registry .Values.mountPodImage.eeMountImage.repository .Values.mountPodImage.eeMountImage.tag }}\
        ceMountImage: {{ printf "%s/%s:%s" .Values.mountPodImage.ceMountImage.registry .Values.mountPodImage.ceMountImage.repository .Values.mountPodImage.ceMountImage.tag }}
' charts/juicefs-csi-driver/templates/configmap.yaml