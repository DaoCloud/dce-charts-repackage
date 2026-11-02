#!/bin/bash
set -euo pipefail

CHART_DIRECTORY=${1:?missing chart directory}
cd "$CHART_DIRECTORY"

# Mirror the NGC image and pin the tag explicitly so relok8s can relocate it.
for VALUES in values.yaml charts/topograph/values.yaml; do
    if [ "$VALUES" = values.yaml ]; then
        PREFIX='.topograph'
    else
        PREFIX=''
    fi
    yq -i "${PREFIX}.image.repository = \"nvcr.m.daocloud.io/nvidia/topograph/topograph\" |
        ${PREFIX}.image.tag = \"v${VERSION}\"" "$VALUES"
done

# Drop the parent schema: provider-specific values vary too much for a UI form.
rm -f values.schema.json

# Add the Insight label only to metadata.labels, preserving the selector.
if [ "$(uname)" = Darwin ]; then
    SED_INPLACE=(-i '')
else
    SED_INPLACE=(-i)
fi
sed "${SED_INPLACE[@]}" \
    's/^  labels:$/&\
    operator.insight.io\/managed-by: insight/' \
    charts/topograph/templates/servicemonitor.yaml
