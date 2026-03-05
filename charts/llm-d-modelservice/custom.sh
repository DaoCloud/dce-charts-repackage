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
  (.llm-d-modelservice.decode.containers[] | select(.image) | .image) |= (
    split(":") as $parts |
    {
      "registry": ($parts[0] | split("/") | .[0]),
      "repository": ($parts[0] | split("/") | .[1:] | join("/")),
      "tag": ($parts[1] // "latest")
    }
  ) |
  (.llm-d-modelservice.prefill.containers[] | select(.image) | .image) |= (
    split(":") as $parts |
    {
      "registry": ($parts[0] | split("/") | .[0]),
      "repository": ($parts[0] | split("/") | .[1:] | join("/")),
      "tag": ($parts[1] // "latest")
    }
  ) |
  (.llm-d-modelservice.requester.image) |= (
    split(":") as $parts |
    {
      "registry": ($parts[0] | split("/") | .[0]),
      "repository": ($parts[0] | split("/") | .[1:] | join("/")),
      "tag": ($parts[1] // "latest")
    }
  ) |
  (.llm-d-modelservice.routing.proxy.image) |= (
    split(":") as $parts |
    {
      "registry": ($parts[0] | split("/") | .[0]),
      "repository": ($parts[0] | split("/") | .[1:] | join("/")),
      "tag": ($parts[1] // "latest")
    }
  )
' values.yaml

yq eval -i '
  (.decode.containers[] | select(.image) | .image) |= (
    split(":") as $parts |
    {
      "registry": ($parts[0] | split("/") | .[0]),
      "repository": ($parts[0] | split("/") | .[1:] | join("/")),
      "tag": ($parts[1] // "latest")
    }
  ) |
  (.prefill.containers[] | select(.image) | .image) |= (
    split(":") as $parts |
    {
      "registry": ($parts[0] | split("/") | .[0]),
      "repository": ($parts[0] | split("/") | .[1:] | join("/")),
      "tag": ($parts[1] // "latest")
    }
  ) |
  (.requester.image) |= (
    split(":") as $parts |
    {
      "registry": ($parts[0] | split("/") | .[0]),
      "repository": ($parts[0] | split("/") | .[1:] | join("/")),
      "tag": ($parts[1] // "latest")
    }
  ) |
  (.routing.proxy.image) |= (
    split(":") as $parts |
    {
      "registry": ($parts[0] | split("/") | .[0]),
      "repository": ($parts[0] | split("/") | .[1:] | join("/")),
      "tag": ($parts[1] // "latest")
    }
  )
' charts/llm-d-modelservice/values.yaml

yq eval -i '
  (.llm-d-modelservice.decode.containers[].image.registry | select(. == "ghcr.io")) |= "ghcr.m.daocloud.io" |
  (.llm-d-modelservice.prefill.containers[].image.registry | select(. == "ghcr.io")) |= "ghcr.m.daocloud.io" |
  (.llm-d-modelservice.requester.image.registry | select(. == "ghcr.io")) |= "ghcr.m.daocloud.io" |
  (.llm-d-modelservice.routing.proxy.image.registry | select(. == "ghcr.io")) |= "ghcr.m.daocloud.io"
' values.yaml

yq eval -i '
  (.decode.containers[].image.registry | select(. == "ghcr.io")) |= "ghcr.m.daocloud.io" |
  (.prefill.containers[].image.registry | select(. == "ghcr.io")) |= "ghcr.m.daocloud.io" |
  (.requester.image.registry | select(. == "ghcr.io")) |= "ghcr.m.daocloud.io" |
  (.routing.proxy.image.registry | select(. == "ghcr.io")) |= "ghcr.m.daocloud.io"
' charts/llm-d-modelservice/values.yaml

if [ "$(uname)" = "Darwin" ]; then
  SED_INPLACE=(-i '')
else
  SED_INPLACE=(-i)
fi

sed "${SED_INPLACE[@]}" \
  -e '/{{- if and .container .container.image (contains "llm-d-inference-sim" .container.image) -}}/{
    N
    s/{{- if and .container .container.image (contains "llm-d-inference-sim" .container.image) -}}/{{- $fullImage := include "llm-d-modelservice.imageAddress" .container.image -}}\
{{- if and .container .container.image (contains "llm-d-inference-sim" $fullImage) -}}/
  }' \
  charts/llm-d-modelservice/templates/_helpers.tpl

sed "${SED_INPLACE[@]}" \
  -e 's/image: {{ required "\(.*\)" \.container\.image }}/image: {{ required "\1" (include "llm-d-modelservice.imageAddress" .container.image) }}/g' \
  -e 's/image: {{ required "\(.*\)" \.proxy\.image }}/image: {{ required "\1" (include "llm-d-modelservice.imageAddress" .proxy.image) }}/g' \
  charts/llm-d-modelservice/templates/_helpers.tpl


rm -rf charts/llm-d-modelservice/values.schema.json charts/llm-d-modelservice/values.schema.tmpl.json

CPU_LIMIT=${CPU_LIMIT:-"1"}
MEMORY_LIMIT=${MEMORY_LIMIT:-"1Gi"}
yq -i "
  (.llm-d-modelservice.decode.containers[] | select(.name == \"vllm\") | .resources.limits) |= {
    \"cpu\": \"${CPU_LIMIT}\",
    \"memory\": \"${MEMORY_LIMIT}\"
  } |
  (.llm-d-modelservice.prefill.containers[] | select(.name == \"vllm\") | .resources.limits) |= {
    \"cpu\": \"${CPU_LIMIT}\",
    \"memory\": \"${MEMORY_LIMIT}\"
  }
" values.yaml

echo "keywords:" >> Chart.yaml
echo "- vllm" >> Chart.yaml
