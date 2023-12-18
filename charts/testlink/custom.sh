#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================
set -o errexit
set -o pipefail
set -o nounset

yq -i '.testlink.service.type = "ClusterIP" ' values.yaml

DB_METRIC_IMAGE_TAG=$(yq e '.metrics.image.tag' charts/testlink/charts/mariadb/values.yaml | tr -d '\n' | tr -d '\r')
DB_VOLUME_PERMISSIONS_IMAGE_TAG=$(yq e '.volumePermissions.image.tag' charts/testlink/charts/mariadb/values.yaml | tr -d '\n' | tr -d '\r')
DB_IMAGE_TAG=$(yq e '.image.tag' charts/testlink/charts/mariadb/values.yaml | tr -d '\n' | tr -d '\r')

yq -i '
  .testlink.certificates.image.registry = "docker.m.daocloud.io" |
  .testlink.metrics.image.registry = "docker.m.daocloud.io" |
  .testlink.volumePermissions.image.registry = "docker.m.daocloud.io" |
  .testlink.image.registry = "m.daocloud.io/marketplace.azurecr.io" |
  .testlink.global.imageRegistry = "m.daocloud.io/marketplace.azurecr.io" |
  .testlink.mariadb.image.registry = "docker.m.daocloud.io" |
  .testlink.mariadb.image.repository = "bitnami/mariadb" |
  .testlink.mariadb.metrics.image.registry = "docker.m.daocloud.io" |
  .testlink.mariadb.metrics.image.repository = "bitnami/mysqld-exporter" |
  .testlink.mariadb.volumePermissions.image.registry = "docker.m.daocloud.io" |
  .testlink.mariadb.volumePermissions.image.repository = "bitnami/bitnami-shell"
' values.yaml

yq -i "
  .testlink.mariadb.image.tag = \"$DB_IMAGE_TAG\" |
  .testlink.mariadb.metrics.image.tag = \"$DB_METRIC_IMAGE_TAG\" |
  .testlink.mariadb.volumePermissions.image.tag = \"$DB_VOLUME_PERMISSIONS_IMAGE_TAG\"
" values.yaml

yq -i '
  .mariadb.image.registry = "docker.m.daocloud.io" |
  .mariadb.image.repository = "bitnami/mariadb" |
  .mariadb.metrics.image.registry = "docker.m.daocloud.io" |
  .mariadb.metrics.image.repository = "bitnami/mysqld-exporter" |
  .mariadb.volumePermissions.image.registry = "docker.m.daocloud.io" |
  .mariadb.volumePermissions.image.repository = "bitnami/bitnami-shell"
' charts/testlink/values.yaml

yq -i "
  .mariadb.image.tag = \"$DB_IMAGE_TAG\" |
  .mariadb.metrics.image.tag = \"$DB_METRIC_IMAGE_TAG\" |
  .mariadb.volumePermissions.image.tag = \"$DB_VOLUME_PERMISSIONS_IMAGE_TAG\"
" charts/testlink/values.yaml

yq -i '
  .image.registry = "docker.m.daocloud.io" |
  .volumePermissions.registry = "docker.m.daocloud.io" |
  .volumePermissions.image.registry = "docker.m.daocloud.io" |
  .metrics.registry = "docker.m.daocloud.io" |
  .metrics.image.registry = "docker.m.daocloud.io" |
  .global.imageRegistry = "m.daocloud.io/marketplace.azurecr.io"
' charts/testlink/charts/mariadb/values.yaml

#==============================
echo "fulfill tag"
sed -i 's@tag: ""@tag: "master"@g' values.yaml
exit $?