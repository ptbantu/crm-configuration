#!/bin/bash

# 部署 Metabase 到 Kubernetes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "部署 Metabase 到 Kubernetes"
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

# 获取节点名称
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
echo "📌 检测到节点: $NODE_NAME"

# 更新 PV 中的节点名称
sed -i "s/srv903230.hstgr.cloud/$NODE_NAME/g" metabase-pv.yaml

# 创建数据目录
echo "创建 Metabase 数据目录..."
sudo mkdir -p /home/bantu/bantu-data/metabase
sudo chmod -R 777 /home/bantu/bantu-data/metabase
echo "✅ Metabase 数据目录已创建: /home/bantu/bantu-data/metabase"
echo ""

# 部署步骤
echo "1. 创建 PV..."
kubectl apply -f metabase-pv.yaml
echo "   ✅ PV 创建完成"

echo "2. 创建 ConfigMap..."
kubectl apply -f metabase-configmap.yaml

echo "3. 创建 PVC..."
kubectl apply -f metabase-pvc.yaml
echo "   等待 PVC 绑定..."
kubectl wait --for=condition=Bound pvc/metabase-pvc --timeout=60s || true
echo "   ✅ PVC 已绑定"

echo "4. 创建 Deployment..."
kubectl apply -f metabase-deployment.yaml

echo "5. 创建 Service..."
kubectl apply -f metabase-service.yaml

echo ""
echo "=========================================="
echo "等待 Metabase Pod 启动..."
echo "=========================================="
kubectl wait --for=condition=ready pod -l app=metabase --timeout=300s || {
    echo "⚠️  Pod 启动超时，查看日志:"
    kubectl logs -l app=metabase --tail=50
    exit 1
}

METABASE_POD=$(kubectl get pods -l app=metabase -o jsonpath='{.items[0].metadata.name}')
echo "✅ Metabase Pod: $METABASE_POD"
echo ""

echo "=========================================="
echo "✅ Metabase 部署完成！"
echo "=========================================="
echo ""

echo "📊 查看状态:"
echo "   kubectl get pods -l app=metabase"
echo "   kubectl get svc metabase"
echo "   kubectl get pvc metabase-pvc"
echo ""

echo "🔍 查看日志:"
echo "   kubectl logs -f $METABASE_POD"
echo ""

echo "🌐 访问信息:"
echo "   集群内访问: http://metabase:3000"
echo "   本地访问: kubectl port-forward svc/metabase 3000:3000"
echo "   然后访问: http://localhost:3000"
echo ""
echo "📝 首次访问需要设置管理员账户"
echo ""

