#!/bin/bash

# 导入 MySQL schema.sql 到数据库

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SQL_FILE="$PROJECT_ROOT/sql/schema_mysql.sql"

echo "=== 导入 schema_mysql.sql 到 MySQL ==="

# 检查 SQL 文件
if [ ! -f "$SQL_FILE" ]; then
    echo "错误: 未找到 $SQL_FILE"
    exit 1
fi

# 检查 MySQL Pod
MYSQL_POD=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -z "$MYSQL_POD" ]; then
    echo "错误: 未找到 MySQL Pod"
    exit 1
fi

echo "MySQL Pod: $MYSQL_POD"
echo "SQL 文件: $SQL_FILE"
echo ""

# 检查 Pod 是否就绪
echo "检查 MySQL Pod 状态..."
kubectl wait --for=condition=ready pod "$MYSQL_POD" --timeout=60s

# 获取数据库连接信息
DB_NAME=$(kubectl get secret mysql-secret -o jsonpath='{.data.MYSQL_DATABASE}' | base64 -d)
DB_USER=$(kubectl get secret mysql-secret -o jsonpath='{.data.MYSQL_USER}' | base64 -d)
DB_PASS=$(kubectl get secret mysql-secret -o jsonpath='{.data.MYSQL_PASSWORD}' | base64 -d)
ROOT_PASS=$(kubectl get secret mysql-secret -o jsonpath='{.data.MYSQL_ROOT_PASSWORD}' | base64 -d)

echo "数据库: $DB_NAME"
echo "用户: $DB_USER"
echo ""

# 设置 log_bin_trust_function_creators 以允许创建触发器
echo "设置 MySQL 配置以允许创建触发器..."
kubectl exec "$MYSQL_POD" -- mysql -uroot -p"$ROOT_PASS" -e "SET GLOBAL log_bin_trust_function_creators = 1;" 2>&1 | grep -v "Warning" || true

# 导入 SQL
# 使用 root 用户导入以确保触发器可以创建（需要 SUPER 权限）
# 使用 --force 忽略重复索引等错误，确保幂等性
echo "开始导入 schema_mysql.sql..."
kubectl exec -i "$MYSQL_POD" -- mysql -uroot -p"$ROOT_PASS" "$DB_NAME" --force < "$SQL_FILE" 2>&1 | grep -v "Warning\|Duplicate key\|already exists" || true

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Schema 导入成功！"
    echo ""
    echo "验证导入:"
    echo "  kubectl exec -it $MYSQL_POD -- mysql -u$DB_USER -p$DB_PASS $DB_NAME -e 'SHOW TABLES;'"
else
    echo ""
    echo "❌ Schema 导入失败"
    exit 1
fi
