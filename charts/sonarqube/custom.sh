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

if ! which yq &>/dev/null ; then
    echo " 'yq' no found"
    if [ "$(uname)" == "Darwin" ];then
      exit 1
    fi
    echo "try to install..."
    YQ_VERSION=v4.30.6
    YQ_BINARY="yq_$(uname | tr 'A-Z' 'a-z')_amd64"
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O /tmp/yq.tar.gz &&
    tar -xzf /tmp/yq.tar.gz -C /tmp &&
    mv /tmp/${YQ_BINARY} /usr/bin/yq
fi

BUSYBOX_VERSION="1.32"
CURL_VERSION="8.2.0"
SONARQUBE_VERSION="10.2.0-community"

# We set postgres image tag force cause the default is missing in bitnamilegacy repo
# ref: https://github.com/bitnami/charts/issues/35164
yq -i '
  .sonarqube.image.registry = "docker.m.daocloud.io" |
  .sonarqube.image.repository = "library/sonarqube" |
  .sonarqube.image.tag = "'$SONARQUBE_VERSION'" |
  .sonarqube.initContainers.registry = "docker.m.daocloud.io" |
  .sonarqube.initContainers.repository = "library/busybox" |
  .sonarqube.initContainers.tag = "'$BUSYBOX_VERSION'" |
  .sonarqube.initSysctl.registry = "docker.m.daocloud.io" |
  .sonarqube.initSysctl.repository = "library/busybox" |
  .sonarqube.initSysctl.tag = "'$BUSYBOX_VERSION'" |
  .sonarqube.initFs.registry = "docker.m.daocloud.io" |
  .sonarqube.initFs.repository = "library/busybox" |
  .sonarqube.initFs.tag = "'$BUSYBOX_VERSION'" |
  .sonarqube.caCerts.registry = "docker.m.daocloud.io" |
  .sonarqube.caCerts.repository = "adoptopenjdk/openjdk11" |
  .sonarqube.caCerts.tag = "alpine" |
  .sonarqube.prometheusExporter.registry = "docker.m.daocloud.io" |
  .sonarqube.prometheusExporter.repository = "curlimages/curl" |
  .sonarqube.prometheusExporter.tag = "'$CURL_VERSION'" |
  .sonarqube.plugins.registry = "docker.m.daocloud.io" |
  .sonarqube.plugins.repository = "curlimages/curl" |
  .sonarqube.plugins.tag = "'$CURL_VERSION'" |
  .sonarqube.tests.image.registry="docker.m.daocloud.io" |
  .sonarqube.tests.image.repository = "library/sonarqube" |
  .sonarqube.tests.image.tag = "'$SONARQUBE_VERSION'" |
  .sonarqube.persistence.storageClass = "" |
  .sonarqube.postgresql.persistence.storageClass = "" |
  .sonarqube.ingress-nginx.controller.image.registry="k8s.m.daocloud.io" |
  .sonarqube.ingress-nginx.controller.admissionWebhooks.patch.image.registry="k8s.m.daocloud.io" |
  .sonarqube.postgresql.volumePermissions.image.registry="docker.m.daocloud.io" |
  .sonarqube.postgresql.image.registry="docker.m.daocloud.io" |
  .sonarqube.postgresql.image.repository="bitnamilegacy/postgresql" |
  .sonarqube.postgresql.image.tag="15.3.0-debian-11-r0" |
  .sonarqube.postgresql.metrics.image.registry="docker.m.daocloud.io" |
  .sonarqube.postgresql.metrics.image.repository="bitnamilegacy/postgres-exporter" |
  .sonarqube.postgresql.metrics.image.tag="0.12.0-debian-11-r86" |
  .sonarqube.postgresql.volumePermissions.image.registry="docker.m.daocloud.io" |
  .sonarqube.postgresql.volumePermissions.image.repository="bitnamilegacy/os-shell" |
  .sonarqube.postgresql.volumePermissions.image.tag="11-debian-11-r112"
' values.yaml

#change the image style of relok8s style
sed -i  's/{{ .Values.image.repository }}/{{ .Values.image.registry }}\/{{ .Values.image.repository }}/' charts/sonarqube/templates/*.yaml
#change sonarqube style
sed -i 's/image: {{ default "busybox:1.32" .Values.initContainers.image }}/image: {{ default "docker.m.daocloud.io" .Values.initContainers.registry }}\/{{ default "library\/busybox" .Values.initContainers.repository }}:{{ default "1.32" .Values.initContainers.tag }}/' charts/sonarqube/templates/deployment.yaml
sed -i 's/image: {{ default "busybox:1.32" .Values.initContainers.image }}/image: {{ default "docker.m.daocloud.io" .Values.initContainers.registry }}\/{{ default "library\/busybox" .Values.initContainers.repository }}:{{ default "1.32" .Values.initContainers.tag }}/' charts/sonarqube/templates/sonarqube-sts.yaml
sed -i 's/image: {{ default "adoptopenjdk\/openjdk11:alpine" .Values.caCerts.image }}/image: {{ default "docker.m.daocloud.io" .Values.caCerts.registry }}\/{{ default "adoptopenjdk\/openjdk11" .Values.caCerts.repository }}:{{ default "alpine" .Values.caCerts.tag }}/' charts/sonarqube/templates/deployment.yaml
sed -i 's/image: {{ default "adoptopenjdk\/openjdk11:alpine" .Values.caCerts.image }}/image: {{ default "docker.m.daocloud.io" .Values.caCerts.registry }}\/{{ default "adoptopenjdk\/openjdk11" .Values.caCerts.repository }}:{{ default "alpine" .Values.caCerts.tag }}/' charts/sonarqube/templates/sonarqube-sts.yaml
sed -i 's/image: {{ default "busybox:1.32" .Values.initSysctl.image }}/image: {{ default "docker.m.daocloud.io" .Values.initSysctl.registry }}\/{{ default "library\/busybox" .Values.initSysctl.repository }}:{{ default "1.32" .Values.initSysctl.tag }}/' charts/sonarqube/templates/deployment.yaml
sed -i 's/image: {{ default "busybox:1.32" .Values.initSysctl.image }}/image: {{ default "docker.m.daocloud.io" .Values.initSysctl.registry }}\/{{ default "library\/busybox" .Values.initSysctl.repository }}:{{ default "1.32" .Values.initSysctl.tag }}/' charts/sonarqube/templates/sonarqube-sts.yaml
sed -i 's/image: {{ default "busybox:1.32" .Values.initFs.image }}/image: {{ default "docker.m.daocloud.io" .Values.initFs.registry }}\/{{ default "library\/busybox" .Values.initFs.repository }}:{{ default "1.32" .Values.initFs.tag }}/' charts/sonarqube/templates/sonarqube-sts.yaml
sed -i 's/image: {{ default "curlimages\/curl:8.2.0" .Values.prometheusExporter.image }}/image: {{ default "docker.m.daocloud.io" .Values.prometheusExporter.registry }}\/{{ default "curlimages\/curl" .Values.prometheusExporter.repository }}:{{ default "8.2.0" .Values.prometheusExporter.tag }}/' charts/sonarqube/templates/deployment.yaml
sed -i 's/image: {{ default "curlimages\/curl:8.2.0" .Values.prometheusExporter.image }}/image: {{ default "docker.m.daocloud.io" .Values.prometheusExporter.registry }}\/{{ default "curlimages\/curl" .Values.prometheusExporter.repository }}:{{ default "8.2.0" .Values.prometheusExporter.tag }}/' charts/sonarqube/templates/sonarqube-sts.yaml
sed -i 's/image: {{ default "curlimages\/curl:8.2.0" .Values.plugins.image }}/image: {{ default "docker.m.daocloud.io" .Values.plugins.registry }}\/{{ default "curlimages\/curl" .Values.plugins.repository }}:{{ default "8.2.0" .Values.plugins.tag }}/' charts/sonarqube/templates/deployment.yaml
sed -i 's/image: {{ default "curlimages\/curl:8.2.0" .Values.plugins.image }}/image: {{ default "docker.m.daocloud.io" .Values.plugins.registry }}\/{{ default "curlimages\/curl" .Values.plugins.repository }}:{{ default "8.2.0" .Values.plugins.tag }}/' charts/sonarqube/templates/sonarqube-sts.yaml
sed -i 's/image: {{ .Values.tests.image | default (printf "%s:%s" .Values.image.repository (tpl .Values.image.tag .)) | quote }}/image: {{ default "docker.m.daocloud.io" .Values.image.registry }}\/{{ default "library\/sonarqube" .Values.image.repository }}:{{ default "10.2.0-community" .Values.image.tag }}/' charts/sonarqube/templates/tests/sonarqube-test.yaml

#==============================
echo "fulfill tag"
sed -i 's@tag: ""@tag: "master"@g' values.yaml
exit $?