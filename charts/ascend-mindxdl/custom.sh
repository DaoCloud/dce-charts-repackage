#! /bin/bash
CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================
#===============================

set -x
set -o errexit
set -o nounset
set -o pipefail

os=$(uname)
echo $os

echo "custom.sh"

script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# set serviceMonitor
yq -i '
    .ascend-mindxdl.npuExporter.serviceMonitor.labels={"operator.insight.io/managed-by": "insight"}
' values.yaml

yq -i '
    .npuExporter.serviceMonitor.labels={"operator.insight.io/managed-by": "insight"}
' charts/ascend-mindxdl/values.yaml

if ! grep "keywords:" Chart.yaml &>/dev/null ; then
    echo "keywords:" >> Chart.yaml
    echo "  - npu" >> Chart.yaml
    echo "  - ascend" >> Chart.yaml
fi