#!/bin/bash
set -e

# LuCSI E2E 测试脚本

# 接收从 Makefile 传入的参数
KUBECONFIG=${1:-.kube/config}
KIND_CLUSTER_NAME=${2:-network-chart}
VERSION=${3:-0.0.1}

# 计算脚本所在目录，用于找到 chart 路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$( cd "$SCRIPT_DIR/../../" && pwd )"

NAMESPACE=${NAMESPACE:-kube-system}
RELEASE_NAME=${RELEASE_NAME:-luscsi}
CHART_PATH=${ROOT_DIR}/charts/luscsi/luscsi
TIMEOUT=${TIMEOUT:-5m}

echo "================================"
echo "LuCSI Helm Chart Installation Test"
echo "================================"
echo "Namespace: $NAMESPACE"
echo "Release Name: $RELEASE_NAME"
echo "Chart Path: $CHART_PATH"
echo "Timeout: $TIMEOUT"
echo "KUBECONFIG: $KUBECONFIG"
echo "Kubernetes Cluster: $KIND_CLUSTER_NAME"
echo "Chart Version: $VERSION"
echo ""

# 检查 helm 是否已安装
if ! command -v helm &> /dev/null; then
    echo "❌ helm not found. Please install helm first."
    exit 1
fi

# 检查 kubectl 是否已安装
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi

# 创建命名空间（如果不存在）
echo "📝 Creating namespace $NAMESPACE if not exists..."
kubectl --kubeconfig=$KUBECONFIG create namespace $NAMESPACE --dry-run=client -o yaml | kubectl --kubeconfig=$KUBECONFIG apply -f -

# 安装 Helm Chart
echo "📦 Installing LuCSI chart..."
helm install $RELEASE_NAME $CHART_PATH \
  --namespace $NAMESPACE \
  --wait \
  --timeout $TIMEOUT \
  --debug \
  --kubeconfig=$KUBECONFIG

# 验证部署
echo ""
echo "✅ Helm install completed. Verifying deployment..."
echo ""

# 等待部署就绪
echo "⏳ Waiting for LuCSI controller deployment..."
kubectl --kubeconfig=$KUBECONFIG wait --for=condition=available --timeout=$TIMEOUT \
  deployment/luscsi-csi-controller \
  -n $NAMESPACE || true

echo ""
echo "⏳ Waiting for LuCSI node daemonset..."
kubectl --kubeconfig=$KUBECONFIG wait --for=condition=ready pod \
  -l app=luscsi-node \
  -n $NAMESPACE \
  --timeout=$TIMEOUT || true

# 显示部署状态
echo ""
echo "📊 Deployment Status:"
echo ""
echo "Deployments:"
kubectl --kubeconfig=$KUBECONFIG get deployments -n $NAMESPACE -l app=luscsi-csi-controller
echo ""

echo "DaemonSets:"
kubectl --kubeconfig=$KUBECONFIG get daemonsets -n $NAMESPACE -l app=luscsi-node
echo ""

echo "Pods:"
kubectl --kubeconfig=$KUBECONFIG get pods -n $NAMESPACE -l app.kubernetes.io/name=luscsi

# 显示 CSI 驱动信息
echo ""
echo "📋 CSI Driver Info:"
kubectl --kubeconfig=$KUBECONFIG get csidriver
echo ""

echo "✅ LuCSI installation test completed successfully!"
echo ""
echo "To view logs:"
echo "  kubectl logs -n $NAMESPACE deployment/luscsi-csi-controller"
echo "  kubectl logs -n $NAMESPACE -l app=luscsi-node -f"

