#!/bin/bash

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================
#===============================

set -o errexit
set -o pipefail
set -o nounset

rm -rf ./charts/gitlab/charts/registry
rm -rf ./charts/gitlab/charts/cert-manager
rm -rf ./charts/gitlab/charts/certmanager-issuer
rm -rf ./charts/gitlab/charts/gitlab-zoekt
rm -rf ./charts/gitlab/charts/kubernetes-ingress
rm -rf ./charts/gitlab/charts/redis/img
rm -rf ./charts/gitlab/charts/prometheus
rm -rf ./charts/gitlab/charts/traefik
rm -rf ./charts/gitlab/charts/nginx-ingress
rm -rf ./charts/gitlab/charts/grafana
rm -rf ./charts/gitlab/charts/gitlab-runner
rm -rf ./charts/gitlab/charts/gitlab/requirements.yaml
rm -rf ./charts/gitlab/charts/gitlab/charts/geo-logcursor
rm -rf ./charts/gitlab/charts/gitlab/charts/gitlab-exporter
rm -rf ./charts/gitlab/charts/gitlab/charts/gitlab-pages
rm -rf ./charts/gitlab/charts/gitlab/charts/gitlab-grafana
rm -rf ./charts/gitlab/charts/gitlab/charts/mailroom
rm -rf ./charts/gitlab/charts/gitlab/charts/praefect
rm -rf ./charts/gitlab/charts/gitlab/charts/spamcheck
rm -rf ./charts/gitlab/charts/gitlab/charts/webservice/templates/tests
rm -rf ./charts/gitlab/support
rm -rf ./charts/gitlab/requirements.yaml
rm -rf ./charts/gitlab/requirements.lock
rm -rf ./charts/gitlab/CHANGELOG.md
rm -rf ./charts/gitlab/templates/NOTES.txt

TARGET_VERSION=$APP_VERSION

# modify father values
yq -i '
  .gitlab.minio.minioMc.registry = "docker.m.daocloud.io" |
  .gitlab.minio.registry = "docker.m.daocloud.io" |
  .gitlab.gitlab.gitaly.image.registry = "m.daocloud.io/registry.gitlab.com" |
  .gitlab.gitlab.gitaly.image.repository = "gitlab-org/build/cng/gitaly" |
  .gitlab.gitlab.gitaly.image.tag = "'$TARGET_VERSION'" |
  .gitlab.gitlab.gitlab-shell.image.registry = "m.daocloud.io/registry.gitlab.com" |
  .gitlab.gitlab.gitlab-shell.image.repository = "gitlab-org/build/cng/gitlab-shell" |
  .gitlab.gitlab.gitlab-shell.image.tag = "'$TARGET_VERSION'" |
  .gitlab.gitlab.kas.image.registry = "m.daocloud.io/registry.gitlab.com" |
  .gitlab.gitlab.kas.image.repository = "gitlab-org/build/cng/gitlab-kas" |
  .gitlab.gitlab.kas.image.tag = "'$TARGET_VERSION'" |
  .gitlab.gitlab.migrations.image.registry = "m.daocloud.io/registry.gitlab.com" |
  .gitlab.gitlab.migrations.image.repository = "gitlab-org/build/cng/gitlab-toolbox-ce" |
  .gitlab.gitlab.migrations.image.tag = "'$TARGET_VERSION'" |
  .gitlab.gitlab.toolbox.image.registry = "m.daocloud.io/registry.gitlab.com" |
  .gitlab.gitlab.toolbox.image.repository = "gitlab-org/build/cng/gitlab-toolbox-ce" |
  .gitlab.gitlab.toolbox.image.tag = "'$TARGET_VERSION'" |
  .gitlab.gitlab.webservice.image.registry = "m.daocloud.io/registry.gitlab.com" |
  .gitlab.gitlab.webservice.image.repository = "gitlab-org/build/cng/gitlab-webservice-ce" |
  .gitlab.gitlab.webservice.image.tag = "'$TARGET_VERSION'" |
  .gitlab.gitlab.webservice.workhorse.image.registry = "m.daocloud.io/registry.gitlab.com" |
  .gitlab.gitlab.webservice.workhorse.image.repository = "gitlab-org/build/cng/gitlab-workhorse-ce" |
  .gitlab.gitlab.webservice.workhorse.image.tag = "'$TARGET_VERSION'" |
  .gitlab.gitlab.sidekiq.image.registry = "m.daocloud.io/registry.gitlab.com" |
  .gitlab.gitlab.sidekiq.image.repository = "gitlab-org/build/cng/gitlab-sidekiq-ce" |
  .gitlab.gitlab.sidekiq.image.tag = "'$TARGET_VERSION'" |
  .gitlab.kubectl.image.registry = "m.daocloud.io/registry.gitlab.com" |
  .gitlab.kubectl.image.repository = "gitlab-org/build/cng/kubectl" |
  .gitlab.kubectl.image.tag = "'$TARGET_VERSION'" |
  .gitlab.postgresql.image.registry = "docker.m.daocloud.io" |
  .gitlab.postgresql.volumePermissions.image.registry = "docker.m.daocloud.io" |
  .gitlab.postgresql.metrics.image.registry = "docker.m.daocloud.io" |
  .gitlab.redis.image.registry = "docker.m.daocloud.io" |
  .gitlab.redis.metrics.image.registry = "docker.m.daocloud.io" |
  .gitlab.redis.sentinel.image.registry = "docker.m.daocloud.io" |
  .gitlab.redis.volumePermissions.image.registry = "docker.m.daocloud.io" |
  .gitlab.redis.sysctl.image.registry = "docker.m.daocloud.io" |
  .gitlab.global.certificates.image.registry = "m.daocloud.io/registry.gitlab.com" |
  .gitlab.global.certificates.image.repository = "gitlab-org/build/cng/certificates" |
  .gitlab.global.certificates.image.tag = "'$TARGET_VERSION'" |
  .gitlab.global.gitlabBase.image.registry = "m.daocloud.io/registry.gitlab.com" |
  .gitlab.global.gitlabBase.image.repository = "gitlab-org/build/cng/gitlab-base" |
  .gitlab.global.gitlabBase.image.tag = "'$TARGET_VERSION'"
' values.yaml

yq -i '
  .image.registry = "docker.m.daocloud.io" |
  .metrics.image.registry = "docker.m.daocloud.io" |
  .sentinel.image.registry = "docker.m.daocloud.io" |
  .volumePermissions.image.registry = "docker.m.daocloud.io" |
  .sysctl.image.registry = "docker.m.daocloud.io"
' charts/gitlab/charts/redis/values.yaml

yq -i '
  .image.registry = "docker.m.daocloud.io" |
  .volumePermissions.image.registry = "docker.m.daocloud.io" |
  .metrics.image.registry = "docker.m.daocloud.io"
' charts/gitlab/charts/postgresql/values.yaml

yq -i '
  .minioMc.registry = "docker.m.daocloud.io" |
  .registry = "docker.m.daocloud.io"
' charts/gitlab/charts/minio/values.yaml

yq -i '
  .image.registry = "m.daocloud.io/registry.gitlab.com" |
  .image.repository = "gitlab-org/build/cng/gitlab-webservice-ce" |
  .image.tag = "'$TARGET_VERSION'" |
  .workhorse.image.registry = "m.daocloud.io/registry.gitlab.com" |
  .workhorse.image.repository = "gitlab-org/build/cng/gitlab-workhorse-ce" |
  .workhorse.image.tag = "'$TARGET_VERSION'"
' charts/gitlab/charts/gitlab/charts/webservice/values.yaml

yq -i '
  .image.registry = "m.daocloud.io/registry.gitlab.com" |
  .image.repository = "gitlab-org/build/cng/gitlab-toolbox-ce" |
  .image.tag = "'$TARGET_VERSION'"
' charts/gitlab/charts/gitlab/charts/toolbox/values.yaml

yq -i '
  .image.registry = "m.daocloud.io/registry.gitlab.com" |
  .image.repository = "gitlab-org/build/cng/gitlab-toolbox-ce" |
  .image.tag = "'$TARGET_VERSION'"
' charts/gitlab/charts/gitlab/charts/migrations/values.yaml

yq -i '
  .image.registry = "m.daocloud.io/registry.gitlab.com" |
  .image.repository = "gitlab-org/build/cng/gitlab-kas" |
  .image.tag = "'$TARGET_VERSION'"
' charts/gitlab/charts/gitlab/charts/kas/values.yaml

yq -i '
  .image.registry = "m.daocloud.io/registry.gitlab.com" |
  .image.repository = "gitlab-org/build/cng/gitlab-shell" |
  .image.tag = "'$TARGET_VERSION'"
' charts/gitlab/charts/gitlab/charts/gitlab-shell/values.yaml

yq -i '
  .image.registry = "m.daocloud.io/registry.gitlab.com" |
  .image.repository = "gitlab-org/build/cng/gitaly" |
  .image.tag = "'$TARGET_VERSION'"
' charts/gitlab/charts/gitlab/charts/gitaly/values.yaml

yq -i '
  .image.registry = "m.daocloud.io/registry.gitlab.com" |
  .image.repository = "gitlab-org/build/cng/gitlab-sidekiq-ce" |
  .image.tag = "'$TARGET_VERSION'"
' charts/gitlab/charts/gitlab/charts/sidekiq/values.yaml


sed -i 's/image: {{ .Values.minioMc.image }}:{{ .Values.minioMc.tag }}/image: {{ .Values.minioMc.registry}}\/{{ .Values.minioMc.image }}:{{ .Values.minioMc.tag }}/' charts/gitlab/charts/minio/templates/create-buckets-job.yaml
sed -i 's/image: {{ .Values.image }}:{{ .Values.imageTag }}/image: {{ .Values.registry }}\/{{ .Values.image }}:{{ .Values.imageTag }}/' charts/gitlab/charts/minio/templates/minio_deployment.yaml
# 移除了 {{ include "gitlab.image.tagSuffix" . }}
sed -i 's/image: "{{ .Values.image.repository }}:{{ coalesce .Values.image.tag (include "gitlab.parseAppVersion" (dict "appVersion" .Chart.AppVersion "prepend" "true")) }}{{ include "gitlab.image.tagSuffix" . }}"/image: "{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag }}"/' charts/gitlab/charts/gitlab/charts/gitaly/templates/_statefulset_spec.yaml
sed -i 's/image: "{{ .Values.image.repository }}:{{ coalesce .Values.image.tag (include "gitlab.parseAppVersion" (dict "appVersion" .Chart.AppVersion "prepend" "true")) }}{{ include "gitlab.image.tagSuffix" . }}"/image: "{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag }}"/' charts/gitlab/charts/gitlab/charts/gitlab-shell/templates/deployment.yaml
sed -i 's/image: "{{ .Values.image.repository }}:{{ coalesce .Values.image.tag (include "gitlab.parseAppVersion" (dict "appVersion" .Chart.AppVersion "prepend" "true")) }}{{ include "gitlab.image.tagSuffix" . }}"/image: "{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag }}"/' charts/gitlab/charts/gitlab/charts/kas/templates/deployment.yaml
sed -i 's/image: "{{ coalesce .Values.image.repository (include "image.repository" .) }}:{{ coalesce .Values.image.tag (include "gitlab.versionTag" . ) }}{{ include "gitlab.image.tagSuffix" . }}"/image: "{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag }}"/' charts/gitlab/charts/gitlab/charts/toolbox/templates/deployment.yaml
sed -i 's/image: "{{ coalesce .Values.image.repository (include "image.repository" .) }}:{{ coalesce .Values.image.tag (include "gitlab.versionTag" . ) }}{{ include "gitlab.image.tagSuffix" . }}"/image: "{{ .Values.image.registry }}\/{{ .Values.image.repository }}:{{ .Values.image.tag }}"/' charts/gitlab/charts/gitlab/charts/migrations/templates/_jobspec.yaml
sed -i 's/image: {{ include "webservice.image" $ }}/image: {{ $.Values.image.registry }}\/{{ $.Values.image.repository }}:{{ $.Values.image.tag }}/' charts/gitlab/charts/gitlab/charts/webservice/templates/deployment.yaml
sed -i 's/image: "{{ coalesce $.Values.workhorse.image.*/image: {{ $.Values.workhorse.image.registry }}\/{{ $.Values.workhorse.image.repository }}:{{ $.Values.workhorse.image.tag }}/' charts/gitlab/charts/gitlab/charts/webservice/templates/deployment.yaml
sed -i 's/image: {{ include "gitlab.kubectl.image" . }}/image: {{ .Values.kubectl.image.registry }}\/{{ .Values.kubectl.image.repository }}:{{ .Values.kubectl.image.tag }}/' charts/gitlab/templates/shared-secrets/job.yaml
sed -i 's/image: {{ include "gitlab.kubectl.image" . }}/image: {{ .Values.kubectl.image.registry }}\/{{ .Values.kubectl.image.repository }}:{{ .Values.kubectl.image.tag }}/' charts/gitlab/templates/shared-secrets/self-signed-cert-job.yml


sed -i 's/{{- $image := (printf "%s:%s%s" (coalesce .Values.image.repository (include "image.repository" .)) (coalesce .Values.image.tag (include "gitlab.versionTag" . )) (include "gitlab.image.tagSuffix" .)) | toString -}}/{{- $image := (printf "%s\/%s:%s" (coalesce .Values.image.registry (include "image.repository" .)) (coalesce .Values.image.repository) (coalesce .Values.image.tag)) | toString -}}/' charts/gitlab/charts/gitlab/charts/sidekiq/templates/deployment.yaml


sed -i 's/openssl req -new -newkey rsa:4096 -subj "\/CN={{ coalesce .Values.registry.tokenIssuer  (dig "registry" "tokenIssuer" "gitlab-issuer" .Values.global ) }}" -nodes -x509 -keyout certs\/registry-example-com.key -out certs\/registry-example-com.crt -days 3650/openssl req -new -newkey rsa:4096 -subj "\/CN={{ coalesce .Values.global.registry.tokenIssuer  (dig "registry" "tokenIssuer" "gitlab-issuer" .Values.global ) }}" -nodes -x509 -keyout certs\/registry-example-com.key -out certs\/registry-example-com.crt -days 3650/' charts/gitlab/templates/shared-secrets/_generate_secrets.sh.tpl

sed -i 's/{{- printf "%s:%s%s" .image.repository $tag $tagSuffix -}}/{{- printf "%s\/%s:%s%s" .image.registry .image.repository $tag $tagSuffix -}}/' charts/gitlab/templates/_image.tpl

#==============================
echo "fulfill tag"
sed -i 's@tag: ""@tag: "master"@g' values.yaml
exit $?