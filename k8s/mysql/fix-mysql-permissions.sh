#!/bin/bash
# ============================================================
# 修复 MySQL 用户权限，允许所有 IP 访问
# ============================================================

set -e

echo "=== 修复 MySQL 用户权限 ==="
echo ""

# 获取 MySQL Pod
MYSQL_POD=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}')
if [ -z "$MYSQL_POD" ]; then
    echo "❌ 错误: 未找到 MySQL Pod"
    exit 1
fi

echo "✅ MySQL Pod: $MYSQL_POD"

# 获取密码（如果 Secret 是 base64 编码的，需要解码；如果是 stringData，直接读取）
MYSQL_ROOT_PASSWORD=$(kubectl get secret mysql-secret -o jsonpath='{.data.MYSQL_ROOT_PASSWORD}' 2>/dev/null | base64 -d 2>/dev/null || kubectl get secret mysql-secret -o jsonpath='{.stringData.MYSQL_ROOT_PASSWORD}' 2>/dev/null || echo "bantu_root_password_2024")
MYSQL_USER_PASSWORD=$(kubectl get secret mysql-secret -o jsonpath='{.data.MYSQL_PASSWORD}' 2>/dev/null | base64 -d 2>/dev/null || kubectl get secret mysql-secret -o jsonpath='{.stringData.MYSQL_PASSWORD}' 2>/dev/null || echo "bantu_user_password_2024")

echo ""
echo "修复用户权限..."

# 删除可能存在的旧用户
kubectl exec "$MYSQL_POD" -- mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "
DROP USER IF EXISTS 'bantu_user'@'localhost';
DROP USER IF EXISTS 'bantu_user'@'127.0.0.1';
DROP USER IF EXISTS 'bantu_user'@'10.%';
" 2>/dev/null || true

# 创建/更新用户，允许从任何 IP 访问
kubectl exec "$MYSQL_POD" -- mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "
-- 创建 bantu_user 用户（允许从任何 IP 访问）
CREATE USER IF NOT EXISTS 'bantu_user'@'%' IDENTIFIED BY '$MYSQL_USER_PASSWORD';
GRANT ALL PRIVILEGES ON bantu_crm.* TO 'bantu_user'@'%' WITH GRANT OPTION;

-- 创建 root 用户（允许从任何 IP 访问，用于管理）
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- 刷新权限
FLUSH PRIVILEGES;
" 2>&1 | grep -v "Warning" || true

echo ""
echo "验证用户权限..."

# 验证用户
kubectl exec "$MYSQL_POD" -- mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "
SELECT user, host FROM mysql.user WHERE user IN ('bantu_user', 'root') ORDER BY user, host;
" 2>&1 | grep -v "Warning" | grep -E "user|bantu_user|root|%|localhost"

echo ""
echo "验证连接..."

# 测试连接
kubectl exec "$MYSQL_POD" -- mysql -ubantu_user -p"$MYSQL_USER_PASSWORD" -h mysql bantu_crm -e "SELECT 1 as test;" 2>&1 | grep -v "Warning" | grep -E "test|1" || echo "⚠️  连接测试失败"

echo ""
echo "=== 修复完成 ==="
echo ""
echo "📋 用户权限:"
echo "   - bantu_user@% : 允许从任何 IP 访问 bantu_crm 数据库"
echo "   - root@% : 允许从任何 IP 访问所有数据库（管理用）"
echo ""
echo "🔄 重启服务以应用更改:"
echo "   kubectl delete pod -l service=foundation"
echo "   kubectl delete pod -l service=service-management"
echo "   kubectl delete pod -l service=analytics-monitoring"
echo "   kubectl delete pod -l service=order-workflow"

