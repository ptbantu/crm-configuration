#!/bin/bash
set -e

echo "=========================================="
echo "部署 Jenkins 到 Kubernetes 集群"
echo "=========================================="

# 检查 kubectl 连接
if ! kubectl cluster-info &>/dev/null; then
  echo "❌ 错误: 无法连接到 Kubernetes 集群"
  exit 1
fi

echo "✅ Kubernetes 集群连接正常"

# 获取节点名
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -z "$NODE_NAME" ]; then
  echo "❌ 错误: 无法获取节点名"
  exit 1
fi

echo "📌 检测到节点: $NODE_NAME"

# 创建数据目录
echo "📁 创建 Jenkins 数据目录: /home/bantu/bantu-data/jenkins"
mkdir -p /home/bantu/bantu-data/jenkins
chmod 777 /home/bantu/bantu-data/jenkins

# 更新 PV 配置中的节点名
sed -i "s/- izk1ab8tuh7ud5hce3z4y7z/- $NODE_NAME/" jenkins-pv.yaml

echo ""
echo "1. 创建 PV..."
kubectl apply -f jenkins-pv.yaml
echo "   ✅ PV 创建完成"

echo ""
echo "2. 创建 PVC..."
kubectl apply -f jenkins-pvc.yaml
echo "   等待 PVC 绑定..."
kubectl wait --for=condition=Bound pvc/jenkins-pvc --timeout=30s || true
echo "   ✅ PVC 已绑定"

echo ""
echo "3. 创建 Deployment..."
kubectl apply -f jenkins-deployment.yaml

echo ""
echo "4. 创建 Service..."
kubectl apply -f jenkins-service.yaml

echo ""
echo "5. 创建 Ingress..."
kubectl apply -f jenkins-ingress.yaml

echo ""
echo "=========================================="
echo "等待 Jenkins Pod 启动..."
echo "=========================================="
kubectl wait --for=condition=ready pod -l app=jenkins --timeout=300s || echo "⚠️  警告: Pod 可能仍在启动中"

echo ""
echo "=========================================="
echo "✅ Jenkins 部署完成！"
echo "=========================================="

echo ""
echo "📊 查看状态:"
echo "   kubectl get pods -l app=jenkins"
echo "   kubectl get svc jenkins"
echo "   kubectl get ingress jenkins-ingress"

echo ""
echo "🔍 查看日志:"
echo "   kubectl logs -l app=jenkins"

echo ""
echo "🔑 获取初始管理员密码:"
echo "   kubectl exec -it \$(kubectl get pod -l app=jenkins -o jsonpath='{.items[0].metadata.name}') -- cat /var/jenkins_home/secrets/initialAdminPassword"

echo ""
echo "📝 访问信息:"
echo "   集群内: http://jenkins:8080"
echo "   外部访问: http://www.bantuqifu.xin/jenkins"
echo "   或使用端口转发: kubectl port-forward svc/jenkins 8080:8080"

