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

#==============================

echo "keywords:" >> Chart.yaml
echo "- hpa" >> Chart.yaml


rm -rf ./charts/opentelemetry-demo/charts/opentelemetry-demo/ci

if [ "$(uname)" == "Darwin" ];then
  sed  -i '' 's?"{{ .Values.extensions.dataservice.image.repository }}:{{ .Values.extensions.dataservice.image.tag | default .Chart.AppVersion }}"?"{{ .Values.extensions.dataservice.image.registry }}/{{ .Values.extensions.dataservice.image.repository }}:{{ .Values.extensions.dataservice.image.tag | default .Chart.AppVersion }}"?'   charts/opentelemetry-demo/templates/dataservice/dataservice.yaml
  sed  -i '' 's?"{{ .Values.redisOperator.imageName }}:{{ .Values.redisOperator.imageTag }}"?"{{ .Values.redisOperator.registry }}/{{ .Values.redisOperator.repository }}:{{ .Values.redisOperator.tag }}"?'   charts/opentelemetry-demo/charts/redis-operator/templates/operator-deployment.yaml
  sed  -i '' 's?mysql:8.0.31?"{{ .Values.extensions.mysql.image.registry }}/{{ .Values.extensions.mysql.image.repository }}:{{ .Values.extensions.mysql.image.tag }}"\n        resources:\n          {{- toYaml .Values.extensions.mysql.resources | nindent 10 }}?'   charts/opentelemetry-demo/templates/dataservice/mysql.yaml
  sed  -i '' 's?"{{ .Values.image.repository }}:{{ .Values.image.tag }}"?"{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"?'   charts/opentelemetry-demo/charts/opentelemetry-demo/charts/prometheus/charts/kube-state-metrics/templates/deployment.yaml
  sed  -i '' 's?"{{ .Values.server.image.repository }}:{{ .Values.server.image.tag }}"?"{{ .Values.server.image.registry }}/{{ .Values.server.image.repository }}:{{ .Values.server.image.tag }}"?'   charts/opentelemetry-demo/charts/opentelemetry-demo/charts/prometheus/templates/server/sts.yaml
  sed  -i '' 's?"{{ .Values.server.image.repository }}:{{ .Values.server.image.tag }}"?"{{ .Values.server.image.registry }}/{{ .Values.server.image.repository }}:{{ .Values.server.image.tag }}"?'   charts/opentelemetry-demo/charts/opentelemetry-demo/charts/prometheus/templates/server/deploy.yaml
  sed  -i '' 's?{{ .Values.image.repository }}?{{ .Values.image.registry }}/{{ .Values.image.repository }}?'   charts/opentelemetry-demo/charts/opentelemetry-demo/charts/grafana/templates/_pod.tpl
  sed  -i '' 's?{{ .Values.image.repository }}?{{ .Values.image.registry }}/{{ .Values.image.repository }}?'   charts/opentelemetry-demo/charts/opentelemetry-demo/charts/opentelemetry-collector/templates/_pod.tpl
  sed  -i '' 's?{{ .imageOverride.repository | default .defaultValues.image.repository }}?{{ if and .imageOverride.registry .imageOverride.repository}}{{ .imageOverride.registry }}/{{ .imageOverride.repository }}{{ else }}{{ .defaultValues.image.repository }}{{ end }}?'   charts/opentelemetry-demo/charts/opentelemetry-demo/templates/_objects.tpl
  sed  -i '' 's?docker.m.daocloud.io/otel/demo:v1.1.0-cartservice?{{.Values.cartservice.image.registry}}/{{.Values.cartservice.image.repository}}:{{.Values.cartservice.image.tag}}?'   charts/opentelemetry-demo/templates/cartservice.yaml
  sed  -i '' 's?"{{ .Values.testFramework.image}}:{{ .Values.testFramework.tag }}"?"{{ .Values.testFramework.image.registry}}/{{.Values.testFramework.image.repository}}:{{ .Values.testFramework.image.tag }}"?'   charts/opentelemetry-demo/charts/opentelemetry-demo/charts/grafana/templates/tests/test.yaml
  sed  -i '' 's?image: "bats/bats"?image: {}?'   charts/opentelemetry-demo/charts/opentelemetry-demo/charts/grafana/values.yaml
  sed  -i '' 's?"repository"?        "registry": {\n          "type": "string"\n        },\n        "repository"?'   charts/opentelemetry-demo/charts/opentelemetry-demo/values.schema.json
  sed  -i '' 's?"repository"?        "registry": {\n          "type": "string"\n        },\n        "repository"?'   charts/opentelemetry-demo/charts/opentelemetry-demo/charts/opentelemetry-collector/values.schema.json
else
  sed  -i  's?"{{ .Values.extensions.dataservice.image.repository }}:{{ .Values.extensions.dataservice.image.tag | default .Chart.AppVersion }}"?"{{ .Values.extensions.dataservice.image.registry }}/{{ .Values.extensions.dataservice.image.repository }}:{{ .Values.extensions.dataservice.image.tag | default .Chart.AppVersion }}"?'   charts/opentelemetry-demo/templates/dataservice/dataservice.yaml
  sed  -i  's?"{{ .Values.redisOperator.imageName }}:{{ .Values.redisOperator.imageTag }}"?"{{ .Values.redisOperator.registry }}/{{ .Values.redisOperator.repository }}:{{ .Values.redisOperator.tag }}"?'   charts/opentelemetry-demo/charts/redis-operator/templates/operator-deployment.yaml
  sed  -i  's?mysql:8.0.31?"{{ .Values.extensions.mysql.image.registry }}/{{ .Values.extensions.mysql.image.repository }}:{{ .Values.extensions.mysql.image.tag }}"\n        resources:\n          {{- toYaml .Values.extensions.mysql.resources | nindent 10 }}?'   charts/opentelemetry-demo/templates/dataservice/mysql.yaml
  sed  -i  's?"{{ .Values.image.repository }}:{{ .Values.image.tag }}"?"{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"?'   charts/opentelemetry-demo/charts/opentelemetry-demo/charts/prometheus/charts/kube-state-metrics/templates/deployment.yaml
  sed  -i  's?"{{ .Values.server.image.repository }}:{{ .Values.server.image.tag }}"?"{{ .Values.server.image.registry }}/{{ .Values.server.image.repository }}:{{ .Values.server.image.tag }}"?'   charts/opentelemetry-demo/charts/opentelemetry-demo/charts/prometheus/templates/server/sts.yaml
  sed  -i  's?"{{ .Values.server.image.repository }}:{{ .Values.server.image.tag }}"?"{{ .Values.server.image.registry }}/{{ .Values.server.image.repository }}:{{ .Values.server.image.tag }}"?'   charts/opentelemetry-demo/charts/opentelemetry-demo/charts/prometheus/templates/server/deploy.yaml
  sed  -i  's?{{ .Values.image.repository }}?{{ .Values.image.registry }}/{{ .Values.image.repository }}?'   charts/opentelemetry-demo/charts/opentelemetry-demo/charts/grafana/templates/_pod.tpl
  sed  -i  's?{{ .Values.image.repository }}?{{ .Values.image.registry }}/{{ .Values.image.repository }}?'   charts/opentelemetry-demo/charts/opentelemetry-demo/charts/opentelemetry-collector/templates/_pod.tpl
  sed  -i  's?{{ .imageOverride.repository | default .defaultValues.image.repository }}?{{ if and .imageOverride.registry .imageOverride.repository}}{{ .imageOverride.registry }}/{{ .imageOverride.repository }}{{ else }}{{ .defaultValues.image.repository }}{{ end }}?'   charts/opentelemetry-demo/charts/opentelemetry-demo/templates/_objects.tpl
  sed  -i  's?docker.m.daocloud.io/otel/demo:v1.1.0-cartservice?{{.Values.cartservice.image.registry}}/{{.Values.cartservice.image.repository}}:{{.Values.cartservice.image.tag}}?'   charts/opentelemetry-demo/templates/cartservice.yaml
  sed  -i  's?"{{ .Values.testFramework.image}}:{{ .Values.testFramework.tag }}"?"{{ .Values.testFramework.image.registry}}/{{.Values.testFramework.image.repository}}:{{ .Values.testFramework.image.tag }}"?'   charts/opentelemetry-demo/charts/opentelemetry-demo/charts/grafana/templates/tests/test.yaml
  sed  -i  's?image: "bats/bats"?image: {}?'   charts/opentelemetry-demo/charts/opentelemetry-demo/charts/grafana/values.yaml
  sed  -i  's?"repository"?        "registry": {\n          "type": "string"\n        },\n        "repository"?'   charts/opentelemetry-demo/charts/opentelemetry-demo/values.schema.json
  sed  -i  's?"repository"?        "registry": {\n          "type": "string"\n        },\n        "repository"?'   charts/opentelemetry-demo/charts/opentelemetry-demo/charts/opentelemetry-collector/values.schema.json
fi
