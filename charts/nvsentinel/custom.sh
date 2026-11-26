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
      del(."mongodb-store".useBitnami, ."mongodb-store".usePerconaOperator)
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
    .usePerconaOperator = true
  ' "$PSMDB_VALUES"
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

# charts-syncer relocates images by rewriting the wrapper chart's values.yaml:
# once the wrapper values define the subchart key (.nvsentinel), every hint is
# applied to that file, and a hint whose path is missing there is skipped
# without an error. Most NVSentinel images are only defined by nested
# subcharts, so without this step an offline import pushes the images but
# leaves the chart pointing at the source registries. Promote every value
# referenced by the relocation hints into the wrapper values.yaml. Parent
# values take precedence in Helm, so the shallowest chart defining a value wins.
yq_path() {
  local expr="" segment
  for segment in "$@"; do
    expr+=".\"${segment}\""
  done
  printf '%s' "$expr"
}

promote_hint_value() {
  local hint_path=$1
  local -a segments
  IFS='.' read -r -a segments <<<"$hint_path"

  local wrapper_expr
  wrapper_expr=$(yq_path "${segments[@]}")
  if yq -e "${wrapper_expr} != null" values.yaml >/dev/null 2>&1; then
    return 0
  fi

  local chart_dir="charts/${segments[0]}"
  local index=1
  local expr value
  while [ -f "${chart_dir}/values.yaml" ] && [ "$index" -lt "${#segments[@]}" ]; do
    expr=$(yq_path "${segments[@]:$index}")
    if yq -e "${expr} != null" "${chart_dir}/values.yaml" >/dev/null 2>&1; then
      value=$(yq -r "${expr}" "${chart_dir}/values.yaml")
      PROMOTED_VALUE="$value" yq -i "${wrapper_expr} = strenv(PROMOTED_VALUE)" values.yaml
      return 0
    fi
    chart_dir="${chart_dir}/charts/${segments[$index]}"
    index=$((index + 1))
  done

  echo "custom shell: error, relocation hint .${hint_path} is not defined by any chart values" >&2
  return 1
}

if [ -f .relok8s-images.yaml ]; then
  while IFS= read -r hint_path; do
    promote_hint_value "$hint_path"
  done < <(
    perl -ne 'print "$1\n" while /\{\{\s*\.([^\s}]+)\s*\}\}/g' .relok8s-images.yaml |
      LC_ALL=C sort -u
  )
fi

# Expose the settings DCE users most often need to change in the wrapper
# values.yaml, so they are visible in the installation form instead of being
# hidden in nested subchart defaults.
LABELER_VALUES=charts/nvsentinel/charts/labeler/values.yaml
if [ -f "$LABELER_VALUES" ] && yq -e '.assumeDriverInstalled != null' "$LABELER_VALUES" >/dev/null 2>&1; then
  ASSUME_DRIVER_INSTALLED=$(yq '.assumeDriverInstalled' "$LABELER_VALUES") yq -i '
    .nvsentinel.labeler.assumeDriverInstalled = (strenv(ASSUME_DRIVER_INSTALLED) | from_yaml) |
    (.nvsentinel.labeler.assumeDriverInstalled | key) head_comment =
      "Set to true when the NVIDIA driver is installed on the host instead of by the\nGPU Operator driver container. The labeler then marks every GPU node with\nnvsentinel.dgxc.nvidia.com/driver.installed=true. Without that label the\ngpu-health-monitor, syslog-health-monitor and metadata-collector DaemonSets\nschedule no Pods."
  ' values.yaml
fi

if [ -n "$PSMDB_VALUES" ]; then
  PSMDB_DB_VALUES=$(find . -path '*/charts/mongodb-store/charts/psmdb-db/values.yaml' -print -quit)
  RS0_SIZE=$(yq '."psmdb-db".replsets.rs0.size' "$PSMDB_VALUES")
  UNSAFE_REPLSET_SIZE=$(yq '.unsafeFlags.replsetSize' "$PSMDB_DB_VALUES")
  RS0_TOPOLOGY_KEY=$(yq -r '.replsets.rs0.affinity.antiAffinityTopologyKey' "$PSMDB_DB_VALUES")

  # The upstream default is a required anti-affinity on the hostname, which
  # leaves a replica Pending on clusters with fewer nodes than replicas. Prefer
  # spreading instead, so small clusters still start while larger clusters keep
  # one replica per node. The operator uses "advanced" in place of
  # antiAffinityTopologyKey whenever it is set.
  RS0_SIZE="$RS0_SIZE" UNSAFE_REPLSET_SIZE="$UNSAFE_REPLSET_SIZE" RS0_TOPOLOGY_KEY="$RS0_TOPOLOGY_KEY" yq -i '
    .nvsentinel."mongodb-store"."psmdb-db".unsafeFlags.replsetSize = (strenv(UNSAFE_REPLSET_SIZE) | from_yaml) |
    (.nvsentinel."mongodb-store"."psmdb-db".unsafeFlags.replsetSize | key) head_comment =
      "Must be true to run the replica set with fewer than 3 or an even number of\nmembers, for example a single member on a test cluster." |
    .nvsentinel."mongodb-store"."psmdb-db".replsets.rs0.size = (strenv(RS0_SIZE) | from_yaml) |
    (.nvsentinel."mongodb-store"."psmdb-db".replsets.rs0.size | key) head_comment =
      "Number of MongoDB replica set members. Lowering it on an existing\ninstallation does not delete the PVCs of the removed members." |
    .nvsentinel."mongodb-store"."psmdb-db".replsets.rs0.affinity.antiAffinityTopologyKey = strenv(RS0_TOPOLOGY_KEY) |
    .nvsentinel."mongodb-store"."psmdb-db".replsets.rs0.affinity.advanced = {
      "podAntiAffinity": {
        "preferredDuringSchedulingIgnoredDuringExecution": [
          {
            "weight": 100,
            "podAffinityTerm": {
              "topologyKey": "kubernetes.io/hostname",
              "labelSelector": {
                "matchLabels": {
                  "app.kubernetes.io/name": "percona-server-mongodb",
                  "app.kubernetes.io/component": "mongod",
                  "app.kubernetes.io/replset": "rs0"
                }
              }
            }
          }
        ]
      }
    } |
    (.nvsentinel."mongodb-store"."psmdb-db".replsets.rs0.affinity | key) head_comment =
      "Members prefer different nodes but may share one, so the replica set also\nstarts on clusters with fewer nodes than members. The operator ignores\nantiAffinityTopologyKey while advanced is set. To require one member per\nnode, set advanced to null. To disable anti-affinity, set advanced to null\nand antiAffinityTopologyKey to \"none\"."
  ' values.yaml
fi

# values.schema.json was generated before the wrapper values were extended.
# Regenerate it so the schema keeps matching values.yaml. Helm deep-merges maps,
# so the default affinity.advanced can only be removed by setting it to null;
# allow that in the generated schema.
if helm schema-gen -h >/dev/null 2>&1; then
  helm schema-gen values.yaml > values.schema.json
  jq --indent 4 '
    (
      .properties.nvsentinel.properties."mongodb-store".properties."psmdb-db".properties.replsets
      .properties.rs0.properties.affinity.properties.advanced | select(. != null) | .type
    ) = ["object", "null"]
  ' values.schema.json > values.schema.json.tmp
  mv values.schema.json.tmp values.schema.json
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
