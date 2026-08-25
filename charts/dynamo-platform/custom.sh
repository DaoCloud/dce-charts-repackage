#!/bin/bash

set +x
set -o errexit
set -o pipefail
set -o nounset

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd "$CHART_DIRECTORY"
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================
#===============================

DYNAMO_OPERATOR_REGISTRY="nvcr.m.daocloud.io"
DYNAMO_OPERATOR_REPOSITORY="nvidia/ai-dynamo/kubernetes-operator"
DOCKER_REGISTRY="docker.m.daocloud.io"
GHCR_REGISTRY="ghcr.m.daocloud.io"
GROVE_OPERATOR_REPOSITORY="ai-dynamo/grove/grove-operator"
GROVE_CRD_INSTALLER_REPOSITORY="ai-dynamo/grove/grove-install-crds"
GROVE_INIT_CONTAINER_REPOSITORY="ai-dynamo/grove/grove-initc"
INSIGHT_LABEL="operator.insight.io/managed-by"
DYNAMO_PLATFORM_VERSION=$(yq -r '.appVersion // .version' Chart.yaml)
GROVE_VERSION=$(yq -r '.appVersion // .version' charts/dynamo-platform/charts/grove-charts/Chart.yaml)
NATS_SERVER_TAG=$(yq -r '."dynamo-platform".nats.container.image.tag' values.yaml)
NATS_RELOADER_TAG=$(yq -r '."dynamo-platform".nats.reloader.image.tag' values.yaml)
NATS_EXPORTER_TAG=$(yq -r '.promExporter.image.tag' charts/dynamo-platform/charts/nats/values.yaml)
NATS_BOX_TAG=$(yq -r '."dynamo-platform".nats.natsBox.container.image.tag' values.yaml)

patch_platform_values() {
  local file=$1
  local prefix=$2

  yq -i "
    ${prefix}.global.nats.install = false |
    ${prefix}.\"dynamo-operator\".controllerManager.manager.image.registry = \"${DYNAMO_OPERATOR_REGISTRY}\" |
    ${prefix}.\"dynamo-operator\".controllerManager.manager.image.repository = \"${DYNAMO_OPERATOR_REPOSITORY}\" |
    ${prefix}.\"dynamo-operator\".controllerManager.manager.image.tag = \"${DYNAMO_PLATFORM_VERSION}\" |
    ${prefix}.nats.config.cluster.enabled = true |
    ${prefix}.nats.config.cluster.replicas = 3 |
    ${prefix}.nats.config.jetstream.enabled = false |
    ${prefix}.nats.container.image.registry = \"${DOCKER_REGISTRY}\" |
    ${prefix}.nats.container.image.repository = \"library/nats\" |
    ${prefix}.nats.container.image.tag = \"${NATS_SERVER_TAG}\" |
    ${prefix}.nats.reloader.image.registry = \"${DOCKER_REGISTRY}\" |
    ${prefix}.nats.reloader.image.repository = \"natsio/nats-server-config-reloader\" |
    ${prefix}.nats.reloader.image.tag = \"${NATS_RELOADER_TAG}\" |
    ${prefix}.nats.promExporter.image.registry = \"${DOCKER_REGISTRY}\" |
    ${prefix}.nats.promExporter.image.repository = \"natsio/prometheus-nats-exporter\" |
    ${prefix}.nats.promExporter.image.tag = \"${NATS_EXPORTER_TAG}\" |
    ${prefix}.nats.natsBox.container.image.registry = \"${DOCKER_REGISTRY}\" |
    ${prefix}.nats.natsBox.container.image.repository = \"natsio/nats-box\" |
    ${prefix}.nats.natsBox.container.image.tag = \"${NATS_BOX_TAG}\" |
    ${prefix}.grove.image.registry = \"${GHCR_REGISTRY}\" |
    ${prefix}.grove.image.repository = \"${GROVE_OPERATOR_REPOSITORY}\" |
    ${prefix}.grove.image.tag = \"${GROVE_VERSION}\" |
    ${prefix}.grove.crdInstaller.image.registry = \"${GHCR_REGISTRY}\" |
    ${prefix}.grove.crdInstaller.image.repository = \"${GROVE_CRD_INSTALLER_REPOSITORY}\" |
    ${prefix}.grove.crdInstaller.image.tag = \"${GROVE_VERSION}\" |
    ${prefix}.grove.initContainer.image.registry = \"${GHCR_REGISTRY}\" |
    ${prefix}.grove.initContainer.image.repository = \"${GROVE_INIT_CONTAINER_REPOSITORY}\" |
    ${prefix}.grove.initContainer.image.tag = \"${GROVE_VERSION}\" |
    ${prefix}.grove.deployment.env = []
  " "$file"
}

patch_platform_values values.yaml '."dynamo-platform"'
patch_platform_values charts/dynamo-platform/values.yaml ''

yq -i "
  .controllerManager.manager.image.registry = \"${DYNAMO_OPERATOR_REGISTRY}\" |
  .controllerManager.manager.image.repository = \"${DYNAMO_OPERATOR_REPOSITORY}\" |
  .controllerManager.manager.image.tag = \"${DYNAMO_PLATFORM_VERSION}\"
" charts/dynamo-platform/charts/dynamo-operator/values.yaml

yq -i "
  .global.image.registry = \"${DOCKER_REGISTRY}\" |
  .config.cluster.enabled = true |
  .config.cluster.replicas = 3 |
  .config.jetstream.enabled = false |
  .container.image.registry = \"${DOCKER_REGISTRY}\" |
  .container.image.repository = \"library/nats\" |
  .container.image.tag = \"${NATS_SERVER_TAG}\" |
  .reloader.image.registry = \"${DOCKER_REGISTRY}\" |
  .reloader.image.repository = \"natsio/nats-server-config-reloader\" |
  .reloader.image.tag = \"${NATS_RELOADER_TAG}\" |
  .promExporter.image.registry = \"${DOCKER_REGISTRY}\" |
  .promExporter.image.repository = \"natsio/prometheus-nats-exporter\" |
  .promExporter.image.tag = \"${NATS_EXPORTER_TAG}\" |
  .natsBox.container.image.registry = \"${DOCKER_REGISTRY}\" |
  .natsBox.container.image.repository = \"natsio/nats-box\" |
  .natsBox.container.image.tag = \"${NATS_BOX_TAG}\"
" charts/dynamo-platform/charts/nats/values.yaml

# The bundled etcd chart is disabled by default. Its upstream image annotation
# references retired Bitnami tags, while helm-dt scans annotations even for
# disabled dependencies.
ETCD_CHART="charts/dynamo-platform/charts/etcd/Chart.yaml"
awk '
  /^  images: \|$/ { skipping_images = 1; next }
  skipping_images && /^  [[:alnum:]_-]+:/ { skipping_images = 0 }
  !skipping_images { print }
' "${ETCD_CHART}" > "${ETCD_CHART}.tmp"
mv "${ETCD_CHART}.tmp" "${ETCD_CHART}"

yq -i "
  .image.registry = \"${GHCR_REGISTRY}\" |
  .image.repository = \"${GROVE_OPERATOR_REPOSITORY}\" |
  .image.tag = \"${GROVE_VERSION}\" |
  .crdInstaller.image.registry = \"${GHCR_REGISTRY}\" |
  .crdInstaller.image.repository = \"${GROVE_CRD_INSTALLER_REPOSITORY}\" |
  .crdInstaller.image.tag = \"${GROVE_VERSION}\" |
  .initContainer.image.registry = \"${GHCR_REGISTRY}\" |
  .initContainer.image.repository = \"${GROVE_INIT_CONTAINER_REPOSITORY}\" |
  .initContainer.image.tag = \"${GROVE_VERSION}\" |
  .deployment.env = []
" charts/dynamo-platform/charts/grove-charts/values.yaml

if [ "$(uname)" = "Darwin" ]; then
  sedi() { sed -i '' "$@"; }
else
  sedi() { sed -i "$@"; }
fi

OPERATOR_DEPLOYMENT_TEMPLATE="charts/dynamo-platform/charts/dynamo-operator/templates/deployment.yaml"
sedi 's#image: {{ .Values.controllerManager.manager.image.repository }}:#image: {{ .Values.controllerManager.manager.image.registry }}/{{ .Values.controllerManager.manager.image.repository }}:#' "${OPERATOR_DEPLOYMENT_TEMPLATE}"

GROVE_DEPLOYMENT_TEMPLATE="charts/dynamo-platform/charts/grove-charts/templates/deployment.yaml"
sedi 's#^          image: {{ include "image" .Values.crdInstaller.image }}$#          image: {{ .Values.crdInstaller.image.registry }}/{{ include "image" .Values.crdInstaller.image }}#' "${GROVE_DEPLOYMENT_TEMPLATE}"
sedi 's#^          image: {{ include "image" .Values.image }}$#          image: {{ .Values.image.registry }}/{{ include "image" .Values.image }}#' "${GROVE_DEPLOYMENT_TEMPLATE}"

if ! grep -q '.Values.initContainer.image.registry' "${GROVE_DEPLOYMENT_TEMPLATE}"; then
  awk '
    /{{- toYaml \.Values\.deployment\.env \| nindent 12 }}/ {
      print "            - name: GROVE_INIT_CONTAINER_IMAGE"
      print "              value: {{ .Values.initContainer.image.registry }}/{{ include \"image\" .Values.initContainer.image }}"
      print "{{- with .Values.deployment.env }}"
      print "{{- toYaml . | nindent 12 }}"
      print "{{- end }}"
      next
    }
    { print }
  ' "${GROVE_DEPLOYMENT_TEMPLATE}" > "${GROVE_DEPLOYMENT_TEMPLATE}.tmp"
  mv "${GROVE_DEPLOYMENT_TEMPLATE}.tmp" "${GROVE_DEPLOYMENT_TEMPLATE}"
fi

# This upstream template does not expose additional ServiceMonitor labels.
SERVICE_MONITOR_TEMPLATE="charts/dynamo-platform/charts/dynamo-operator/templates/operator-servicemonitor.yaml"
if ! grep -q "${INSIGHT_LABEL}" "${SERVICE_MONITOR_TEMPLATE}"; then
  awk -v insight_label="${INSIGHT_LABEL}" '
    { print }
    /    release: prometheus/ {
      print "    " insight_label ": insight"
    }
  ' "${SERVICE_MONITOR_TEMPLATE}" > "${SERVICE_MONITOR_TEMPLATE}.tmp"
  mv "${SERVICE_MONITOR_TEMPLATE}.tmp" "${SERVICE_MONITOR_TEMPLATE}"
fi

# Label every PodMonitor rendered by the Dynamo operator so Insight manages it.
PROMETHEUS_TEMPLATE="charts/dynamo-platform/charts/dynamo-operator/templates/prometheus.yaml"
if ! grep -q "${INSIGHT_LABEL}" "${PROMETHEUS_TEMPLATE}"; then
  awk -v insight_label="${INSIGHT_LABEL}" '
    /^metadata:$/ {
      print
      print "  labels:"
      print "    " insight_label ": insight"
      next
    }
    { print }
  ' "${PROMETHEUS_TEMPLATE}" > "${PROMETHEUS_TEMPLATE}.tmp"
  mv "${PROMETHEUS_TEMPLATE}.tmp" "${PROMETHEUS_TEMPLATE}"
fi

export CHART_IMAGES
CHART_IMAGES=$(cat <<EOF
- image: ${DYNAMO_OPERATOR_REGISTRY}/${DYNAMO_OPERATOR_REPOSITORY}:${DYNAMO_PLATFORM_VERSION}
  name: dynamo-operator
- image: ${DOCKER_REGISTRY}/library/nats:${NATS_SERVER_TAG}
  name: nats
- image: ${DOCKER_REGISTRY}/natsio/nats-server-config-reloader:${NATS_RELOADER_TAG}
  name: nats-server-config-reloader
- image: ${DOCKER_REGISTRY}/natsio/prometheus-nats-exporter:${NATS_EXPORTER_TAG}
  name: prometheus-nats-exporter
- image: ${DOCKER_REGISTRY}/natsio/nats-box:${NATS_BOX_TAG}
  name: nats-box
- image: ${GHCR_REGISTRY}/${GROVE_OPERATOR_REPOSITORY}:${GROVE_VERSION}
  name: grove-operator
- image: ${GHCR_REGISTRY}/${GROVE_CRD_INSTALLER_REPOSITORY}:${GROVE_VERSION}
  name: grove-install-crds
- image: ${GHCR_REGISTRY}/${GROVE_INIT_CONTAINER_REPOSITORY}:${GROVE_VERSION}
  name: grove-initc
EOF
)

yq -i '
  .keywords = (.keywords // []) + ["ai", "inference"] | .keywords |= unique |
  .annotations.images = strenv(CHART_IMAGES)
' Chart.yaml
