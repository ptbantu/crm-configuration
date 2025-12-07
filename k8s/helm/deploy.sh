#!/bin/bash

# BANTU CRM Helm Chart 部署脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_DIR="$SCRIPT_DIR/bantu-crm"

echo "=========================================="
echo "BANTU CRM Helm Chart 部署"
echo "=========================================="
echo ""

# 检查 Helm 是否安装
if ! command -v helm &> /dev/null; then
    echo "❌ 错误: Helm 未安装"
    echo "请先安装 Helm: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
    exit 1
fi

echo "✅ Helm 版本: $(helm version --short)"
echo ""

# 检查 Chart 目录
if [ ! -d "$CHART_DIR" ]; then
    echo "❌ 错误: Chart 目录不存在: $CHART_DIR"
    exit 1
fi

# 检查 values.yaml
if [ ! -f "$CHART_DIR/values.yaml" ]; then
    echo "❌ 错误: values.yaml 不存在"
    exit 1
fi

# 获取节点名称（用于 local-storage）
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "srv903230.hstgr.cloud")
echo "📌 检测到节点: $NODE_NAME"

# 创建数据目录
echo "创建数据目录..."
sudo mkdir -p /home/bantu/bantu-data/{mysql,redis,minio,mongodb,chroma,metabase}
sudo chmod -R 777 /home/bantu/bantu-data
echo "✅ 数据目录已创建"
echo ""

# 更新 values.yaml 中的节点名称（如果需要）
if grep -q "srv903230.hstgr.cloud" "$CHART_DIR/values.yaml" 2>/dev/null; then
    echo "更新节点名称..."
    sed -i "s/srv903230.hstgr.cloud/$NODE_NAME/g" "$CHART_DIR/values.yaml" || true
fi

# 检查是否已安装
RELEASE_NAME="bantu-crm"
if helm list -q | grep -q "^${RELEASE_NAME}$"; then
    echo "⚠️  检测到已安装的 Release: $RELEASE_NAME"
    read -p "是否升级现有部署? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "升级部署..."
        helm upgrade $RELEASE_NAME $CHART_DIR
        echo ""
        echo "✅ 升级完成！"
    else
        echo "取消操作"
        exit 0
    fi
else
    echo "安装 Chart..."
    helm install $RELEASE_NAME $CHART_DIR
    echo ""
    echo "✅ 安装完成！"
fi

echo ""
echo "=========================================="
echo "部署状态"
echo "=========================================="
helm status $RELEASE_NAME

echo ""
echo "=========================================="
echo "查看资源"
echo "=========================================="
echo "Pod 状态:"
kubectl get pods -l app.kubernetes.io/instance=$RELEASE_NAME

echo ""
echo "Service 状态:"
kubectl get svc -l app.kubernetes.io/instance=$RELEASE_NAME

echo ""
echo "=========================================="
echo "访问信息"
echo "=========================================="
echo "MySQL: mysql.default.svc.cluster.local:3306"
echo "Redis: redis.default.svc.cluster.local:6379"
echo "MinIO: minio.default.svc.cluster.local:9000"
echo "MongoDB: mongodb.default.svc.cluster.local:27017"
echo "Chroma: chroma.default.svc.cluster.local:8000"
echo "Metabase: metabase.default.svc.cluster.local:3000"
echo "Activiti Cloud: activiti-cloud.default.svc.cluster.local:8080"
echo ""

