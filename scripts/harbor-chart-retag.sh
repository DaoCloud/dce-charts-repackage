#!/bin/bash
# 把 Harbor ChartMuseum 仓库里 version 含 '+' 的 chart 重新发布为 '-' 版本。
#
# ChartMuseum 没有 retag 语义，实际流程是:
#   拉取 tgz -> 改 Chart.yaml 的 version -> 重新 helm package -> cm-push -> (可选) 删除旧版本
#
# 依赖: curl, jq, helm, helm cm-push 插件
#   helm plugin install https://github.com/chartmuseum/helm-push
#
# 用法:
#   HARBOR_USER=xxx HARBOR_PASSWORD=xxx \
#     ./scripts/harbor-chart-retag.sh --project addon --chart nvidia-vgpu
#   加 --apply 才会真正写入; 再加 --delete-old 才会删除旧的 '+' 版本。

set -o errexit
set -o nounset
set -o pipefail

HARBOR_URL="${HARBOR_URL:-https://release.daocloud.io}"
PROJECT=""
CHART=""
APPLY=false
DELETE_OLD=false

usage() {
    cat <<'USAGE'
Usage: harbor-chart-retag.sh --project <harbor-project> [options]

  --project <name>   Harbor 项目名, 如 addon / community        (必填)
  --chart <name>     只处理该 chart; 不填则处理项目下所有 chart
  --apply            真正执行上传 (默认 dry-run, 只打印计划)
  --delete-old       上传成功后删除旧的 '+' 版本 (需要同时 --apply)
  -h, --help         显示帮助

环境变量:
  HARBOR_URL         默认 https://release.daocloud.io
  HARBOR_USER        Harbor 用户名 (必填)
  HARBOR_PASSWORD    Harbor 密码   (必填)
USAGE
}

while [ $# -gt 0 ]; do
    case "$1" in
        --project)    PROJECT="$2"; shift 2 ;;
        --chart)      CHART="$2"; shift 2 ;;
        --apply)      APPLY=true; shift ;;
        --delete-old) DELETE_OLD=true; shift ;;
        -h|--help)    usage; exit 0 ;;
        *) echo "unknown argument: $1" >&2; usage; exit 1 ;;
    esac
done

[ -z "$PROJECT" ] && echo "error: --project is required" >&2 && exit 1
[ -z "${HARBOR_USER:-}" ] && echo "error: HARBOR_USER is required" >&2 && exit 1
[ -z "${HARBOR_PASSWORD:-}" ] && echo "error: HARBOR_PASSWORD is required" >&2 && exit 1

for BIN in curl jq helm perl tar; do
    command -v "$BIN" >/dev/null || { echo "error: $BIN not found" >&2; exit 1; }
done
helm cm-push --help >/dev/null 2>&1 || {
    echo "error: helm cm-push plugin not installed" >&2
    echo "       helm plugin install https://github.com/chartmuseum/helm-push" >&2
    exit 1
}

AUTH="${HARBOR_USER}:${HARBOR_PASSWORD}"
REPO_ALIAS="retag-${PROJECT}"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "${WORK_DIR}"' EXIT

$APPLY || echo ">>> DRY-RUN 模式, 不会有任何写操作 (加 --apply 才执行)"
if $DELETE_OLD && ! $APPLY; then
    echo ">>> 注意: --delete-old 需要与 --apply 同时使用, 当前仅打印计划"
fi

# 1. 列出待处理的 chart
if [ -n "$CHART" ]; then
    CHART_LIST="$CHART"
else
    # 先落盘再解析, 避免 curl 的失败被管道 + '|| true' 吞掉
    if ! curl -sSf -u "$AUTH" -o "${WORK_DIR}/charts.json" \
         "${HARBOR_URL}/api/chartrepo/${PROJECT}/charts"; then
        echo "error: 无法列出项目 ${PROJECT} 的 chart" >&2
        echo "       确认 ${HARBOR_URL} 是否仍提供 ChartMuseum API (Harbor 2.8+ 已移除该组件)" >&2
        exit 1
    fi
    CHART_LIST=$(jq -r '.[].name' "${WORK_DIR}/charts.json")
fi
[ -z "$CHART_LIST" ] && echo "no chart found in project ${PROJECT}" && exit 0

if $APPLY; then
    # --force-update: 否则 alias 已存在时 helm 会直接报错退出
    helm repo add "$REPO_ALIAS" "${HARBOR_URL}/chartrepo/${PROJECT}" --force-update \
        --username="$HARBOR_USER" --password="$HARBOR_PASSWORD" >/dev/null
fi

PLANNED=0
DONE_LIST=""
FAILED_LIST=""

for NAME in $CHART_LIST; do
    # 2. 找出该 chart 下所有含 '+' 的版本
    if ! curl -sSf -u "$AUTH" -o "${WORK_DIR}/${NAME}-versions.json" \
         "${HARBOR_URL}/api/chartrepo/${PROJECT}/charts/${NAME}"; then
        echo "error: 无法读取 ${NAME} 的版本列表 (chart 不存在或 API 不可用)" >&2
        FAILED_LIST+=" ${NAME}"
        continue
    fi
    VERSIONS=$(jq -r '.[].version' "${WORK_DIR}/${NAME}-versions.json" | grep -F '+' || true)
    if [ -z "$VERSIONS" ]; then
        echo "skip  : ${NAME} 没有含 '+' 的版本"
        continue
    fi

    for OLD_VER in $VERSIONS; do
        NEW_VER="${OLD_VER//+/-}"
        PLANNED=$((PLANNED + 1))
        echo "----------------------------------------"
        echo "chart : ${NAME}"
        echo "plan  : ${OLD_VER}  ->  ${NEW_VER}"

        if ! $APPLY; then
            $DELETE_OLD && echo "        (--apply 后会删除旧版本 ${OLD_VER})"
            continue
        fi

        # 3. 下载 tgz ('+' 在 URL 里必须编码为 %2B, 否则会被解析成空格)
        ENCODED_VER="${OLD_VER//+/%2B}"
        TGZ="${WORK_DIR}/${NAME}-${OLD_VER}.tgz"
        if ! curl -sSfL -u "$AUTH" -o "$TGZ" \
             "${HARBOR_URL}/chartrepo/${PROJECT}/charts/${NAME}-${ENCODED_VER}.tgz"; then
            echo "error: failed to download ${NAME}-${OLD_VER}.tgz" >&2
            FAILED_LIST+=" ${NAME}-${OLD_VER}"
            continue
        fi

        # 4. 解包 + 改版本号 + 重新打包
        SRC_DIR="${WORK_DIR}/src-${NAME}-${OLD_VER}"
        OUT_DIR="${WORK_DIR}/out-${NAME}-${OLD_VER}"
        mkdir -p "$SRC_DIR" "$OUT_DIR"
        if ! tar -xzf "$TGZ" -C "$SRC_DIR"; then
            echo "error: failed to extract ${NAME}-${OLD_VER}.tgz" >&2
            FAILED_LIST+=" ${NAME}-${OLD_VER}"
            continue
        fi
        CHART_YAML="${SRC_DIR}/${NAME}/Chart.yaml"
        [ ! -f "$CHART_YAML" ] && echo "error: ${CHART_YAML} not found" >&2 && FAILED_LIST+=" ${NAME}-${OLD_VER}" && continue
        # 只改顶层 version 行, 不动 appVersion 和子 chart
        perl -0pi -e "s/^version: \Q${OLD_VER}\E\s*$/version: ${NEW_VER}\n/m" "$CHART_YAML"
        ACTUAL=$(helm show chart "${SRC_DIR}/${NAME}" | awk '/^version:/{print $2}')
        if [ "$ACTUAL" != "$NEW_VER" ]; then
            echo "error: rewrite version failed, got '${ACTUAL}', want '${NEW_VER}'" >&2
            FAILED_LIST+=" ${NAME}-${OLD_VER}"
            continue
        fi
        if ! helm package "${SRC_DIR}/${NAME}" --destination "$OUT_DIR" >/dev/null; then
            echo "error: failed to package ${NAME}-${NEW_VER}" >&2
            FAILED_LIST+=" ${NAME}-${OLD_VER}"
            continue
        fi

        # 5. 上传新版本
        if ! helm cm-push "${OUT_DIR}/${NAME}-${NEW_VER}.tgz" "$REPO_ALIAS" \
             --username="$HARBOR_USER" --password="$HARBOR_PASSWORD"; then
            echo "error: failed to push ${NAME}-${NEW_VER}.tgz" >&2
            FAILED_LIST+=" ${NAME}-${OLD_VER}"
            continue
        fi
        echo "pushed: ${NAME}-${NEW_VER}"

        # 6. 可选删除旧版本
        if $DELETE_OLD; then
            if curl -sSf -X DELETE -u "$AUTH" \
                 "${HARBOR_URL}/api/chartrepo/${PROJECT}/charts/${NAME}/${ENCODED_VER}" >/dev/null; then
                echo "deleted: ${NAME}-${OLD_VER}"
            else
                echo "warn: failed to delete old version ${NAME}-${OLD_VER}" >&2
            fi
        fi
        DONE_LIST+=" ${NAME}:${OLD_VER}->${NEW_VER}"
    done
done

echo "========================================"
echo "planned : ${PLANNED}"
$APPLY && echo "done    :${DONE_LIST:- none}"
$APPLY && echo "failed  :${FAILED_LIST:- none}"
[ -n "$FAILED_LIST" ] && exit 1
exit 0
