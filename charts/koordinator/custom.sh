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
os=$(uname)
echo $os

yq e -i '.annotations |= (. + {"addon.kpanda.io/release-name": "koordinator", "addon.kpanda.io/namespace": "koordinator-system"})' Chart.yaml

yq e -i '.koordinator.imageRepositoryHost="ghcr.m.daocloud.io"' values.yaml
