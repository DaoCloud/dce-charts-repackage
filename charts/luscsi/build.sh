#!/bin/bash
set -e

# 获取参数
PROJECT_DIR="${1:-.}"
CHART_NAME="luscsi"

echo "Building $CHART_NAME chart..."

# 输出目录
OUTPUT_DIR="${PROJECT_DIR}/${CHART_NAME}"

# 如果输出目录已存在，清空它
if [ -d "$OUTPUT_DIR" ]; then
    rm -rf "$OUTPUT_DIR"
fi

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 复制原始chart文件到输出目录
cp -r ${PROJECT_DIR}/luscsi/* "$OUTPUT_DIR/"

# 如果parent目录存在，覆盖输出目录中的相应文件
if [ -d "${PROJECT_DIR}/parent" ]; then
    echo "Applying parent chart customizations..."
    cp -r ${PROJECT_DIR}/parent/* "$OUTPUT_DIR/"
fi

# 如果appendValues.yaml存在，追加到values.yaml
if [ -f "${PROJECT_DIR}/appendValues.yaml" ]; then
    echo "Appending additionalValues..."
    cat "${PROJECT_DIR}/appendValues.yaml" >> "$OUTPUT_DIR/values.yaml"
fi


echo "$CHART_NAME chart build completed successfully!"

