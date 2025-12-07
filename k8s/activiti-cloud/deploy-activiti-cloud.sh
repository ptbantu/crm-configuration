#!/bin/bash

# 部署 Activiti Cloud 7.1.0 到 Kubernetes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "部署 Activiti Cloud 7.1.0 到 Kubernetes"
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

# 检查 MySQL 是否运行
echo "检查 MySQL 状态..."
MYSQL_POD=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -z "$MYSQL_POD" ]; then
    echo "❌ 错误: 未找到 MySQL Pod，请先部署 MySQL"
    exit 1
fi

echo "✅ MySQL Pod: $MYSQL_POD"
kubectl wait --for=condition=ready pod "$MYSQL_POD" --timeout=60s 2>/dev/null || true

# 检查 MySQL Secret
echo "检查 MySQL Secret..."
if ! kubectl get secret mysql-secret >/dev/null 2>&1; then
    echo "❌ 错误: 未找到 mysql-secret，请先部署 MySQL"
    exit 1
fi

echo "✅ MySQL Secret 存在"
echo ""

# 部署步骤
echo "1. 创建 ConfigMap..."
kubectl apply -f activiti-cloud-configmap.yaml

echo "2. 创建 Deployment..."
kubectl apply -f activiti-cloud-deployment.yaml

echo "3. 创建 Service..."
kubectl apply -f activiti-cloud-service.yaml

echo ""
echo "=========================================="
echo "等待 Activiti Cloud Pod 启动..."
echo "=========================================="
kubectl wait --for=condition=ready pod -l app=activiti-cloud --timeout=300s || {
    echo "⚠️  Pod 启动超时，查看日志:"
    kubectl logs -l app=activiti-cloud --tail=50
    exit 1
}

ACTIVITI_POD=$(kubectl get pods -l app=activiti-cloud -o jsonpath='{.items[0].metadata.name}')
echo "✅ Activiti Cloud Pod: $ACTIVITI_POD"
echo ""

echo "=========================================="
echo "✅ Activiti Cloud 部署完成！"
echo "=========================================="
echo ""

echo "📊 查看状态:"
echo "   kubectl get pods -l app=activiti-cloud"
echo "   kubectl get svc activiti-cloud"
echo ""

echo "🔍 查看日志:"
echo "   kubectl logs -f $ACTIVITI_POD"
echo ""

echo "🌐 访问信息:"
echo "   集群内访问: http://activiti-cloud:8080"
echo "   本地访问: kubectl port-forward svc/activiti-cloud 8080:8080"
echo "   然后访问: http://localhost:8080"
echo ""

