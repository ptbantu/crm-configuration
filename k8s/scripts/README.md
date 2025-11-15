# 数据库初始化脚本

用于初始化 MySQL 数据库的脚本。

## 📁 文件说明

- `import-schema-mysql.sh` - 导入数据库 Schema（清空并重建表结构）
- `import-seed-data.sh` - 导入种子数据（初始数据）

## 🚀 使用说明

### 前置条件

1. MySQL 已部署并运行
2. MySQL Pod 处于 Ready 状态

### 导入 Schema

```bash
cd scripts
./import-schema-mysql.sh
```

此脚本会：
- 清空现有数据库（删除所有表和视图）
- 导入 `schema_unified.sql` 文件
- 验证导入结果

### 导入种子数据

```bash
./import-seed-data.sh
```

此脚本会：
- 导入 `seed_data.sql` 文件
- 验证 BANTU 组织是否创建成功

## ⚠️ 注意事项

1. **Schema 导入会清空数据库**：请确保在非生产环境或已备份的情况下运行
2. **执行顺序**：必须先导入 Schema，再导入种子数据
3. **SQL 文件路径**：脚本会自动查找 `../sql/` 目录下的 SQL 文件

## 📝 SQL 文件位置

脚本会自动查找以下文件：
- Schema: `../sql/schema_unified.sql`
- Seed Data: `../sql/seed_data.sql`

