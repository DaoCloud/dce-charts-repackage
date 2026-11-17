#!/bin/bash

set -x
set -o errexit
set -o nounset
set -o pipefail

# 获取当前脚本所在目录
CURRENT_DIR_PATH=$(cd "$(dirname "$0")"; pwd)
cd "$CURRENT_DIR_PATH"

# 加载 config
source ./config

echo "构建 nvidia-vgpu-commercial chart from ${CHART_OCI_REF}:${VERSION}"

# 清理并创建临时目录
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# 从 Dynamia 软件中心（https://docs.dynamia.ai/zh/docs/software）发布的 OCI 仓库拉取上游 chart
helm pull "${CHART_OCI_REF}" --version "${VERSION}" --untar --untardir "$TMP_DIR"

# 获取解压后的 chart 目录名
CHART_DIR_NAME=$(ls "$TMP_DIR")
CHART_DIR="$TMP_DIR/$CHART_DIR_NAME"

echo "解压后的 chart 目录: $CHART_DIR"
ls -la "$CHART_DIR"

# 获取子 chart 的 appVersion
SUB_NAME=$(yq '.name' "$CHART_DIR/Chart.yaml")
SUB_APP_VERSION=$(yq '.appVersion' "$CHART_DIR/Chart.yaml")
SUB_VERSION=$(yq '.version' "$CHART_DIR/Chart.yaml")

# 清理并创建输出目录
rm -rf nvidia-vgpu-commercial || true
mkdir -p nvidia-vgpu-commercial/charts

# 复制解压的 chart 到输出目录的 charts 子目录（作为子 chart）
# 上游 chart 名为 hami-enterprise，以 alias hami 引入，保持父 chart values 的 hami: 前缀与资源命名不变
cp -rf "$CHART_DIR" nvidia-vgpu-commercial/charts/hami

# 生成父 chart 的 Chart.yaml（不再拷贝子 chart 的）
cat > nvidia-vgpu-commercial/Chart.yaml <<EOF
apiVersion: v2
name: nvidia-vgpu-commercial
version: ${CUSTOM_VERSION}
appVersion: ${SUB_APP_VERSION}
description: Heterogeneous AI Computing Virtualization Middleware (Commercial Edition)
keywords:
  - vgpu
  - gpu
kubeVersion: '>= 1.18.0-0'
maintainers: []
sources:
  - https://github.com/dynamia-ai/hami-enterprise
type: application
dependencies:
  - name: ${SUB_NAME}
    alias: hami
    version: "${SUB_VERSION}"
    repository: "file://charts/hami"
EOF

# 生成父 chart 的 values.yaml：将子 chart 的 values 嵌套在 hami: 键下
echo "# Default values for nvidia-vgpu-commercial" > nvidia-vgpu-commercial/values.yaml
echo "hami:" >> nvidia-vgpu-commercial/values.yaml
sed -E 's/(.*)/  \1/g' "$CHART_DIR"/values.yaml >> nvidia-vgpu-commercial/values.yaml

# 复制 parent 目录的定制内容（README.md, values.schema.json, .relok8s-images.yaml 等，不覆盖 Chart.yaml 和 values.yaml）
if [ -d "parent" ]; then
    # 只复制 README.md, values.schema.json 和 .relok8s-images.yaml
    [ -f "parent/README.md" ] && cp parent/README.md nvidia-vgpu-commercial/
    [ -f "parent/values.schema.json" ] && cp parent/values.schema.json nvidia-vgpu-commercial/
    [ -f "parent/.relok8s-images.yaml" ] && cp parent/.relok8s-images.yaml nvidia-vgpu-commercial/
fi

# 调用 custom.sh 进行定制
if [ -f "custom.sh" ]; then
    chmod +x custom.sh
    ./custom.sh nvidia-vgpu-commercial
fi

echo ""
echo "=========================================="
echo "nvidia-vgpu-commercial chart 构建完成"
echo "版本: ${CUSTOM_VERSION}"
echo "=========================================="
ls -la nvidia-vgpu-commercial/
