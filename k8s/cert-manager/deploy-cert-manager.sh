#!/bin/bash
# ============================================================
# 部署 cert-manager 和 Let's Encrypt ClusterIssuer
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== 部署 cert-manager 和 SSL 证书配置 ==="
echo ""

# 检查是否已安装 cert-manager
if kubectl get namespace cert-manager >/dev/null 2>&1; then
    echo "✅ cert-manager 命名空间已存在"
else
    echo "📦 安装 cert-manager..."
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml
    
    echo "⏳ 等待 cert-manager 就绪..."
    kubectl wait --for=condition=ready pod \
        -l app.kubernetes.io/instance=cert-manager \
        -n cert-manager \
        --timeout=300s || true
fi

# 等待 cert-manager webhook 就绪
echo "⏳ 等待 cert-manager webhook 就绪..."
kubectl wait --for=condition=ready pod \
    -l app.kubernetes.io/name=webhook \
    -n cert-manager \
    --timeout=300s || true

# 检查 ClusterIssuer 是否存在
if kubectl get clusterissuer letsencrypt-prod >/dev/null 2>&1; then
    echo "✅ ClusterIssuer letsencrypt-prod 已存在"
    echo "   如需更新，请先删除: kubectl delete clusterissuer letsencrypt-prod"
else
    echo "📝 创建 Let's Encrypt ClusterIssuer..."
    kubectl apply -f cluster-issuer.yaml
    
    echo "⏳ 等待 ClusterIssuer 就绪..."
    sleep 5
fi

# 验证安装
echo ""
echo "=== 验证安装 ==="
echo "cert-manager Pods:"
kubectl get pods -n cert-manager

echo ""
echo "ClusterIssuers:"
kubectl get clusterissuer

echo ""
echo "=== 部署完成 ==="
echo ""
echo "📋 下一步："
echo "1. 确保域名 www.bantuqifu.xin 的 DNS 已正确解析到服务器 IP"
echo "2. 确保 Ingress 配置中已包含 TLS 配置和 cert-manager 注解"
echo "3. cert-manager 会自动为 Ingress 中的域名申请证书"
echo ""
echo "🔍 检查证书状态:"
echo "   kubectl get certificate"
echo "   kubectl describe certificate bantuqifu-xin-tls-cert"
echo ""
echo "📧 注意：请修改 cluster-issuer.yaml 中的邮箱地址为您的实际邮箱"

