#!/bin/bash

# ============================================================
# 导入种子数据到 MySQL 数据库
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 配置
SQL_FILE="../sql/seed_data.sql"
MYSQL_SERVICE="mysql"
MYSQL_DATABASE="bantu_crm"
MYSQL_USER="bantu_user"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "BANTU CRM 种子数据导入"
echo "=========================================="
echo ""

# 检查 SQL 文件是否存在
if [ ! -f "$SQL_FILE" ]; then
    echo -e "${RED}❌ 错误: SQL 文件不存在: $SQL_FILE${NC}"
    exit 1
fi

echo "📄 SQL 文件: $SQL_FILE"
echo ""

# 检查 MySQL Pod 是否存在
echo "检查 MySQL Pod 状态..."
MYSQL_POD=$(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -z "$MYSQL_POD" ]; then
    echo -e "${RED}❌ 错误: 未找到 MySQL Pod${NC}"
    echo "请先部署 MySQL: kubectl apply -f mysql-deployment.yaml"
    exit 1
fi

echo -e "${GREEN}✅ MySQL Pod: $MYSQL_POD${NC}"

# 等待 Pod 就绪
echo "等待 MySQL Pod 就绪..."
kubectl wait --for=condition=ready pod "$MYSQL_POD" --timeout=60s 2>/dev/null || {
    echo -e "${YELLOW}⚠️  警告: Pod 可能未完全就绪，继续尝试...${NC}"
}

# 检查 MySQL Secret
if ! kubectl get secret mysql-secret >/dev/null 2>&1; then
    echo -e "${RED}❌ 错误: 未找到 mysql-secret${NC}"
    exit 1
fi

# 获取 MySQL 密码
MYSQL_PASSWORD=$(kubectl get secret mysql-secret -o jsonpath='{.data.MYSQL_PASSWORD}' | base64 -d)

echo ""
echo "=========================================="
echo "开始导入种子数据"
echo "=========================================="
echo ""

# 导入 SQL 文件
echo "正在导入种子数据..."
if kubectl exec -i "$MYSQL_POD" -- mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < "$SQL_FILE"; then
    echo ""
    echo -e "${GREEN}✅ 种子数据导入成功！${NC}"
else
    echo ""
    echo -e "${RED}❌ 错误: 种子数据导入失败${NC}"
    exit 1
fi

echo ""
echo "=========================================="
echo "验证数据"
echo "=========================================="
echo ""

# 验证 BANTU 组织是否创建成功
echo "检查 BANTU 组织..."
VERIFY_RESULT=$(kubectl exec "$MYSQL_POD" -- mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "
SELECT 
    id,
    name,
    code,
    organization_type,
    is_active,
    is_locked
FROM organizations 
WHERE code = 'BANTU';
" 2>/dev/null)

if echo "$VERIFY_RESULT" | grep -q "BANTU"; then
    echo -e "${GREEN}✅ BANTU 组织创建成功${NC}"
    echo ""
    echo "$VERIFY_RESULT"
else
    echo -e "${YELLOW}⚠️  警告: 未找到 BANTU 组织，请检查导入日志${NC}"
fi

echo ""
echo "=========================================="
echo "完成"
echo "=========================================="
echo ""
echo "📝 下一步："
echo "  1. 可以使用 BANTU 组织 ID 创建用户"
echo "  2. 获取组织 ID: SELECT id FROM organizations WHERE code = 'BANTU';"
echo ""

