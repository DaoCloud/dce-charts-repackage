#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY: $(ls)"

#========================= add your customize bellow ====================
#===============================

set -o errexit
set -o pipefail
set -o nounset

# keyWords to chart.yaml
cat <<EOF >> Chart.yaml
keywords:
  - networking
EOF

if [ "$(uname)" == "Darwin" ];then
  sed -i '' '/---/d' values.yaml
else
  sed -i '/---/d' values.yaml
fi
exit 0


