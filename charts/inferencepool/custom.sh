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
yq eval -i '
  .inferencepool.inferencePool.modelServers.matchLabels.app = "inferx"
' values.yaml

yq eval -i '
  .inferencepool.inferenceExtension.resources = {
    "requests": {
      "cpu": "1",
      "memory": "1Gi"
    },
    "limits": {
      "cpu": "1",
      "memory": "1Gi"
    }
  }
' values.yaml

yq eval -i '
  .inferenceExtension.resources = {
    "requests": {
      "cpu": "1",
      "memory": "1Gi"
    },
    "limits": {
      "cpu": "1",
      "memory": "1Gi"
    }
  }
' ./charts/inferencepool/values.yaml

yq eval -i '
  .inferencepool.inferenceExtension.strategy.type = "Recreate" |
  .inferencepool.inferenceExtension.ha.enableLeaderElection = false
' values.yaml

yq eval -i '
  .inferenceExtension.strategy.type = "Recreate" |
  .inferenceExtension.ha.enableLeaderElection = false
' ./charts/inferencepool/values.yaml


# Add sidecar image fields (not present in upstream chart)
# reference: https://github.com/llm-d/llm-d/blob/main/guides/precise-prefix-cache-aware/gaie-kv-events/values_pod_discovery.yaml#L19
# By default, the sidecar in values.yaml is disabled and lacks an image, making it impossible to obtain the tag from the image. Additionally, the tag differs from the one in this chart, so the tag is fixed here.
yq eval -i '
  .inferencepool.inferenceExtension.sidecar.image = {
    "hub": "ghcr.m.daocloud.io/llm-d",
    "name": "llm-d-uds-tokenizer",
    "tag": "v0.6.0",
    "pullPolicy": "IfNotPresent"
  }
' values.yaml

yq eval -i '
  .inferenceExtension.sidecar.image = {
    "hub": "ghcr.m.daocloud.io/llm-d",
    "name": "llm-d-uds-tokenizer",
    "tag": "v0.6.0",
    "pullPolicy": "IfNotPresent"
  }
' ./charts/inferencepool/values.yaml

if [ "$(uname)" = "Darwin" ]; then
  SED_INPLACE=(-i '')
else
  SED_INPLACE=(-i)
fi

# sidecar image: replace single string with three-segment format in template
sed "${SED_INPLACE[@]}" \
  's/\.Values\.inferenceExtension\.sidecar\.image }}/\.Values\.inferenceExtension\.sidecar\.image\.registry}}\/{{ \.Values\.inferenceExtension\.sidecar\.image\.repository}}:{{ \.Values\.inferenceExtension\.sidecar\.image\.tag}}/g' \
 ./charts/inferencepool/charts/inference-extension/templates/_deployment.yaml

# sidecar imagePullPolicy: fix path from sidecar.imagePullPolicy to sidecar.image.pullPolicy
sed "${SED_INPLACE[@]}" \
  's/\.Values\.inferenceExtension\.sidecar\.imagePullPolicy/\.Values\.inferenceExtension\.sidecar\.image\.pullPolicy/g' \
 ./charts/inferencepool/charts/inference-extension/templates/_deployment.yaml

# deployment strategy type: make spec.strategy.type configurable from values
sed "${SED_INPLACE[@]}" \
  's/type: Recreate/type: {{ .Values.inferenceExtension.strategy.type | default "Recreate" }}/g' \
 ./charts/inferencepool/charts/inference-extension/templates/_deployment.yaml

# leader election: make --ha-enable-leader-election configurable from values instead of replica count
sed "${SED_INPLACE[@]}" \
  's/if gt (\.Values\.inferenceExtension\.replicas | int) 1/if (.Values.inferenceExtension.ha.enableLeaderElection | default false)/g' \
 ./charts/inferencepool/charts/inference-extension/templates/_deployment.yaml

sed "${SED_INPLACE[@]}" \
  -e '/{{- with .Values.inferenceExtension.resources }}/i\
          {{- with .Values.inferenceExtension.lifecycle }}\
          lifecycle:\
            {{ toYaml . | nindent 12 }}\
          {{- end }}' \
  ./charts/inferencepool/charts/inference-extension/templates/_deployment.yaml

# sidecar image: hub -> registry, name -> repository in values
yq eval -i '
  (.inferencepool.inferenceExtension.sidecar.image.registry = .inferencepool.inferenceExtension.sidecar.image.hub) |
  del(.inferencepool.inferenceExtension.sidecar.image.hub) |
  (.inferencepool.inferenceExtension.sidecar.image.repository = .inferencepool.inferenceExtension.sidecar.image.name) |
  del(.inferencepool.inferenceExtension.sidecar.image.name)
' values.yaml

yq eval -i '
  (.inferenceExtension.sidecar.image.registry = .inferenceExtension.sidecar.image.hub) |
  del(.inferenceExtension.sidecar.image.hub) |
  (.inferenceExtension.sidecar.image.repository = .inferenceExtension.sidecar.image.name) |
  del(.inferenceExtension.sidecar.image.name)
' ./charts/inferencepool/values.yaml

yq eval '.inferencepool.inferenceExtension.image.registry = "k8s.m.daocloud.io"' -i values.yaml
yq eval '.inferenceExtension.image.registry = "k8s.m.daocloud.io"' -i ./charts/inferencepool/values.yaml

echo "keywords:" >> Chart.yaml
echo "- networking" >> Chart.yaml

# Regenerate schema to reflect transformed values
helm schema-gen values.yaml > values.schema.json
