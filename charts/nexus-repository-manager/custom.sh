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

sed -i "/---/d" values.yaml

yq -i '
  .nexus-repository-manager.image.registry = "docker.m.daocloud.io" |
  .nexus-repository-manager.nexus.resources.requests.cpu = 4 |
  .nexus-repository-manager.nexus.resources.requests.memory = "8Gi" |
  .nexus-repository-manager.nexus.resources.limits.cpu = 4 |
  .nexus-repository-manager.nexus.resources.limits.memory = "8Gi" |
  .nexus-repository-manager.persistence.image.registry = "docker.m.daocloud.io" |
  .nexus-repository-manager.persistence.image.repository = "library/busybox" |
  .nexus-repository-manager.persistence.image.tag = "latest"
' values.yaml

yq -i '
  .image.registry = "docker.m.daocloud.io" |
  .nexus.resources.requests.cpu = 4 |
  .nexus.resources.requests.memory = "8Gi" |
  .nexus.resources.limits.cpu = 4 |
  .nexus.resources.limits.memory = "8Gi" |
  .persistence.image.registry = "docker.m.daocloud.io" |
  .persistence.image.repository = "library/busybox" |
  .persistence.image.tag = "latest"
' charts/nexus-repository-manager/values.yaml

sed -i 's/image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"/image: "{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag }}"/' charts/nexus-repository-manager/templates/deployment.yaml

sed -i 's/image: busybox/image: "{{ .Values.persistence.image.registry }}\/{{ .Values.persistence.image.repository }}:{{ .Values.persistence.image.tag }}"/' charts/nexus-repository-manager/templates/test/test-check-logs.yaml
sed -i 's/image: busybox/image: "{{ .Values.persistence.image.registry }}\/{{ .Values.persistence.image.repository }}:{{ .Values.persistence.image.tag }}"/' charts/nexus-repository-manager/templates/test/test-connection.yaml

#==============================
echo "fulfill tag"
sed -i 's@tag: ""@tag: "master"@g' values.yaml
exit $?