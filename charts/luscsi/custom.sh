#!/bin/bash
# LuCSI 自定义处理脚本
# 此脚本会在chart生成过程中被调用，可进行复杂的定制修改

set -e

CHART_DIR=$1

if [ -z "$CHART_DIR" ]; then
    echo "Error: CHART_DIR not provided"
    exit 1
fi

echo "执行 LuCSI 自定义处理..."
echo "Chart 目录: $CHART_DIR"

# 示例：确保镜像使用正确的registry
echo "✓ 验证镜像配置..."

# 如果需要在此处理特殊的向后兼容问题，可以添加条件逻辑
# 例如：检查chart版本，处理不兼容的values等

# 示例：添加自定义的CRD或其他资源（如需要）
# if [ -d "$CHART_DIR/crds" ]; then
#     echo "✓ 处理CRD文件..."
# fi

echo "✓ LuCSI 自定义处理完成"

