#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

CURRENT_DIR_PATH=$(
    cd $(dirname ${BASH_SOURCE[0]})
    pwd
)

echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"
echo "CURRENT_DIR_PATH: " $CURRENT_DIR_PATH

#========================= add your customize bellow ====================

set -o errexit
set -o pipefail
set -o nounset

if ! which yq &>/dev/null ; then
    echo " 'yq' no found"
    if [ "$(uname)" == "Darwin" ];then
      exit 1
    fi
    echo "try to install..."
    YQ_VERSION=v4.30.6
    YQ_BINARY="yq_$(uname | tr 'A-Z' 'a-z')_amd64"
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O /tmp/yq.tar.gz &&
     tar -xzf /tmp/yq.tar.gz -C /tmp &&
     mv /tmp/${YQ_BINARY} /usr/bin/yq
fi

cd "$CHART_DIRECTORY"

# Prefer generating parent values.yaml from the vendored subchart values.yaml to avoid drift.
# This allows configuring subcharts via the outer values.yaml structure:
#   higress:
#     higress-core: ...
#     higress-console: ...
VENDORED_HIGRESS_DIR="$CHART_DIRECTORY/charts/higress"

CORE_VALUES_PATH=""
CONSOLE_VALUES_PATH=""

if [ -f "$VENDORED_HIGRESS_DIR/charts/higress-core/values.yaml" ]; then
  CORE_VALUES_PATH="$VENDORED_HIGRESS_DIR/charts/higress-core/values.yaml"
else
  echo "custom shell: error, missing vendored higress-core values.yaml at $VENDORED_HIGRESS_DIR/charts/higress-core/values.yaml" >&2
  exit 1
fi

if [ -f "$VENDORED_HIGRESS_DIR/charts/higress-console/values.yaml" ]; then
  CONSOLE_VALUES_PATH="$VENDORED_HIGRESS_DIR/charts/higress-console/values.yaml"
else
  echo "custom shell: error, missing vendored higress-console values.yaml at $VENDORED_HIGRESS_DIR/charts/higress-console/values.yaml" >&2
  exit 1
fi

TMP_VALUES_YAML="$(mktemp)"
yq ea '[.] | {"higress": {"higress-core": .[0], "higress-console": .[1]}}' \
"${CORE_VALUES_PATH}" \
"${CONSOLE_VALUES_PATH}" > ${TMP_VALUES_YAML}
mv "$TMP_VALUES_YAML" values.yaml

# origin higress chart doesn't have the values.yaml, we need to generate it
TMP_VALUES_YAML="$(mktemp)"
yq ea '[.] | {"higress-core": .[0], "higress-console": .[1]}' \
"${CORE_VALUES_PATH}" \
"${CONSOLE_VALUES_PATH}" > ${TMP_VALUES_YAML}
mv "$TMP_VALUES_YAML" charts/higress/values.yaml

export CHART_VERSION=$(yq e '.version' Chart.yaml)
export DEFAULT_GLOBAL_HUB="higress-registry.cn-hangzhou.cr.aliyuncs.com"

yq -i ' 
  .global.hub = strenv(DEFAULT_GLOBAL_HUB) |
  .higress.higress-core.hub = "" |
  .higress.higress-core.global.hub = "" |
  .higress.higress-core.gateway.hub = "" |
  .higress.higress-core.controller.hub = "" |
  .higress.higress-core.pilot.hub = "" |
  .higress.higress-core.pluginServer.hub = "" |
  .higress.higress-core.gateway.image = "higress/gateway" |
  .higress.higress-core.controller.image = "higress/higress" |
  .higress.higress-core.pilot.image = "higress/pilot" |
  .higress.higress-core.pluginServer.image = "higress/plugin-server" |
  .higress.higress-core.global.ingressClass="" |
  .higress.higress-core.global.enableGatewayAPI=true |
  .higress.higress-core.global.local=true |
  .higress.higress-core.global.multiCluster.enabled=false |
  .higress.higress-core.gateway.tag=strenv(CHART_VERSION) |
  .higress.higress-core.controller.tag=strenv(CHART_VERSION) |
  .higress.higress-core.pilot.tag=strenv(CHART_VERSION) |
  .higress.higress-console.image.repository = "higress/console" |
  .higress.higress-console.global.o11y.grafana.image.repository = "higress/grafana" |
  .higress.higress-console.global.o11y.prometheus.image.repository = "higress/prometheus" |
  .higress.higress-console.global.o11y.loki.image.repository = "higress/loki" |
  .higress.higress-core.global.o11y.promtail.image.repository = "higress/promtail" |
  .higress.higress-console.certmanager.image.repository = "higress" |
  .higress.higress-console.image.tag=strenv(CHART_VERSION) | 
  .higress.higress-console.resources.limits.cpu="600m" |
  .higress.higress-console.resources.limits.memory="1000Mi"
' values.yaml

# Normalize repositories that might include a registry prefix.
# Some templates use: "{{ .Values.global.hub }}/{{ .Values.image.repository }}:{{ tag }}".
# In that case, repository must NOT already contain the hub prefix.
yq -i '
  .higress.higress-console.image.repository |= sub("^[^/]*\\.[^/]*/"; "") |
  .higress.higress-console.global.o11y.grafana.image.repository |= sub("^[^/]*\\.[^/]*/"; "") |
  .higress.higress-console.global.o11y.prometheus.image.repository |= sub("^[^/]*\\.[^/]*/"; "") |
  .higress.higress-console.global.o11y.loki.image.repository |= sub("^[^/]*\\.[^/]*/"; "") |
  .higress.higress-core.global.o11y.promtail.image.repository |= sub("^[^/]*\\.[^/]*/"; "") |
  .higress.higress-console.certmanager.image.repository |= sub("^[^/]*\\.[^/]*/"; "")
' values.yaml

# fix https://github.com/alibaba/higress/issues/3532
yq -i '.higress.higress-core.tracing.skywalking.service=""' values.yaml

# fix securityContext nil pointer evaluating interface when o11y enabled
yq -i '
  .higress.higress-console.global.o11y.prometheus.securityContext.runAsUser=0 |
  .higress.higress-console.global.o11y.loki.securityContext.runAsUser=0 |
  .higress.higress-console.global.o11y.grafana.securityContext.runAsUser=0
' values.yaml

# make pluginServer default to 1.0.0, see charts/higress/higress/charts/higress/charts/higress-core/templates/plugin-server-deployment.yaml:26
# or latest tag can't be pull
yq -i '.higress.higress-core.pluginServer.tag="1.0.0"' values.yaml

# patch redis-stack-server
yq -i '.higress.higress-core.redis.redis.image="higress/redis-stack-server"' values.yaml

yq -i '.version=strenv(CHART_VERSION)' Chart.yaml
yq -i '.keywords = ["networking"] + (.keywords)' Chart.yaml

# Patch higress-console templates at build time to use global.hub + repository + tag
CONSOLE_DEPLOY_PATH="charts/higress/charts/higress-console/templates/deployment.yaml"
GRAFANA_PATH="charts/higress/charts/higress-console/templates/grafana.yaml"
PROMETHEUS_PATH="charts/higress/charts/higress-console/templates/prometheus.yaml"
LOKI_PATH="charts/higress/charts/higress-console/templates/loki.yaml"
CERTMANAGER_PATH="charts/higress/charts/higress-console/templates/certmanager.yaml"

# Patch higress-core promtail sidecar image to use global.hub + repository + tag
CORE_POD_TPL_PATH="charts/higress/charts/higress-core/templates/_pod.tpl"

PATCH_SED="sed"
PATCH_SED_INPLACE=(-i)
if command -v gsed >/dev/null 2>&1; then
  PATCH_SED="gsed"
fi
if [ "$(uname)" = "Darwin" ] && [ "$PATCH_SED" = "sed" ]; then
  PATCH_SED_INPLACE=(-i '')
fi

[ -f "$CONSOLE_DEPLOY_PATH" ] && $PATCH_SED "${PATCH_SED_INPLACE[@]}" 's?image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"?image: "{{ .Values.global.hub }}/{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"?' "$CONSOLE_DEPLOY_PATH"
[ -f "$GRAFANA_PATH" ] && $PATCH_SED "${PATCH_SED_INPLACE[@]}" 's?image: {{ $config.image.repository }}:{{ $config.image.tag }}?image: {{ $.Values.global.hub }}/{{ $config.image.repository }}:{{ $config.image.tag }}?' "$GRAFANA_PATH"
[ -f "$PROMETHEUS_PATH" ] && $PATCH_SED "${PATCH_SED_INPLACE[@]}" 's?- image: {{ $config.image.repository }}:{{ $config.image.tag }}?- image: {{ $.Values.global.hub }}/{{ $config.image.repository }}:{{ $config.image.tag }}?' "$PROMETHEUS_PATH"
[ -f "$LOKI_PATH" ] && $PATCH_SED "${PATCH_SED_INPLACE[@]}" 's?image: {{ $config.image.repository }}:{{ $config.image.tag }}?image: {{ $.Values.global.hub }}/{{ $config.image.repository }}:{{ $config.image.tag }}?' "$LOKI_PATH"
[ -f "$CORE_POD_TPL_PATH" ] && $PATCH_SED "${PATCH_SED_INPLACE[@]}" 's?image: {{ $config.image.repository | default (printf "%s/promtail" .Values.global.hub) }}:{{ $config.image.tag }}?image: {{ .Values.global.hub }}/{{ $config.image.repository | default "higress/promtail" }}:{{ $config.image.tag }}?g' "$CORE_POD_TPL_PATH"
[ -f "$CORE_POD_TPL_PATH" ] && $PATCH_SED "${PATCH_SED_INPLACE[@]}" 's?image: {{ $config.image.repository }}:{{ $config.image.tag }}?image: {{ .Values.global.hub }}/{{ $config.image.repository }}:{{ $config.image.tag }}?g' "$CORE_POD_TPL_PATH"

[ -f "$CERTMANAGER_PATH" ] && $PATCH_SED "${PATCH_SED_INPLACE[@]}" 's?image: "{{ \$config.image.repository }}/cert-manager-cainjector:{{ \$config.image.tag }}"?image: "{{ \$.Values.global.hub }}/{{ \$config.image.repository }}/cert-manager-cainjector:{{ \$config.image.tag }}"?g' "$CERTMANAGER_PATH"
[ -f "$CERTMANAGER_PATH" ] && $PATCH_SED "${PATCH_SED_INPLACE[@]}" 's?image: "{{ \$config.image.repository }}/cert-manager-controller:{{ \$config.image.tag }}"?image: "{{ \$.Values.global.hub }}/{{ \$config.image.repository }}/cert-manager-controller:{{ \$config.image.tag }}"?g' "$CERTMANAGER_PATH"
[ -f "$CERTMANAGER_PATH" ] && $PATCH_SED "${PATCH_SED_INPLACE[@]}" 's?image: "{{ \$config.image.repository }}/cert-manager-webhook:{{ \$config.image.tag }}"?image: "{{ \$.Values.global.hub }}/{{ \$config.image.repository }}/cert-manager-webhook:{{ \$config.image.tag }}"?g' "$CERTMANAGER_PATH"
[ -f "$CERTMANAGER_PATH" ] && $PATCH_SED "${PATCH_SED_INPLACE[@]}" 's?image: "{{ \$config.image.repository }}/cert-manager-ctl:{{ \$config.image.tag }}"?image: "{{ \$.Values.global.hub }}/{{ \$config.image.repository }}/cert-manager-ctl:{{ \$config.image.tag }}"?g' "$CERTMANAGER_PATH"