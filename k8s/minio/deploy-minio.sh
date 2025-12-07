#!/bin/bash

# MinIO 部署脚本
# 用于在 Kubernetes 集群中部署 MinIO 对象存储服务

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "部署 MinIO 到 Kubernetes 集群"
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
MINIO_DATA_DIR="/home/bantu/bantu-data/minio"
if [ ! -d "$MINIO_DATA_DIR" ]; then
    echo "📁 创建 MinIO 数据目录: $MINIO_DATA_DIR"
    sudo mkdir -p "$MINIO_DATA_DIR"
    sudo chmod 777 "$MINIO_DATA_DIR"
else
    echo "✅ MinIO 数据目录已存在: $MINIO_DATA_DIR"
fi
echo ""

# 部署顺序
echo "1. 创建 PV..."
# 检查 PV 是否已存在
if kubectl get pv minio-pv &> /dev/null; then
    echo "   ⚠️  PV minio-pv 已存在，跳过创建"
else
    # 更新 PV 中的节点名称
    sed "s/srv903230.hstgr.cloud/$NODE_NAME/g" minio-pv.yaml | kubectl apply -f -
    echo "   ✅ PV 创建完成"
fi

echo "2. 创建 Secret..."
kubectl apply -f minio-secret.yaml

echo "3. 创建 ConfigMap..."
kubectl apply -f minio-configmap.yaml

echo "4. 创建 PVC..."
kubectl apply -f minio-pvc.yaml

# 等待 PVC 绑定
echo "   等待 PVC 绑定..."
sleep 3
if kubectl get pvc minio-pvc | grep -q Bound; then
    echo "   ✅ PVC 已绑定"
else
    echo "   ⚠️  PVC 未绑定，请检查 PV 状态"
    kubectl get pv,pvc
fi

echo "5. 创建 Deployment..."
kubectl apply -f minio-deployment.yaml

echo "6. 创建 Service..."
kubectl apply -f minio-service.yaml

echo "7. 创建 Console Service..."
kubectl apply -f minio-console-service.yaml

echo ""
echo "=========================================="
echo "等待 MinIO Pod 启动..."
echo "=========================================="

# 等待 Pod 就绪
kubectl wait --for=condition=ready pod -l app=minio --timeout=120s || {
    echo "⚠️  警告: Pod 启动超时，请检查状态"
    kubectl get pods -l app=minio
    exit 1
}

echo ""
echo "=========================================="
echo "✅ MinIO 部署完成！"
echo "=========================================="
echo ""
echo "📊 查看状态:"
echo "   kubectl get pods -l app=minio"
echo "   kubectl get svc minio minio-console"
echo "   kubectl get pvc minio-pvc"
echo ""
echo "🔍 查看日志:"
echo "   kubectl logs -l app=minio"
echo ""
echo "🌐 访问信息:"
echo "   API 地址: http://minio.default.svc.cluster.local:9000"
echo "   Console 地址: http://minio-console.default.svc.cluster.local:9001"
echo "   访问密钥: bantu_minio_admin"
echo "   秘密密钥: bantu_minio_password_2024"
echo ""
echo "📝 本地端口转发（访问 Console）:"
echo "   kubectl port-forward svc/minio-console 9001:9001"
echo "   然后访问: http://localhost:9001"
echo ""

