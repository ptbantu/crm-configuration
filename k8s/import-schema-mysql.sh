#!/bin/bash

# 清空数据库并导入新的 schema_unified.sql 到 MySQL

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SQL_FILE="$PROJECT_ROOT/sql/schema_unified.sql"

echo "=== 清空数据库并导入 schema_unified.sql 到 MySQL ==="

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

# 清空数据库：删除所有表
echo ""
echo "⚠️  警告: 即将清空数据库 $DB_NAME 中的所有表！"
echo "按 Ctrl+C 取消，或等待 5 秒后继续..."
sleep 5

echo "开始清空数据库..."

# 检查是否有表
TABLE_COUNT=$(kubectl exec "$MYSQL_POD" -- mysql -uroot -p"$ROOT_PASS" "$DB_NAME" -sN -e "
SELECT COUNT(*) 
FROM information_schema.tables
WHERE table_schema = '$DB_NAME'
AND table_type = 'BASE TABLE';
" 2>/dev/null || echo "0")

if [ "$TABLE_COUNT" -gt 0 ]; then
    echo "发现 $TABLE_COUNT 个表，开始删除..."
    # 生成删除所有表的 SQL 语句
    kubectl exec "$MYSQL_POD" -- mysql -uroot -p"$ROOT_PASS" "$DB_NAME" -e "
    SET FOREIGN_KEY_CHECKS = 0;
    SET @tables = NULL;
    SELECT GROUP_CONCAT('\`', table_name, '\`') INTO @tables
    FROM information_schema.tables
    WHERE table_schema = '$DB_NAME'
    AND table_type = 'BASE TABLE';
    SET @tables = CONCAT('DROP TABLE IF EXISTS ', @tables);
    PREPARE stmt FROM @tables;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET FOREIGN_KEY_CHECKS = 1;
    " 2>&1 | grep -v "Warning" || true
    echo "✅ 所有表已删除"
else
    echo "ℹ️  数据库为空，无需清空表"
fi

# 删除所有视图
VIEW_COUNT=$(kubectl exec "$MYSQL_POD" -- mysql -uroot -p"$ROOT_PASS" "$DB_NAME" -sN -e "
SELECT COUNT(*) 
FROM information_schema.views
WHERE table_schema = '$DB_NAME';
" 2>/dev/null || echo "0")

if [ "$VIEW_COUNT" -gt 0 ]; then
    echo "发现 $VIEW_COUNT 个视图，开始删除..."
    kubectl exec "$MYSQL_POD" -- mysql -uroot -p"$ROOT_PASS" "$DB_NAME" -e "
    SET @views = NULL;
    SELECT GROUP_CONCAT('\`', table_name, '\`') INTO @views
    FROM information_schema.views
    WHERE table_schema = '$DB_NAME';
    SET @views = CONCAT('DROP VIEW IF EXISTS ', @views);
    PREPARE stmt FROM @views;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    " 2>&1 | grep -v "Warning" || true
    echo "✅ 所有视图已删除"
fi

echo ""
echo "开始导入 schema_unified.sql..."

# 导入 SQL
# 使用 root 用户导入以确保触发器可以创建（需要 SUPER 权限）
# 使用 --force 忽略重复索引等错误，确保幂等性
kubectl exec -i "$MYSQL_POD" -- mysql -uroot -p"$ROOT_PASS" "$DB_NAME" --force < "$SQL_FILE" 2>&1 | grep -v "Warning\|Duplicate key\|already exists" || true

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Schema 导入成功！"
    echo ""
    echo "验证导入:"
    echo "  查看所有表:"
    echo "    kubectl exec -it $MYSQL_POD -- mysql -u$DB_USER -p$DB_PASS $DB_NAME -e 'SHOW TABLES;'"
    echo ""
    echo "  查看表数量:"
    kubectl exec "$MYSQL_POD" -- mysql -u$DB_USER -p$DB_PASS "$DB_NAME" -e "
    SELECT COUNT(*) as table_count 
    FROM information_schema.tables 
    WHERE table_schema = '$DB_NAME' 
    AND table_type = 'BASE TABLE';
    " 2>/dev/null || true
    echo ""
    echo "  查看 users 表结构:"
    echo "    kubectl exec -it $MYSQL_POD -- mysql -u$DB_USER -p$DB_PASS $DB_NAME -e 'DESCRIBE users;'"
else
    echo ""
    echo "❌ Schema 导入失败"
    exit 1
fi
