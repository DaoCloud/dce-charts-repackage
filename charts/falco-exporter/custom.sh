#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

[ -f "values.yaml" ] || { echo "error, failed to find values.yaml " ; exit 1 ; }
#========================= add your customize bellow ====================
#===============================

set -o errexit
set -o pipefail
set -o nounset
set -x

yq -i ' .falco-exporter.image.registry = "docker.m.daocloud.io" ' values.yaml

yq -i ' .falco-exporter.serviceMonitor.enabled = true ' values.yaml
yq -i ' .falco-exporter.serviceMonitor.additionalLabels."operator.insight.io/managed-by" = "insight" ' values.yaml

yq -i ' .falco-exporter.prometheusRules.enabled = true ' values.yaml
yq -i ' .falco-exporter.prometheusRules.additionalLabels."operator.insight.io/managed-by" = "insight" ' values.yaml

yq -i ' .falco-exporter.resources.limits.cpu = "100m" ' values.yaml
yq -i ' .falco-exporter.resources.requests.cpu = "10m" ' values.yaml
yq -i ' .falco-exporter.resources.limits.memory = "128Mi" ' values.yaml
yq -i ' .falco-exporter.resources.requests.memory = "15Mi" ' values.yaml

rm -rf charts/falco-exporter/templates/tests
