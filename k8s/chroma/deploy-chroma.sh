#!/bin/bash

# 部署 Chroma 向量数据库到 Kubernetes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "部署 Chroma 向量数据库到 Kubernetes"
echo "=========================================="
echo ""

# 检查 kubectl 是否可用
if ! command -v kubectl &> /dev/null; then
    echo "❌ 错误: kubectl 未安装或不在 PATH 中"
    exit 1
fi

# 检查集群连接
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ 错误: 无法连接到 Kubernetes 集群"
    exit 1
fi

echo "✅ Kubernetes 集群连接正常"
echo ""

# 获取节点名称
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
echo "📌 检测到节点: $NODE_NAME"

# 更新 PV 中的节点名称
sed -i "s/srv903230.hstgr.cloud/$NODE_NAME/g" chroma-pv.yaml

# 创建数据目录
echo "创建 Chroma 数据目录..."
sudo mkdir -p /home/bantu/bantu-data/chroma
sudo chmod -R 777 /home/bantu/bantu-data/chroma
echo "✅ Chroma 数据目录已创建: /home/bantu/bantu-data/chroma"
echo ""

# 部署步骤
echo "1. 创建 PV..."
kubectl apply -f chroma-pv.yaml
echo "   ✅ PV 创建完成"

echo "2. 创建 ConfigMap..."
kubectl apply -f chroma-configmap.yaml

echo "3. 创建 PVC..."
kubectl apply -f chroma-pvc.yaml
echo "   等待 PVC 绑定..."
kubectl wait --for=condition=Bound pvc/chroma-pvc --timeout=60s || true
echo "   ✅ PVC 已绑定"

echo "4. 创建 Deployment..."
kubectl apply -f chroma-deployment.yaml

echo "5. 创建 Service..."
kubectl apply -f chroma-service.yaml

echo ""
echo "=========================================="
echo "等待 Chroma Pod 启动..."
echo "=========================================="
kubectl wait --for=condition=ready pod -l app=chroma --timeout=300s || {
    echo "⚠️  Pod 启动超时，查看日志:"
    kubectl logs -l app=chroma --tail=50
    exit 1
}

CHROMA_POD=$(kubectl get pods -l app=chroma -o jsonpath='{.items[0].metadata.name}')
echo "✅ Chroma Pod: $CHROMA_POD"
echo ""

echo "=========================================="
echo "✅ Chroma 部署完成！"
echo "=========================================="
echo ""

echo "📊 查看状态:"
echo "   kubectl get pods -l app=chroma"
echo "   kubectl get svc chroma"
echo "   kubectl get pvc chroma-pvc"
echo ""

echo "🔍 查看日志:"
echo "   kubectl logs -f $CHROMA_POD"
echo ""

echo "🌐 访问信息:"
echo "   集群内访问: http://chroma:8000"
echo "   API 端点: http://chroma.default.svc.cluster.local:8000"
echo "   本地访问: kubectl port-forward svc/chroma 8000:8000"
echo "   然后访问: http://localhost:8000"
echo ""

echo "📝 Python 客户端连接示例:"
echo "   from chromadb import HttpClient"
echo "   client = HttpClient(host='chroma', port=8000)"
echo ""

