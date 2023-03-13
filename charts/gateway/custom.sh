#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================

set -o errexit
set -o pipefail
set -o nounset

if ! helm schema-gen -h &>/dev/null ; then
      echo "install helm-schema-gen "
      helm plugin install https://github.com/karuppiah7890/helm-schema-gen.git
fi

## bug fix, overwrite values.schema.json
rm -rf values.schema.json
helm schema-gen ./values.yaml > values.schema.json
