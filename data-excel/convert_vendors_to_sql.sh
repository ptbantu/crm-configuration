#!/bin/bash

# 将 Vendors.xlsx 转换为 SQL 的辅助脚本
# 如果无法使用 Python，可以手动查看 Excel 并编辑 SQL

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

EXCEL_FILE="Vendors.xlsx"
OUTPUT_SQL="../sql/vendors_seed_data.sql"

echo "=== 供应商 Excel 转 SQL 工具 ==="
echo ""

# 检查 Excel 文件
if [ ! -f "$EXCEL_FILE" ]; then
    echo "❌ 错误: 未找到 $EXCEL_FILE"
    exit 1
fi

echo "📄 Excel 文件: $EXCEL_FILE"
echo ""

# 尝试使用 Python 脚本
if python3 -c "import openpyxl" 2>/dev/null; then
    echo "✅ 检测到 openpyxl，使用 Python 脚本生成 SQL..."
    python3 read_vendors.py "$EXCEL_FILE"
    
    if [ -f "vendors_seed_data.sql" ]; then
        mv vendors_seed_data.sql "$OUTPUT_SQL"
        echo ""
        echo "✅ SQL 文件已生成: $OUTPUT_SQL"
        exit 0
    fi
fi

# 如果 Python 不可用，提供手动指导
echo "⚠️  无法使用 Python 脚本（需要安装 openpyxl）"
echo ""
echo "请选择以下方式之一："
echo ""
echo "方式一：安装 openpyxl 后使用 Python 脚本"
echo "  1. 安装: pip install openpyxl 或 python3 -m pip install openpyxl"
echo "  2. 运行: python3 read_vendors.py $EXCEL_FILE"
echo ""
echo "方式二：手动创建 SQL"
echo "  1. 打开 $EXCEL_FILE 文件"
echo "  2. 查看数据列和内容"
echo "  3. 参考 $OUTPUT_SQL 中的模板"
echo "  4. 手动创建 INSERT 语句"
echo ""
echo "方式三：使用在线工具"
echo "  1. 将 Excel 转换为 CSV"
echo "  2. 使用文本编辑器查看 CSV"
echo "  3. 根据 CSV 数据创建 SQL"
echo ""

# 尝试使用 unzip 读取 Excel 内容（Excel 是 ZIP 文件）
echo "尝试读取 Excel 文件内容..."
if command -v unzip &> /dev/null; then
    echo "使用 unzip 提取 Excel 内容..."
    TEMP_DIR=$(mktemp -d)
    unzip -q "$EXCEL_FILE" -d "$TEMP_DIR" 2>/dev/null || true
    
    if [ -f "$TEMP_DIR/xl/sharedStrings.xml" ]; then
        echo "✅ 成功读取 Excel 内容"
        echo ""
        echo "Excel 文件中的文本内容（前20个）："
        grep -oP '<t[^>]*>.*?</t>' "$TEMP_DIR/xl/sharedStrings.xml" 2>/dev/null | \
            sed 's/<[^>]*>//g' | head -20 | nl
        echo ""
        echo "请根据以上内容手动创建 SQL 语句"
    fi
    
    rm -rf "$TEMP_DIR"
fi

echo ""
echo "📝 SQL 模板位置: $OUTPUT_SQL"
echo "   请参考模板手动创建供应商组织数据"

