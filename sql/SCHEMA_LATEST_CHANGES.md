# Schema 最新变更说明

## 更新日期
2024-11-07

## 核心变更

### 1. Users 表调整

#### 用户名唯一性
- **之前**: `username` 字段有 UNIQUE 约束（全局唯一）
- **现在**: `username` 字段移除 UNIQUE 约束，**允许重复**
- **唯一性**: 只有 `email` 字段保持全局唯一

#### 新增字段
在 `users` 表中新增以下字段，用于存储用户的详细信息：

| 字段名 | 类型 | 说明 |
|--------|------|------|
| `avatar_url` | VARCHAR(500) / TEXT | 头像地址 |
| `bio` | TEXT | 个人简介 |
| `gender` | VARCHAR(10) / TEXT | 性别：male, female, other |
| `address` | TEXT | 住址 |
| `contact_phone` | VARCHAR(50) / TEXT | 联系电话 |
| `whatsapp` | VARCHAR(50) / TEXT | WhatsApp 号码 |
| `wechat` | VARCHAR(100) / TEXT | 微信号 |

#### 索引调整
- **移除**: `ux_users_username` 唯一索引
- **新增**: `ix_users_username` 普通索引（用于查询）
- **新增**: `ix_users_wechat` 索引（用于查询）
- **保留**: `ux_users_email` 唯一索引（邮箱唯一性）

### 2. Users 与 Organization_Employees 关系

#### 职责划分
- **Users 表**: 专注于系统登录账户管理（username, password, email, 个人详细信息）
- **Organization_Employees 表**: 作为用户表的扩展，记录用户在组织中的详细信息（职位、部门、工作联系方式）

#### 核心原则
- **每个成员都必须是一个组织成员**
- `organization_employees.user_id` 为 **NOT NULL**（必填）
- 每个用户必须至少有一个 `organization_employees` 记录（业务逻辑约束）

### 3. 字段命名规范

所有表字段已统一使用 **snake_case** 命名规范，确保简洁明了、统一风格。

## 文件说明

### 推荐使用
- **schema_unified.sql** - MySQL 版本的统一 schema 文件（最新，推荐使用）

### 兼容版本
- **schema_mysql.sql** - MySQL 版本（已更新，保持兼容）
- **schema.sql** - PostgreSQL 版本（已更新，保持兼容）

## 业务逻辑影响

### 1. 登录逻辑
- **用户名**: 可以重复，不支持仅通过用户名唯一识别用户
- **邮箱**: 必须唯一（如果提供），推荐使用邮箱登录
- **登录方式**: 支持用户名或邮箱登录，但邮箱登录更可靠

### 2. 用户查询
- 使用用户名查询时，可能返回多条记录（需要结合其他条件）
- 使用邮箱查询时，返回唯一记录
- 建议：登录时优先使用邮箱，用户名作为辅助

### 3. 用户创建
- 创建用户时，邮箱必须唯一（如果提供），用户名可以重复
- 创建用户后，**必须**创建对应的 `organization_employees` 记录

## 数据迁移

如果已有数据，需要执行以下迁移：

### 1. 处理用户名冲突
```sql
-- 查找重复的用户名
SELECT username, COUNT(*) as cnt
FROM users
GROUP BY username
HAVING cnt > 1;
```

### 2. 添加新字段
```sql
ALTER TABLE users 
  ADD COLUMN avatar_url VARCHAR(500),
  ADD COLUMN bio TEXT,
  ADD COLUMN gender VARCHAR(10),
  ADD COLUMN address TEXT,
  ADD COLUMN contact_phone VARCHAR(50),
  ADD COLUMN whatsapp VARCHAR(50),
  ADD COLUMN wechat VARCHAR(100);
```

### 3. 调整索引
```sql
-- 移除用户名唯一索引
DROP INDEX IF EXISTS ux_users_username ON users;

-- 创建普通索引
CREATE INDEX ix_users_username ON users(username);
CREATE INDEX ix_users_wechat ON users(wechat);
```

## 验证清单

- [ ] `username` 字段移除唯一性约束
- [ ] 新增字段已添加：`avatar_url`, `bio`, `gender`, `address`, `contact_phone`, `whatsapp`, `wechat`
- [ ] 索引已调整：`ix_users_username`（普通索引），`ux_users_email`（唯一索引）
- [ ] 所有用户都有至少一个 `organization_employees` 记录
- [ ] 应用层代码已更新，支持新的登录逻辑和用户字段

