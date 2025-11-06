#!/bin/bash
set -e

echo "=== MySQL K8s 部署脚本 ==="

# 获取节点名（第一个节点）
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$NODE_NAME" ]; then
  echo "错误: 无法获取节点名，请确保 kubectl 已配置"
  exit 1
fi

echo "检测到节点名: $NODE_NAME"

# 创建数据目录
mkdir -p /home/bantu/bantu-data/mysql
chmod 777 /home/bantu/bantu-data/mysql  # 确保容器有权限

# 生成带节点名的 PV 配置
cat > /tmp/mysql-pv-generated.yaml <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /home/bantu/bantu-data/mysql
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - "$NODE_NAME"
EOF

echo "正在部署 MySQL..."
kubectl apply -f mysql-secret.yaml
kubectl apply -f /tmp/mysql-pv-generated.yaml
kubectl apply -f mysql-pvc.yaml
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml

echo ""
echo "等待 MySQL Pod 启动..."
kubectl wait --for=condition=ready pod -l app=mysql --timeout=120s || echo "警告: Pod 可能仍在启动中"

echo ""
echo "=== 部署完成 ==="
echo "检查状态:"
kubectl get pv mysql-pv
kubectl get pvc mysql-pvc
kubectl get pods -l app=mysql
kubectl get svc mysql

echo ""
echo "连接信息:"
echo "  Service: mysql.default.svc.cluster.local:3306"
echo "  数据库: bantu_crm"
echo "  Root 用户: root / bantu_root_password_2024"
echo "  应用用户: bantu_user / bantu_user_password_2024"

