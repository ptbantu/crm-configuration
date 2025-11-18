#!/bin/bash

# MongoDB 部署脚本
# 用于在 Kubernetes 集群中部署 MongoDB 数据库

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "部署 MongoDB 到 Kubernetes 集群"
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
MONGODB_DATA_DIR="/home/bantu/bantu-data/mongodb"
if [ ! -d "$MONGODB_DATA_DIR" ]; then
    echo "📁 创建 MongoDB 数据目录: $MONGODB_DATA_DIR"
    sudo mkdir -p "$MONGODB_DATA_DIR"
    sudo chmod 777 "$MONGODB_DATA_DIR"
else
    echo "✅ MongoDB 数据目录已存在: $MONGODB_DATA_DIR"
fi
echo ""

# 部署顺序
echo "1. 创建 PV..."
# 检查 PV 是否已存在
if kubectl get pv mongodb-pv &> /dev/null; then
    echo "   ⚠️  PV mongodb-pv 已存在，跳过创建"
else
    # 更新 PV 中的节点名称
    sed "s/srv903230.hstgr.cloud/$NODE_NAME/g" mongodb-pv.yaml | kubectl apply -f -
    echo "   ✅ PV 创建完成"
fi

echo "2. 创建 Secret..."
kubectl apply -f mongodb-secret.yaml

echo "3. 创建 ConfigMap..."
kubectl apply -f mongodb-configmap.yaml

echo "4. 创建 PVC..."
kubectl apply -f mongodb-pvc.yaml

# 等待 PVC 绑定
echo "   等待 PVC 绑定..."
sleep 3
if kubectl get pvc mongodb-pvc | grep -q Bound; then
    echo "   ✅ PVC 已绑定"
else
    echo "   ⚠️  PVC 未绑定，请检查 PV 状态"
    kubectl get pv,pvc
fi

echo "5. 创建 Deployment..."
kubectl apply -f mongodb-deployment.yaml

echo "6. 创建 Service..."
kubectl apply -f mongodb-service.yaml

echo ""
echo "=========================================="
echo "等待 MongoDB Pod 启动..."
echo "=========================================="

# 等待 Pod 就绪
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=120s || {
    echo "⚠️  警告: Pod 启动超时，请检查状态"
    kubectl get pods -l app=mongodb
    exit 1
}

echo ""
echo "=========================================="
echo "✅ MongoDB 部署完成！"
echo "=========================================="
echo ""
echo "📊 查看状态:"
echo "   kubectl get pods -l app=mongodb"
echo "   kubectl get svc mongodb"
echo "   kubectl get pvc mongodb-pvc"
echo ""
echo "🔍 查看日志:"
echo "   kubectl logs -l app=mongodb"
echo ""
echo "🧪 测试连接:"
echo "   kubectl run -it --rm mongodb-client --image=mongo:7.0 --restart=Never -- mongosh -h mongodb -u bantu_mongo_admin -p bantu_mongo_password_2024 --authenticationDatabase admin"
echo ""
echo "📝 连接信息:"
echo "   服务地址: mongodb.default.svc.cluster.local:27017"
echo "   Root 用户: bantu_mongo_admin / bantu_mongo_password_2024"
echo "   应用用户: bantu_mongo_user / bantu_mongo_user_password_2024"
echo "   数据库: bantu_crm"
echo ""

