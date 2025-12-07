# Excel 数据导入说明

## 文件说明

- `Vendors.xlsx` - 供应商数据 Excel 文件
- `read_vendors.py` - Python 脚本，用于读取 Excel 并生成 SQL
- `generate_vendors_sql.sh` - 辅助脚本，自动安装依赖并运行 Python 脚本

## 使用方法

### 方式一：使用 Python 脚本自动生成（推荐）

#### 1. 安装依赖

```bash
# 安装 openpyxl
pip install openpyxl
# 或
python3 -m pip install openpyxl
```

#### 2. 运行脚本

```bash
cd /home/bantu/crm-configuration/data-excel
python3 read_vendors.py Vendors.xlsx
```

脚本会自动：
- 读取 Excel 文件
- 识别表头和数据
- 生成 `vendors_seed_data.sql` 文件

#### 3. 导入数据库

```bash
mysql -u user -p database < vendors_seed_data.sql
```

或使用 K8s 导入脚本：

```bash
cd /home/bantu/crm-configuration/k8s
# 修改 import-seed-data.sh 以支持供应商数据
```

### 方式二：手动创建 SQL

如果无法使用 Python 脚本，可以：

1. 打开 `Vendors.xlsx` 文件
2. 查看数据列名和内容
3. 参考 `/home/bantu/crm-configuration/sql/vendors_seed_data.sql` 中的示例
4. 手动创建 INSERT 语句

## Excel 文件结构要求

脚本期望 Excel 文件包含以下列（列名不区分大小写）：

- **Name** / **name** - 供应商名称（必填）
- **Code** / **code** - 供应商编码（可选，会自动生成）
- **Email** / **email** / **Email Address** - 邮箱
- **Phone** / **phone** / **Phone Number** - 电话
- **Website** / **website** / **Web** - 网站
- **Description** / **description** / **Notes** - 描述
- **Street** / **street** / **Address** - 街道地址
- **City** / **city** - 城市
- **State** / **state** / **Province** - 省/州
- **Postal** / **postal** / **Postal Code** - 邮编
- **Country** / **country** - 国家（默认：中国）
- **Country Code** / **country_code** - 国家代码（默认：CN）

## 生成的 SQL 文件

生成的 SQL 文件包含：

- 每个供应商的 INSERT 语句
- 使用 `INSERT IGNORE` 避免重复插入
- 自动生成组织编码（如果 Excel 中没有）
- 设置 `organization_type = 'vendor'`
- 设置 `parent_id = NULL`（供应商是独立组织）

## 字段映射

Excel 列 → 数据库字段：

| Excel 列 | 数据库字段 | 说明 |
|---------|-----------|------|
| Name | name | 组织名称 |
| Code | code | 组织编码（唯一） |
| Email | email | 邮箱 |
| Phone | phone | 电话 |
| Website | website | 网站 |
| Description | description | 描述 |
| Street/Address | street | 街道地址 |
| City | city | 城市 |
| State/Province | state_province | 省/州 |
| Postal Code | postal_code | 邮编 |
| Country | country | 国家 |
| Country Code | country_code | 国家代码 |

## 默认值

如果 Excel 中没有某些字段，脚本会使用以下默认值：

- `organization_type`: 'vendor'
- `parent_id`: NULL
- `company_size`: 'medium'
- `company_nature`: 'private'
- `company_type`: 'limited'
- `is_active`: TRUE
- `is_locked`: FALSE
- `country`: '中国'（如果未提供）
- `country_code`: 'CN'（如果未提供）

## 验证数据

导入后验证：

```sql
-- 查看所有供应商
SELECT 
    id,
    name,
    code,
    organization_type,
    email,
    phone,
    city,
    country,
    is_active
FROM organizations 
WHERE organization_type = 'vendor'
ORDER BY created_at;
```

## 注意事项

1. **组织编码唯一性**：确保每个供应商的 `code` 字段唯一
2. **可重复执行**：使用 `INSERT IGNORE` 可以安全地重复执行
3. **字段映射**：如果 Excel 列名不同，需要修改 `read_vendors.py` 中的字段映射
4. **数据完整性**：建议在导入前检查 Excel 数据的完整性

## 扩展

如果需要添加更多字段（如工商信息、财务信息等），可以：

1. 在 Excel 中添加对应列
2. 修改 `read_vendors.py` 脚本添加字段映射
3. 重新生成 SQL 文件

