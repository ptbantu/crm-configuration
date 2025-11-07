# SQL 文件说明

## 文件列表

### Schema 文件（按推荐顺序）

1. **schema_unified.sql** ⭐ **推荐使用**
   - MySQL 版本的统一 schema 文件
   - 包含所有最新变更（username 不唯一，新增用户字段）
   - 文件大小: 37KB
   - 用途: 生产环境推荐使用此文件

2. **schema_mysql.sql**
   - MySQL 版本（已更新，与 unified 版本一致）
   - 文件大小: 37KB
   - 用途: 兼容旧脚本，功能与 unified 版本相同

3. **schema.sql**
   - PostgreSQL 版本（已更新，与 unified 版本一致）
   - 文件大小: 38KB
   - 用途: PostgreSQL 数据库使用

### 文档文件

- **README.md** - 数据库结构详细文档（已更新）
- **SCHEMA_LATEST_CHANGES.md** - 最新变更说明（2024-11-07）
- **FILES.md** - 本文件，文件说明

### 关系图文件

- **RELATIONSHIPS.mmd** - Mermaid ER 图源文件
- **RELATIONSHIPS.dot** - Graphviz ER 图源文件
- **RELATIONSHIPS.png** - ER 图 PNG 格式
- **RELATIONSHIPS.svg** - ER 图 SVG 格式
- **RELATIONSHIPS.txt** - ER 图文本格式

## 使用建议

### 开发环境
- 使用 `schema_unified.sql` 作为主要 schema 文件
- 使用 `k8s/import-schema-mysql.sh` 脚本导入（会自动清空数据库）

### 生产环境
- 使用 `schema_unified.sql` 进行初始化
- 后续使用迁移脚本进行增量更新

### 多数据库支持
- MySQL: 使用 `schema_unified.sql` 或 `schema_mysql.sql`
- PostgreSQL: 使用 `schema.sql`

## 文件一致性

所有 schema 文件（schema_unified.sql, schema_mysql.sql, schema.sql）都包含：
- ✅ 最新的 users 表结构（username 不唯一，新增字段）
- ✅ 最新的 organization_employees 表结构（user_id 必填）
- ✅ 统一的字段命名（snake_case）
- ✅ 完整的索引和约束

## 已删除的过时文件

- ❌ `SCHEMA_CHANGES.md` - 已删除（信息过时，已由 SCHEMA_LATEST_CHANGES.md 替代）

