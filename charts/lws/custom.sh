#!/bin/bash
set -euo pipefail

CHART_DIRECTORY=${1:?missing chart directory}
cd "$CHART_DIRECTORY"

# Split the upstream image into registry/repository/tag for offline relocation.
# Update both defaults so the parent and child charts remain consistent.
for VALUES in values.yaml charts/lws/values.yaml; do
    if [ "$VALUES" = values.yaml ]; then
        PREFIX='.lws'
    else
        PREFIX=''
    fi
    # Match limits to the upstream requests (1 CPU, 1Gi memory).
    yq -i "${PREFIX}.resources.limits = {\"cpu\": \"1\", \"memory\": \"1Gi\"}" "$VALUES"
    yq -i "${PREFIX}.image.manager.registry = \"k8s.m.daocloud.io\" |
        ${PREFIX}.image.manager.repository = \"lws/lws\"" "$VALUES"
done

if [ "$(uname)" = Darwin ]; then
    SED_INPLACE=(-i '')
else
    SED_INPLACE=(-i)
fi
sed "${SED_INPLACE[@]}" \
    's@{{ .Values.image.manager.repository }}@{{ .Values.image.manager.registry }}/{{ .Values.image.manager.repository }}@g' \
    charts/lws/templates/manager/deployment.yaml

# Upstream uses v-prefixed chart versions; normalize to SemVer for Helm.
yq -i '.version |= sub("^v", "") | .keywords = ["ai", "workload", "lws"]' Chart.yaml
yq -i '.version |= sub("^v", "")' charts/lws/Chart.yaml
# Add the Insight label only to metadata.labels, preserving the selector.
sed "${SED_INPLACE[@]}" \
    's/^    control-plane: controller-manager$/&\
    operator.insight.io\/managed-by: insight/' \
    charts/lws/templates/prometheus/monitor.yaml

# The upstream monitor selects this label, but the metrics Service lacks it.
sed "${SED_INPLACE[@]}" \
    's/^  labels:$/&\
    control-plane: controller-manager/' \
    charts/lws/templates/manager/service.yaml
