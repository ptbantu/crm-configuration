#!/bin/bash

# Redis 部署脚本
# 用于在 Kubernetes 集群中部署 Redis

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "部署 Redis 到 Kubernetes 集群"
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

# 创建数据目录（如果不存在）
REDIS_DATA_DIR="/home/bantu/bantu-data/redis"
if [ ! -d "$REDIS_DATA_DIR" ]; then
    echo "📁 创建 Redis 数据目录: $REDIS_DATA_DIR"
    sudo mkdir -p "$REDIS_DATA_DIR"
    sudo chmod 777 "$REDIS_DATA_DIR"
else
    echo "✅ Redis 数据目录已存在: $REDIS_DATA_DIR"
fi
echo ""

# 部署顺序
echo "1. 创建 PV..."
# 检查 PV 是否已存在
if kubectl get pv redis-pv &> /dev/null; then
    echo "   ⚠️  PV redis-pv 已存在，跳过创建"
else
    # 更新 PV 中的节点名称
    sed "s/srv903230.hstgr.cloud/$NODE_NAME/g" redis-pv.yaml | kubectl apply -f -
    echo "   ✅ PV 创建完成"
fi

echo "2. 创建 Secret..."
kubectl apply -f redis-secret.yaml

echo "3. 创建 ConfigMap..."
kubectl apply -f redis-configmap.yaml

echo "4. 创建 PVC..."
kubectl apply -f redis-pvc.yaml

# 等待 PVC 绑定
echo "   等待 PVC 绑定..."
sleep 3
if kubectl get pvc redis-pvc | grep -q Bound; then
    echo "   ✅ PVC 已绑定"
else
    echo "   ⚠️  PVC 未绑定，请检查 PV 状态"
    kubectl get pv,pvc
fi

echo "5. 创建 Deployment..."
kubectl apply -f redis-deployment.yaml

echo "6. 创建 Service..."
kubectl apply -f redis-service.yaml

echo ""
echo "=========================================="
echo "等待 Redis Pod 启动..."
echo "=========================================="

# 等待 Pod 就绪
kubectl wait --for=condition=ready pod -l app=redis --timeout=120s || {
    echo "⚠️  警告: Pod 启动超时，请检查状态"
    kubectl get pods -l app=redis
    exit 1
}

echo ""
echo "=========================================="
echo "✅ Redis 部署完成！"
echo "=========================================="
echo ""
echo "📊 查看状态:"
echo "   kubectl get pods -l app=redis"
echo "   kubectl get svc redis"
echo "   kubectl get pvc redis-pvc"
echo ""
echo "🔍 查看日志:"
echo "   kubectl logs -l app=redis"
echo ""
echo "🧪 测试连接:"
echo "   kubectl run -it --rm redis-client --image=redis:7.2-alpine --restart=Never -- redis-cli -h redis -a bantu_redis_password_2024 ping"
echo ""
echo "📝 连接信息:"
echo "   服务地址: redis.default.svc.cluster.local:6379"
echo "   密码: bantu_redis_password_2024"
echo ""

