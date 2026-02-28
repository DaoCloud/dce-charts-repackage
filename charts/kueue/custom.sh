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

yq e -i '.annotations |= (. + {"addon.kpanda.io/release-name": "kueue", "addon.kpanda.io/namespace": "kueue-system"})' Chart.yaml
yq e -i '.keywords = ["kueue"] + (.keywords)' Chart.yaml

yq e -i '.kueue.controllerManager.manager.image.repository="k8s.m.daocloud.io/kueue/kueue"' values.yaml
yq e -i '.kueue.kueueViz.frontend.image.repository="k8s.m.daocloud.io/kueue/kueueviz-frontend"' values.yaml
yq e -i '.kueue.kueueViz.backend.image.repository="k8s.m.daocloud.io/kueue/kueueviz-backend"' values.yaml
