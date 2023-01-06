#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY: $(ls)"

#========================= add your customize bellow ====================

set -o errexit
set -o pipefail
set -o nounset

export CHART_VERSION=$(helm show chart kubean-io/kubean --devel | grep '^version' |grep -E 'v.*' | awk -F ':' '{print $2}' | tr -d ' ') ## v0.4.1
echo "CHART_VERSION:$CHART_VERSION"

yq -i '
   .annotations["addon.kpanda.io/namespace"]="kubean-system" |
   .annotations["addon.kpanda.io/release-name"]="kubean"
' Chart.yaml
