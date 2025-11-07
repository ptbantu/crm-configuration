#!/bin/bash

# 生成供应商组织 SQL 的辅助脚本
# 如果无法使用 Python，可以手动编辑此脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== 供应商组织 SQL 生成脚本 ==="
echo ""

# 检查 Python 和 openpyxl
if python3 -c "import openpyxl" 2>/dev/null; then
    echo "✅ openpyxl 已安装"
    python3 read_vendors.py Vendors.xlsx
else
    echo "⚠️  openpyxl 未安装，尝试安装..."
    if python3 -m pip install openpyxl --quiet 2>&1; then
        echo "✅ openpyxl 安装成功"
        python3 read_vendors.py Vendors.xlsx
    else
        echo "❌ 无法安装 openpyxl"
        echo ""
        echo "请手动安装:"
        echo "  python3 -m pip install openpyxl"
        echo "  或"
        echo "  pip install openpyxl"
        echo ""
        echo "然后运行:"
        echo "  python3 read_vendors.py Vendors.xlsx"
        exit 1
    fi
fi

