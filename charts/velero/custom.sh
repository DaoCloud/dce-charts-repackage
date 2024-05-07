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
#remove the darwin part since it's out of maintenance.



# add registry variable both to parent and child chart
yq -i '.velero.image.registry="docker.m.daocloud.io"' values.yaml
yq -i "with(.image.registry; . = \"\" | . tag=\"!!null\")" charts/velero/values.yaml   # child just expose this parameter



#remove the comments for initContainers, we need them
sed -i '/initContainers:/,/^\s*$/{/^\s*$/!s/#/ /g}' values.yaml
#add more variables to make relok8s happy
yq -i '.velero.image.initContainers.veleroPluginForCsi.repository="velero/velero-plugin-for-csi"' values.yaml
yq -i '.velero.image.initContainers.veleroPluginForAws.repository="velero/velero-plugin-for-aws"' values.yaml


# get initContainers image tag from values.yaml
img0=$(yq  '.velero.initContainers[0].image' values.yaml)
arr0=(${img0//:/ })
tag0=${arr0[1]}
img1=$(yq  '.velero.initContainers[1].image' values.yaml)
arr1=(${img1//:/ })
tag1=${arr1[1]}
yq -i .velero.image.initContainers.veleroPluginForCsi.tag=\"$tag0\"  values.yaml
yq -i .velero.image.initContainers.veleroPluginForAws.tag=\"$tag1\" values.yaml

# add dce restore plugin
yq -i '
  .velero.image.initContainers.veleroPluginForMigration.registry="release.daocloud.io" |
  .velero.image.initContainers.veleroPluginForMigration.repository = "kcoral/velero-plugin-for-migration" |
  .velero.image.initContainers.veleroPluginForMigration.tag= "v0.3.0"
' values.yaml

yq -i '
  .velero.veleroPluginForMigration.enabled = false |
  .velero.veleroPluginForMigration.plugin[0].name = "velero-plugin-for-migration" |
  .velero.veleroPluginForMigration.plugin[0].image = "{{ .Values.image.initContainers.veleroPluginForMigration.registry }}/{{ .Values.image.initContainers.veleroPluginForMigration.repository }}:{{ .Values.image.initContainers.veleroPluginForMigration.tag }}" |
  .velero.veleroPluginForMigration.plugin[0].imagePullPolicy = "IfNotPresent" |
  .velero.veleroPluginForMigration.plugin[0].volumeMounts[0].mountPath = "/target" |
  .velero.veleroPluginForMigration.plugin[0].volumeMounts[0].name = "plugins"
' values.yaml



# change image string to go-template,
sed -i 's/image: velero\/velero-plugin-for-csi:v.*/image: "{{ .Values.image.registry }}\/{{ .Values.image.initContainers.veleroPluginForCsi.repository }}:{{ .Values.image.initContainers.veleroPluginForCsi.tag }}"/' values.yaml
sed -i 's/image: velero\/velero-plugin-for-aws:v.*/image: "{{ .Values.image.registry }}\/{{ .Values.image.initContainers.veleroPluginForAws.repository }}:{{ .Values.image.initContainers.veleroPluginForAws.tag }}"/' values.yaml
#change the image style of relok8s style
sed -i  's/{{ .Values.image.repository }}/{{ .Values.image.registry }}\/{{ .Values.image.repository }}/' charts/velero/templates/*.yaml

# update template style
# reference: https://austindewey.com/2021/02/22/using-the-helm-tpl-function-to-refer-values-in-values-files/
sed -i 's/toYaml .Values.initContainers/tpl (toYaml .Values.initContainers) ./' charts/velero/templates/deployment.yaml
sed  -i -e '/initContainers:/a\{{ include "velero.plugin.for.migration" .}}' charts/velero/templates/deployment.yaml
sed -i 's/- server/&\n            - --disable-informer-cache=true \n            - --default-backup-storage-location=default-backup-storage-location/' charts/velero/templates/deployment.yaml


yq  -i '.velero.deployNodeAgent=true' values.yaml
yq  -i '.velero.upgradeCRDs=false' values.yaml
yq  -i '.velero.snapshotsEnabled=false' values.yaml
yq  -i '.velero.cleanUpCRDs=false' values.yaml
#yq  -i '."velero"."configuration"."provider"="aws"' values.yaml the configuration.provider is deprecated
yq  -i '.velero.configuration.volumeSnapshotLocation[0].provider="aws"' values.yaml
yq  -i '.velero.configuration.backupStorageLocation[0].provider="aws"'  values.yaml
yq  -i '.velero.credentials.name="velero-s3-credential"'  values.yaml


# to make `helm template test` complains ` Invalid type. Expected: string, given: null`
yq -i '
  .velero.configuration.backupStorageLocation[0].name= "default-backup-storage-location" |
  .velero.configuration.backupStorageLocation[0].bucket= "velero" |
  .velero.configuration.backupStorageLocation[0].default= true' values.yaml
# some default values
yq -i '
  .velero.configuration.backupStorageLocation[0].config.region = "us-east-1" |
  .velero.configuration.backupStorageLocation[0].config.s3ForcePathStyle = true |
  .velero.configuration.backupStorageLocation[0].config.s3Url = "" |
  .velero.credentials.secretContents.cloud = "[default]
      aws_access_key_id = <modifiy>
      aws_secret_access_key = <modifiy>"
' values.yaml


# we don't need kubectl sidecar
yq  -i 'del(."velero"."kubectl")' values.yaml

yq -i '
   .annotations["addon.kpanda.io/namespace"]="velero"|
   .annotations["addon.kpanda.io/release-name"]="velero"
' Chart.yaml

if ! grep "keywords:" Chart.yaml &>/dev/null ; then
    echo "keywords:" >> Chart.yaml
    echo "  - velero" >> Chart.yaml
    echo "  - backup" >> Chart.yaml
fi

sed -i '/configMaps:/,/runAsGroup: 999/ s/^ *#//' values.yaml
sed -i 's/ configMaps:/  configMaps:/' values.yaml
sed -i '/configMaps: {}/d' values.yaml
sed -i '/See:/d' values.yaml

# add velero-restore-helper image
tag=$(yq '.velero.image.tag' values.yaml)
yq -i '
  .velero.veleroRestoreHelper.image.registry="docker.m.daocloud.io" |
  .velero.veleroRestoreHelper.image.repository = "velero/velero-restore-helper"
'  values.yaml

yq -i .velero.veleroRestoreHelper.image.tag=\"$tag\" values.yaml

yq -i '
  .velero.configMaps.fs-restore-action-config.data.image = "{{ .Values.veleroRestoreHelper.image.registry }}/{{ .Values.veleroRestoreHelper.image.repository }}:{{ .Values.veleroRestoreHelper.image.tag }}"
' values.yaml

sed -i 's/toYaml $configMap.data/tpl (toYaml $configMap.data) $ /g'  charts/velero/templates/configmaps.yaml
