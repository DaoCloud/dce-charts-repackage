#!/usr/bin/env bash

CHART_DIRECTORY=${1:-}
[ -d "$CHART_DIRECTORY" ] || {
  echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY"
  exit 1
}

cd "$CHART_DIRECTORY"

set -o errexit
set -o nounset
set -o pipefail

command -v yq >/dev/null || {
  echo "custom shell: error, yq is required"
  exit 1
}

export VERSION

# Rewrite both registry-qualified repositories and separate registry/repository
# image settings. Upstream leaves several component tags empty so they fall back
# to the chart appVersion; make those tags explicit for relok8s. NVSentinel's
# MongoDB store is switched to the vendored Percona Server for MongoDB Operator
# below because the legacy Bitnami MongoDB image is amd64-only.
# Keep slurm-drain-monitor's tag unchanged for now. The upstream v1.22.0 release
# did not publish that image consistently; only its registry is mirrored below.
mirror_values() {
  local values_file=$1

  perl -pi -e '
    s/(?<![A-Za-z0-9_.-])ghcr\.io\//ghcr.m.daocloud.io\//g;
    s/(?<![A-Za-z0-9_.-])docker\.io\//docker.m.daocloud.io\//g;
    s/(?<![A-Za-z0-9_.-])quay\.io\//quay.m.daocloud.io\//g;
    s/(?<![A-Za-z0-9_.-])nvcr\.io\//nvcr.m.daocloud.io\//g;
    s/(?<![A-Za-z0-9_.-])(?<!m\.daocloud\.io\/)public\.ecr\.aws\//m.daocloud.io\/public.ecr.aws\//g;
    s/(?<![A-Za-z0-9_.-])(?<!\/)percona\//docker.m.daocloud.io\/percona\//g;
    s/((?:repository|image):\s*["'"'"']?(?:docker\.m\.daocloud\.io\/)?)bitnami\//$1bitnamilegacy\//g;
    s/(?:registry|imageRegistry):\s*["'"'"']?\Kdocker\.io(?=["'"'"']?\s*$)/docker.m.daocloud.io/g;
  ' "$values_file"

  VERSION="$VERSION" yq -i '(
    .. | select(tag == "!!map" and has("repository") and (.repository | tag == "!!str") and
      ((.repository | test("^ghcr\\.m\\.daocloud\\.io/")) or
       (.repository | test("^docker\\.m\\.daocloud\\.io/")) or
       (.repository | test("^quay\\.m\\.daocloud\\.io/")) or
       (.repository | test("^nvcr\\.m\\.daocloud\\.io/")) or
       (.repository | test("^m\\.daocloud\\.io/public\\.ecr\\.aws/"))) and
      ((.repository | test("/slurm-drain-monitor$") | not)) and
      has("tag") and .tag == "") | .tag
  ) = strenv(VERSION)' "$values_file"

  VERSION="$VERSION" yq -i '(
    .. | select(tag == "!!map" and has("repository") and (.repository | tag == "!!str") and
      ((.repository | test("^ghcr\\.m\\.daocloud\\.io/")) or
       (.repository | test("^docker\\.m\\.daocloud\\.io/")) or
       (.repository | test("^quay\\.m\\.daocloud\\.io/")) or
       (.repository | test("^nvcr\\.m\\.daocloud\\.io/")) or
       (.repository | test("^m\\.daocloud\\.io/public\\.ecr\\.aws/"))) and
      ((.repository | test("/slurm-drain-monitor$") | not)) and
      .tag == null)
  ) |= (.tag = strenv(VERSION))' "$values_file"
}

# Rewrite every values profile shipped by the chart, including values-full.yaml
# and the Tilt profiles used to exercise optional modules.
while IFS= read -r -d '' values_file; do
  mirror_values "$values_file"
done < <(find . -type f -name 'values*.yaml' -print0)

# Keep the Percona selection in the mongodb-store subchart defaults below.
# Profile files inherit those defaults; remove profile-local mode flags so they
# do not duplicate the implementation choice or drift on future upgrades.
while IFS= read -r -d '' values_file; do
  if yq -e 'has("mongodb-store")' "$values_file" >/dev/null 2>&1; then
    yq -i '
      del(
        ."mongodb-store".useBitnami,
        ."mongodb-store".usePerconaOperator,
        ."mongodb-store".mongodb.helperImages,
        ."mongodb-store".mongodb.image,
        ."mongodb-store".mongodb.tls.image,
        ."mongodb-store".mongodb.metrics.image
      )
    ' "$values_file"
  fi
done < <(find . -type f -name 'values*.yaml' -print0)

# Relok8s does not support image paths addressed through list indexes such as
# initContainers[0]. Keep the upstream initContainers list shape, but expose
# named image aliases and make each list item reference its alias. This is the
# same pattern used by the Velero repackaging flow.
while IFS= read -r -d '' values_file; do
  if yq -e '
    .initContainers[0].image.repository != null and
    .initContainers[1].image.repository != null and
    .initContainers[2].image.repository != null
  ' "$values_file" >/dev/null 2>&1; then
    yq -i '
      .image.initContainers = {
        "dcgmDiag": .initContainers[0].image,
        "ncclLoopback": .initContainers[1].image,
        "ncclAllreduce": .initContainers[2].image
      } |
      .initContainers[0].image = "{{ .Values.image.initContainers.dcgmDiag.repository }}:{{ .Values.image.initContainers.dcgmDiag.tag }}" |
      .initContainers[1].image = "{{ .Values.image.initContainers.ncclLoopback.repository }}:{{ .Values.image.initContainers.ncclLoopback.tag }}" |
      .initContainers[2].image = "{{ .Values.image.initContainers.ncclAllreduce.repository }}:{{ .Values.image.initContainers.ncclAllreduce.tag }}"
    ' "$values_file"
  elif yq -e '
    .preflight.initContainers[0].image.repository != null and
    .preflight.initContainers[1].image.repository != null and
    .preflight.initContainers[2].image.repository != null
  ' "$values_file" >/dev/null 2>&1; then
    yq -i '
      .preflight.image.initContainers = {
        "dcgmDiag": .preflight.initContainers[0].image,
        "ncclLoopback": .preflight.initContainers[1].image,
        "ncclAllreduce": .preflight.initContainers[2].image
      } |
      .preflight.initContainers[0].image = "{{ .Values.image.initContainers.dcgmDiag.repository }}:{{ .Values.image.initContainers.dcgmDiag.tag }}" |
      .preflight.initContainers[1].image = "{{ .Values.image.initContainers.ncclLoopback.repository }}:{{ .Values.image.initContainers.ncclLoopback.tag }}" |
      .preflight.initContainers[2].image = "{{ .Values.image.initContainers.ncclAllreduce.repository }}:{{ .Values.image.initContainers.ncclAllreduce.tag }}"
    ' "$values_file"
  fi
done < <(find . -type f -name 'values*.yaml' -print0)

# The preflight chart resolves image maps itself. Evaluate the new template
# strings before formatting the generated init container objects.
while IFS= read -r -d '' helper_file; do
  perl -pi -e 's/\{\{- \$image -\}\}/{{- tpl \$image \$root -}}/' "$helper_file"
done < <(find . -path '*/charts/preflight/templates/_helpers.tpl' -type f -print0)

# PSMDB also accepts sidecars as a list. Keep that upstream list shape, but
# expose the sidecar image through a named map in the mongodb-store values and
# let the PSMDB template evaluate the templated list before writing the custom
# resource. This mirrors the preflight/Velero workaround without changing the
# chart's public layout.
PSMDB_VALUES=$(find . -path '*/charts/mongodb-store/values.yaml' -print -quit)
if [ -n "$PSMDB_VALUES" ]; then
  # Use the existing Percona implementation instead of the Bitnami MongoDB
  # dependency. The Percona images published for this chart are multi-arch.
  yq -i '
    .useBitnami = false |
    .usePerconaOperator = true |
    del(.mongodb.helperImages, .mongodb.image, .mongodb.tls.image, .mongodb.metrics.image)
  ' "$PSMDB_VALUES"

  PSMDB_CHART_DIR=$(dirname "$PSMDB_VALUES")
  if [ -f "$PSMDB_CHART_DIR/Chart.yaml" ]; then
    yq -i 'del(.dependencies[] | select(.name == "mongodb"))' "$PSMDB_CHART_DIR/Chart.yaml"
  fi
  # The lock file would otherwise retain the removed Bitnami dependency and
  # become inconsistent with the generated Chart.yaml.
  if [ -f "$PSMDB_CHART_DIR/Chart.lock" ]; then
    rm -f "$PSMDB_CHART_DIR/Chart.lock"
  fi
  BITNAMI_MONGODB_CHART=$(find "$PSMDB_CHART_DIR/charts" -maxdepth 1 -type d -name mongodb -print -quit)
  if [ -n "$BITNAMI_MONGODB_CHART" ]; then
    rm -rf "$BITNAMI_MONGODB_CHART"
  fi
fi

if [ -n "$PSMDB_VALUES" ] && yq -e '
  ."psmdb-db".replsets.rs0.sidecars[0].image != null
' "$PSMDB_VALUES" >/dev/null 2>&1; then
  yq -i '
    ."psmdb-db".image.sidecars.mongodbExporter =
      ."psmdb-db".replsets.rs0.sidecars[0].image |
    ."psmdb-db".replsets.rs0.sidecars[0].image =
      "{{ .Values.image.sidecars.mongodbExporter }}"
  ' "$PSMDB_VALUES"
fi

while IFS= read -r -d '' psmdb_template; do
  perl -pi -e \
    's/\{\{ \$replset\.sidecars \| toYaml \| indent 6 \}\}/{{ tpl (\$replset.sidecars | toYaml) \$ | indent 6 }}/' \
    "$psmdb_template"
done < <(find . -path '*/charts/psmdb-db/templates/cluster.yaml' -type f -print0)

# The external MongoDB setup job has a source-registry fallback directly in a
# template. Rewrite template literals as well as values-driven image settings.
while IFS= read -r -d '' template_file; do
  perl -pi -e '
    s/(?<![A-Za-z0-9_.-])ghcr\.io\//ghcr.m.daocloud.io\//g;
    s/(?<![A-Za-z0-9_.-])quay\.io\//quay.m.daocloud.io\//g;
    s/(?<![A-Za-z0-9_.-])nvcr\.io\//nvcr.m.daocloud.io\//g;
    s/(?<![A-Za-z0-9_.-])(?<!m\.daocloud\.io\/)public\.ecr\.aws\//m.daocloud.io\/public.ecr.aws\//g;
  ' "$template_file"
done < <(find . -path '*/templates/*' -type f \( -name '*.yaml' -o -name '*.yml' -o -name '*.tpl' \) -print0)

# The chart now uses the Percona branch, so remove inactive Bitnami MongoDB
# entries from the relocation hints and add the Percona helper images used by
# the database setup job. Keep the hints value-driven so future version bumps
# continue to follow the chart values.
if [ -f .relok8s-images.yaml ]; then
  yq -i '
    map(select(test("\\.nvsentinel\\.mongodb-store\\.mongodb\\.") | not)) + [
      "{{ .nvsentinel.mongodb-store.psmdb.helperImages.kubectl.repository }}:{{ .nvsentinel.mongodb-store.psmdb.helperImages.kubectl.tag }}",
      "{{ .nvsentinel.mongodb-store.psmdb.helperImages.mongosh.repository }}:{{ .nvsentinel.mongodb-store.psmdb.helperImages.mongosh.tag }}"
    ] | unique | map(. style = "double")
  ' .relok8s-images.yaml
fi

# The upstream chart currently does not ship a README.md; add a minimal
# description for the repackaged chart.
if [ ! -s README.md ]; then
  cat > README.md <<'EOF'
# NVSentinel

NVSentinel is NVIDIA's Kubernetes-native platform for GPU cluster health monitoring and remediation.

This Helm chart deploys NVSentinel and its related components in a Kubernetes cluster.
EOF
fi

# The source chart has no keywords, while the repository CI requires them on
# every generated chart.
yq -i '.keywords = ["gpu", "monitoring", "nvsentinel"]' Chart.yaml
