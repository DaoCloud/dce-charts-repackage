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
# to the chart appVersion; make those tags explicit for relok8s.
# The upstream v1.23.0 slurm-drain-monitor image is available, so its empty tag
# can be normalized to v1.23.0 together with the other release images.
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
      has("tag") and .tag == "") | .tag
  ) = strenv(VERSION)' "$values_file"

  VERSION="$VERSION" yq -i '(
    .. | select(tag == "!!map" and has("repository") and (.repository | tag == "!!str") and
      ((.repository | test("^ghcr\\.m\\.daocloud\\.io/")) or
       (.repository | test("^docker\\.m\\.daocloud\\.io/")) or
       (.repository | test("^quay\\.m\\.daocloud\\.io/")) or
       (.repository | test("^nvcr\\.m\\.daocloud\\.io/")) or
       (.repository | test("^m\\.daocloud\\.io/public\\.ecr\\.aws/"))) and
      .tag == null)
  ) |= (.tag = strenv(VERSION))' "$values_file"
}

# Rewrite every values profile shipped by the chart, including values-full.yaml
# and the Tilt profiles used to exercise optional modules.
while IFS= read -r -d '' values_file; do
  mirror_values "$values_file"
done < <(find . -type f -name 'values*.yaml' -print0)

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
