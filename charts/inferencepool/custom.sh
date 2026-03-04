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

REPOSITORY=$(yq eval '.inferencepool.inferenceExtension.image.registry | split("/")[1]' values.yaml)
IMAGE_NAME=$(yq eval '.inferencepool.inferenceExtension.image.repository | sub("^/", "")' values.yaml)

yq eval '.inferencepool.inferenceExtension.image.registry = "k8s.m.daocloud.io"' -i values.yaml
yq eval ".inferencepool.inferenceExtension.image.repository = \"${REPOSITORY}/${IMAGE_NAME}\"" -i values.yaml

echo "keywords:" >> Chart.yaml
echo "- networking" >> Chart.yaml
