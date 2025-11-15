#!/bin/bash

# 部署所有 CRM 微服务到 Kubernetes
# 使用统一的配置文件 crm-services.yaml

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== 部署 BANTU CRM 微服务到 Kubernetes ==="
echo ""

# 检查 MySQL 是否运行
echo "检查 MySQL 状态..."
MYSQL_POD=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -z "$MYSQL_POD" ]; then
    echo "❌ 错误: 未找到 MySQL Pod，请先部署 MySQL"
    echo "运行: ./deploy-mysql.sh"
    exit 1
fi

echo "✅ MySQL Pod: $MYSQL_POD"
kubectl wait --for=condition=ready pod "$MYSQL_POD" --timeout=60s 2>/dev/null || true

# 检查 MySQL Secret
if ! kubectl get secret mysql-secret >/dev/null 2>&1; then
    echo "❌ 错误: 未找到 mysql-secret"
    exit 1
fi

# 检查配置文件
if [ ! -f "crm-deployments.yaml" ] || [ ! -f "crm-services.yaml" ]; then
    echo "❌ 错误: 未找到部署配置文件"
    echo "需要文件: crm-deployments.yaml, crm-services.yaml"
    exit 1
fi

echo ""
echo "部署所有微服务..."
echo "1. 部署 Deployments..."
kubectl apply -f crm-deployments.yaml

echo "2. 部署 Services..."
kubectl apply -f crm-services.yaml

echo ""
echo "等待服务启动..."
sleep 10

# 检查部署状态
echo ""
echo "=== 部署状态 ==="
kubectl get deployments -l 'service in (gateway,foundation,business,workflow,finance)'
kubectl get svc -l 'service in (gateway,foundation,business,workflow,finance)'

echo ""
echo "=== 服务访问信息 ==="
echo "Gateway (集群内): http://crm-gateway:8080"
echo "Foundation Service: http://crm-foundation-service:8081"
echo "Business Service: http://crm-business-service:8082"
echo "Workflow Service: http://crm-workflow-service:8083"
echo "Finance Service: http://crm-finance-service:8084"
echo ""
echo "端口转发到本地:"
echo "  kubectl port-forward svc/crm-gateway 8080:8080"
echo "  然后访问: http://localhost:8080"

