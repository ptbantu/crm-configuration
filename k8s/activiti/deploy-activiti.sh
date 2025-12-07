#!/bin/bash

# 部署 Activiti Spring Boot 到 Kubernetes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== 部署 Activiti Spring Boot ==="
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

# 应用 ConfigMap
echo ""
echo "创建 ConfigMap..."
kubectl apply -f activiti-configmap.yaml

# 应用 Deployment
echo "创建 Deployment..."
kubectl apply -f activiti-deployment.yaml

# 应用 Service
echo "创建 Service..."
kubectl apply -f activiti-service.yaml

# 等待 Pod 就绪
echo ""
echo "等待 Activiti Pod 启动..."
kubectl wait --for=condition=ready pod -l app=activiti --timeout=300s || {
    echo "⚠️  Pod 启动超时，查看日志:"
    kubectl logs -l app=activiti --tail=50
    exit 1
}

ACTIVITI_POD=$(kubectl get pods -l app=activiti -o jsonpath='{.items[0].metadata.name}')
echo "✅ Activiti Pod: $ACTIVITI_POD"

# 显示状态
echo ""
echo "=== 部署状态 ==="
kubectl get pods -l app=activiti
kubectl get svc activiti

echo ""
echo "=== 访问信息 ==="
echo "Service: activiti:8080"
echo "在集群内访问: http://activiti:8080/activiti"
echo ""
echo "查看日志:"
echo "  kubectl logs -f $ACTIVITI_POD"
echo ""
echo "端口转发到本地:"
echo "  kubectl port-forward svc/activiti 8080:8080"
echo "  然后访问: http://localhost:8080/activiti"

