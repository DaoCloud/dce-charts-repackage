#!/bin/bash

PROJECT_PATH=$(pwd)

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================
#===============================

yq -i '
  .nxrm-ha.license.enabled = false |
  .nxrm-ha.statefulset.container.image.registry = "docker.m.daocloud.io" |
  .nxrm-ha.statefulset.container.image.repository = "sonatype/nexus3" |
  .nxrm-ha.statefulset.container.image.tag = "latest" |
  .nxrm-ha.statefulset.requestLogContainer.image.registry = "docker.m.daocloud.io" |
  .nxrm-ha.statefulset.requestLogContainer.image.repository = "library/busybox" |
  .nxrm-ha.statefulset.requestLogContainer.image.tag = "latest" |
  .nxrm-ha.statefulset.initContainer.image.registry = "docker.m.daocloud.io" |
  .nxrm-ha.statefulset.initContainer.image.repository = "library/busybox" |
  .nxrm-ha.statefulset.initContainer.image.tag = "latest" |
  .nxrm-ha.statefulset.auditLogContainer.image.registry = "docker.m.daocloud.io" |
  .nxrm-ha.statefulset.auditLogContainer.image.repository = "library/busybox" |
  .nxrm-ha.statefulset.auditLogContainer.image.tag = "latest" |
  .nxrm-ha.statefulset.taskLogContainer.image.registry = "docker.m.daocloud.io" |
  .nxrm-ha.statefulset.taskLogContainer.image.repository = "library/busybox" |
  .nxrm-ha.statefulset.taskLogContainer.image.tag = "latest"
' values.yaml

sed -i 's/cpu: [0-9]/cpu: "4"/g' values.yaml

yq -i '
  .license.enabled=false |
  .statefulset.container.image.registry = "docker.m.daocloud.io" |
  .statefulset.container.image.repository = "sonatype/nexus3" |
  .statefulset.container.image.tag = "latest" |
  .statefulset.initContainer.image.registry = "docker.m.daocloud.io" |
  .statefulset.initContainer.image.repository = "library/busybox" |
  .statefulset.initContainer.image.tag = "latest" |
  .statefulset.requestLogContainer.image.registry = "docker.m.daocloud.io" |
  .statefulset.requestLogContainer.image.repository = "library/busybox" |
  .statefulset.requestLogContainer.image.tag = "latest" |
  .statefulset.auditLogContainer.image.registry = "docker.m.daocloud.io" |
  .statefulset.auditLogContainer.image.repository = "library/busybox" |
  .statefulset.auditLogContainer.image.tag = "latest" |
  .statefulset.taskLogContainer.image.registry = "docker.m.daocloud.io" |
  .statefulset.taskLogContainer.image.repository = "library/busybox" |
  .statefulset.taskLogContainer.image.tag = "latest"
' charts/nxrm-ha/values.yaml

sed -i 's/cpu: [0-9]/cpu: "4"/g' charts/nxrm-ha/values.yaml

sed -i 's/image: busybox:1.33.1/image: "{{ .Values.statefulset.initContainer.image.registry }}\/{{ .Values.statefulset.initContainer.image.repository }}:{{ .Values.statefulset.initContainer.image.tag }}"/' values.yaml

sed -i 's/{{- if .Values.secret.license.licenseSecret.enabled }}/{{- if and .Values.license.enabled .Values.secret.license.licenseSecret.enabled }}/' charts/nxrm-ha/templates/license-config-mapping.yaml
sed -i 's/{{- if or .Values.aws.secretmanager.enabled .Values.azure.keyvault.enabled  }}/{{- if and .Values.license.enabled (or .Values.aws.secretmanager.enabled .Values.azure.keyvault.enabled)  }}/' charts/nxrm-ha/templates/statefulset.yaml
sed -i 's/value: "{{ .Values.statefulset.container.env.install4jAddVmParams }} -Dnexus.licenseFile=${LICENSE_FILE} \\/value: "{{ .Values.statefulset.container.env.install4jAddVmParams }} {{- if .Values.license.enabled }}-Dnexus.licenseFile=${LICENSE_FILE}{{ end }} \\/' charts/nxrm-ha/templates/statefulset.yaml
sed -i 's/image: {{ .Values.statefulset.requestLogContainer.image.repository }}:{{ .Values.statefulset.requestLogContainer.image.tag }}/image: "{{ .Values.statefulset.requestLogContainer.image.registry }}\/{{ .Values.statefulset.requestLogContainer.image.repository }}:{{ .Values.statefulset.requestLogContainer.image.tag }}"/' charts/nxrm-ha/templates/statefulset.yaml
sed -i 's/image: {{ .Values.statefulset.auditLogContainer.image.repository }}:{{ .Values.statefulset.auditLogContainer.image.tag }}/image: "{{ .Values.statefulset.auditLogContainer.image.registry }}\/{{ .Values.statefulset.auditLogContainer.image.repository }}:{{ .Values.statefulset.auditLogContainer.image.tag }}"/' charts/nxrm-ha/templates/statefulset.yaml
sed -i 's/image: {{ .Values.statefulset.taskLogContainer.image.repository }}:{{ .Values.statefulset.taskLogContainer.image.tag }}/image: "{{ .Values.statefulset.taskLogContainer.image.registry }}\/{{ .Values.statefulset.taskLogContainer.image.repository }}:{{ .Values.statefulset.taskLogContainer.image.tag }}"/' charts/nxrm-ha/templates/statefulset.yaml
sed -i 's/image: {{ .Values.statefulset.container.image.repository }}:{{ .Values.statefulset.container.image.tag }}/image: "{{ .Values.statefulset.container.image.registry }}\/{{ .Values.statefulset.container.image.repository }}:{{ .Values.statefulset.container.image.tag }}"/' charts/nxrm-ha/templates/statefulset.yaml
sed -i 's/{{ toYaml .Values.statefulset.initContainers | nindent 8 }}/{{- tpl (toYaml .Values.statefulset.initContainers) . | nindent 8 }}/'  charts/nxrm-ha/templates/statefulset.yaml
#==============================