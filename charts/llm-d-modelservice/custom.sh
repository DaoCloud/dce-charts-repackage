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
set -x

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

echo "keywords:" >> Chart.yaml
echo "- vllm" >> Chart.yaml
