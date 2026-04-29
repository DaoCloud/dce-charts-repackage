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
  .inferencepool.inferenceExtension |= (
    to_entries
    | (.[] | select(.key == "tolerations") | key + 1) as $idx
    | (.[:$idx] + [{"key":"resources","value":{
        "requests": {"cpu":"1000m","memory":"1Gi"},
        "limits":   {"cpu":"4000m","memory":"8Gi"}
      }}] + .[$idx:])
    | from_entries
  )
' values.yaml

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

awk '
/env:/ {
    count++
    if(count == 2) {
        print "        {{- with .Values.inferenceExtension.resources }}"
        print "        resources:"
        print "          {{- toYaml . | nindent 10 }}"
        print "        {{- end }}"
    }
}
{ print }
' charts/inferencepool/templates/epp-deployment.yaml > temp_file && mv temp_file charts/inferencepool/templates/epp-deployment.yaml

if [ "$(uname)" = "Darwin" ]; then
  SED_INPLACE=(-i '')
else
  SED_INPLACE=(-i)
fi

sed "${SED_INPLACE[@]}" \
  's/\.Values\.inferenceExtension\.image\.hub/\.Values\.inferenceExtension\.image\.registry/g' \
  charts/inferencepool/templates/epp-deployment.yaml

sed "${SED_INPLACE[@]}" \
  's/\.Values\.inferenceExtension\.image\.name/\.Values\.inferenceExtension\.image\.repository/g' \
 charts/inferencepool/templates/epp-deployment.yaml

# sidecar image: replace single string with three-segment format in template
sed "${SED_INPLACE[@]}" \
  's/\.Values\.inferenceExtension\.sidecar\.image }}/\.Values\.inferenceExtension\.sidecar\.image\.registry}}\/{{ \.Values\.inferenceExtension\.sidecar\.image\.repository}}:{{ \.Values\.inferenceExtension\.sidecar\.image\.tag}}/g' \
 charts/inferencepool/templates/epp-deployment.yaml

# sidecar imagePullPolicy: fix path from sidecar.imagePullPolicy to sidecar.image.pullPolicy
sed "${SED_INPLACE[@]}" \
  's/\.Values\.inferenceExtension\.sidecar\.imagePullPolicy/\.Values\.inferenceExtension\.sidecar\.image\.pullPolicy/g' \
 charts/inferencepool/templates/epp-deployment.yaml

yq -i '(.inferencepool.experimentalHttpRoute.inferenceGatewayName = "") | (.inferencepool.experimentalHttpRoute.inferenceGatewayNameOverride = "inference-gateway")' values.yaml

sed "${SED_INPLACE[@]}" \
  's|inference\.networking\.k8s\.io|{{ default "inference.networking.k8s.io" (split "/" .Values.inferencePool.apiVersion)._0 }}|g' \
 charts/inferencepool/templates/httproute.yaml

sed "${SED_INPLACE[@]}" \
  's/{{ \.Values\.experimentalHttpRoute\.inferenceGatewayName }}/{{ include "inferencepool.gateway.fullname" . }}/g' \
  charts/inferencepool/templates/httproute.yaml

yq eval -i '
  (.inferenceExtension.image.registry = .inferenceExtension.image.hub) |
  del(.inferenceExtension.image.hub) |
  (.inferenceExtension.image.repository = .inferenceExtension.image.name) |
  del(.inferenceExtension.image.name)
' ./charts/inferencepool/values.yaml

yq eval -i '
  (.inferencepool.inferenceExtension.image.registry = .inferencepool.inferenceExtension.image.hub) |
  del(.inferencepool.inferenceExtension.image.hub) |
  (.inferencepool.inferenceExtension.image.repository = .inferencepool.inferenceExtension.image.name) |
  del(.inferencepool.inferenceExtension.image.name)
' values.yaml

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

REPOSITORY=$(yq -r '.inferencepool.inferenceExtension.image.registry | split("/") | .[1]' values.yaml)
IMAGE_NAME=$(yq -r '.inferencepool.inferenceExtension.image.repository | sub("^/", "")' values.yaml)

yq eval '.inferencepool.inferenceExtension.image.registry = "k8s.m.daocloud.io"' -i values.yaml
yq eval ".inferencepool.inferenceExtension.image.repository = \"${REPOSITORY}/${IMAGE_NAME}\"" -i values.yaml

yq eval '.inferenceExtension.image.registry = "k8s.m.daocloud.io"' -i ./charts/inferencepool/values.yaml
yq eval ".inferenceExtension.image.repository = \"${REPOSITORY}/${IMAGE_NAME}\"" -i ./charts/inferencepool/values.yaml

echo "keywords:" >> Chart.yaml
echo "- networking" >> Chart.yaml

# Regenerate schema to reflect transformed values
helm schema-gen values.yaml > values.schema.json
