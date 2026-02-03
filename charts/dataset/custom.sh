#!/bin/bash
set -x

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================

os=$(uname)
echo $os

yq e -i '.annotations |= (. + {"addon.kpanda.io/release-name": "dataset", "addon.kpanda.io/namespace": "dataset-system"})' Chart.yaml
yq e -i '.dataset.global.imageRegistry="ghcr.m.daocloud.io"' values.yaml
yq e -i '.dataset.dataloader.image.registry="ghcr.m.daocloud.io"' values.yaml
yq e -i '.dataset.controller.image.registry="ghcr.m.daocloud.io"' values.yaml
yq e -i '.dataset.resources={"limits":{"cpu":"1000m","memory":"2048M"},"requests":{"cpu":"100m","memory":"125M"}}' values.yaml
yq e -i '.keywords = ["dataset"] + (.keywords)' Chart.yaml