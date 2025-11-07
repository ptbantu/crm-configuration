# BANTU CRM 数据库结构文档

## 文件说明

- **schema_unified.sql** - **推荐使用**，MySQL 版本的统一 schema 文件（最新）
- **schema_mysql.sql** - MySQL 版本（已更新，保持兼容）
- **schema.sql** - PostgreSQL 版本（已更新，保持兼容）
- **README.md** - 数据库结构文档
- **RELATIONSHIPS.*** - ER 关系图文件（.dot, .mmd, .png, .svg, .txt）

## 执行顺序

### MySQL 版本（推荐）

```bash
# 使用统一的 schema 文件（推荐）
mysql -u user -p database < sql/schema_unified.sql

# 或使用 K8s 导入脚本（会自动清空数据库）
./k8s/import-schema-mysql.sh
```

### PostgreSQL 版本

```bash
# 执行完整的数据库架构
psql "$DATABASE_URL" -f sql/schema.sql
```

**注意**：所有数据库结构已整合到各自的 schema 文件中，包含所有表、约束、索引、触发器和视图定义。

## 数据库表结构

### 核心表（Core Tables）

#### 1. organizations（统一组织表）
- **用途**: 统一管理所有组织类型（内部组织、供应商、渠道代理）
- **关键字段**: 
  - `id`, `name`, `code` (UNIQUE), `organization_type` ('internal' | 'vendor' | 'agent')
  - `parent_id`: 上级组织（主要用于内部组织）
  - 联系方式：`email`, `phone`, `website`
  - 地址：`street`, `city`, `state_province`, `postal_code`, `country_region`
- **关联**: 
  - `parent_id` → organizations (自关联，支持组织层级)
  - 通过 `organization_employees` 关联到 `users`
  - 通过 `vendor_extensions` 关联供应商扩展信息
  - 通过 `agent_extensions` 关联代理扩展信息

#### 2. vendor_extensions（供应商扩展表）
- **用途**: 存储供应商组织特有的字段
- **关键字段**: `organization_id`, `account_group`, `category_name`
- **关联**: `organization_id` → organizations (organization_type = 'vendor')

#### 3. agent_extensions（渠道代理扩展表）
- **用途**: 存储渠道代理组织特有的字段
- **关键字段**: `organization_id`, `account_group`, `category_name`
- **关联**: `organization_id` → organizations (organization_type = 'agent')

#### 4. organization_employees（组织员工表）- 用户表的扩展
- **用途**: 作为用户表的扩展，记录用户在组织中的详细信息
- **关键字段**: 
  - `id`, `organization_id`, `user_id` (**必填**，每个成员必须是组织成员)
  - `first_name`, `last_name`: 名字（可选）
  - `email`, `phone`: 工作联系方式（可与 users 表不同）
  - `position`: 职位
  - `department`: 部门
  - `employee_number`: 工号
  - `is_primary`: 是否用户的主要组织
  - `is_manager`: 是否管理者
  - `is_decision_maker`: 是否决策人（vendor/agent）
  - `is_active`: 是否在职
- **关联**: 
  - `organization_id` → organizations
  - `user_id` → users (**必填**，每个成员必须关联用户)
- **约束**: 
  - 每个用户必须至少有一个 `organization_employees` 记录（业务逻辑约束）
  - 每个用户只能有一个主要组织（`is_primary = TRUE AND is_active = TRUE`）
  - 同一用户在同一组织只能有一条激活的员工记录

#### 5. users（用户表）- 系统登录账户
- **用途**: 管理可以登录系统的用户账户信息
- **关键字段**: 
  - `id`, `username`, `email`, `phone`, `password_hash`, `display_name`
  - `avatar_url`, `bio`, `gender`, `address`, `contact_phone`, `whatsapp`, `wechat`
  - `is_active`, `last_login_at`
- **唯一约束**: 
  - `username` **不唯一**（可以重复，用于登录）
  - `email` **全局唯一**（可空，用于登录）
- **关联**: 
  - 通过 `user_roles` 关联到 `roles`
  - 通过 `organization_employees` 关联到组织（每个用户必须至少有一个组织员工记录）
- **注意**: 每个用户必须至少有一个 `organization_employees` 记录

#### 6. roles（角色表）
- **用途**: 系统角色定义（全局）
- **预设角色**: ADMIN, SALES, AGENT, OPERATION, FINANCE
- **关键字段**: `id`, `code` (UNIQUE), `name`, `description`

#### 7. user_roles（用户角色关联表）
- **用途**: 用户与角色的多对多关系
- **关键字段**: `user_id`, `role_id` (联合主键)

### 产品域（Product Domain）

#### 注：vendors 和 agents 表已废弃
- **vendors** 表：已迁移到 `organizations` (organization_type = 'vendor')
- **agents** 表：已迁移到 `organizations` (organization_type = 'agent')
- **vendor_employees** 表：已迁移到 `organization_employees`
- **agent_employees** 表：已迁移到 `organization_employees`
- 使用 `vendor_extensions` 和 `agent_extensions` 存储类型特有的扩展字段

#### 8. product_categories（产品分类表）
- **用途**: 产品分类
- **关键字段**: `id`, `code` (UNIQUE), `name`
- **关联**: 无

#### 9. products（产品表）
- **用途**: 产品/服务信息
- **关键字段**: `id`, `code`, `name`, `vendor_id`, `category_id`, `price_list`, `price_channel`, `price_cost`
- **关联**: 
  - `vendor_id` → organizations (organization_type = 'vendor')
  - `category_id` → product_categories

### 客户域（Customer Domain）

#### 8. customer_sources（客户来源表）
- **用途**: 客户来源分类（如：微信扫码、客户转介绍等）
- **关键字段**: `id`, `code` (UNIQUE), `name`

#### 9. customer_channels（客户渠道表）
- **用途**: 客户渠道分类
- **关键字段**: `id`, `code` (UNIQUE), `name`

#### 10. customers（客户表）
- **用途**: 客户主表，支持内部客户和渠道客户
- **关键字段**: 
  - `id`, `name`, `code`
  - `customer_source_type`: 'own' | 'agent'（内部客户/渠道客户）
  - `customer_type`: 'individual' | 'organization'（个人/组织）
  - `owner_user_id`: 内部客户的所有者（销售）
  - `agent_id`: 渠道客户的所有者（agent 组织，推荐使用）
  - `agent_user_id`: 渠道客户的所有者（agent 用户，已废弃，保留用于向后兼容）
  - `parent_customer_id`: 组织下的个人客户
- **关联**: 
  - `owner_user_id` → users (SALES)
  - `agent_id` → organizations (organization_type = 'agent')
  - `agent_user_id` → users (AGENT，已废弃)
  - `parent_customer_id` → customers (self-reference)

#### 11. contacts（联系人表）
- **用途**: 组织客户下的联系人信息
- **关键字段**: 
  - `id`, `customer_id`, `first_name`, `last_name`, `email`, `phone`
  - `is_primary`: 是否主要联系人（每个组织唯一）
  - `is_decision_maker`: 是否决策人
- **关联**: `customer_id` → customers (organization)

### 订单域（Order Domain）

#### 12. order_statuses（订单状态表）
- **用途**: 订单状态枚举
- **预设状态**: draft, submitted, assigned, in_progress, pending_review, completed, cancelled, on_hold
- **关键字段**: `id`, `code` (UNIQUE), `name`, `display_order`

#### 13. orders（订单表）
- **用途**: 订单主表，连接客户、产品、销售
- **关键字段**: 
  - `id`, `order_number` (UNIQUE), `title`
  - `customer_id`, `product_id`, `sales_user_id`
  - `quantity`, `unit_price`, `total_amount`, `final_amount`
  - `status_code`, `expected_start_date`, `expected_completion_date`
- **关联**: 
  - `customer_id` → customers
  - `product_id` → products
  - `sales_user_id` → users (SALES)
  - `status_id` → order_statuses

#### 14. order_assignments（订单分配表）
- **用途**: 订单分配给做单人员（内部员工或供应商/代理员工）
- **关键字段**: 
  - `id`, `order_id`, `assigned_to_user_id`, `assigned_by_user_id`
  - `vendor_id`: 供应商组织（如果分配给供应商，organization_type = 'vendor'）
  - `organization_employee_id`: 组织员工（如果分配给供应商/代理员工）
  - `vendor_employee_id`: 供应商员工（已废弃，保留用于向后兼容）
  - `assignment_type`: 'operation' | 'vendor'
  - `is_primary`: 是否主要负责人
- **关联**: 
  - `order_id` → orders
  - `assigned_to_user_id` → users (OPERATION，内部做单人员)
  - `assigned_by_user_id` → users
  - `vendor_id` → organizations (organization_type = 'vendor')
  - `organization_employee_id` → organization_employees

#### 17. order_stages（订单阶段表）
- **用途**: 订单的分阶段进度跟踪
- **关键字段**: 
  - `id`, `order_id`, `stage_name`, `stage_code`, `stage_order`
  - `status`: 'pending' | 'in_progress' | 'completed' | 'failed'
  - `progress_percent`: 0-100
  - `assigned_to_user_id`
- **关联**: 
  - `order_id` → orders
  - `assigned_to_user_id` → users

#### 18. deliverables（交付物表）
- **用途**: 订单交付的文件、文档、成果
- **关键字段**: 
  - `id`, `order_id`, `order_stage_id`
  - `deliverable_type`: 'file' | 'document' | 'certificate' | 'other'
  - `name`, `file_path`, `file_url`, `file_size`, `mime_type`
  - `is_verified`: 是否已验证
- **关联**: 
  - `order_id` → orders
  - `order_stage_id` → order_stages

#### 19. payments（收款记录表）
- **用途**: 订单收款记录
- **关键字段**: 
  - `id`, `order_id`
  - `payment_type`: 'full' | 'partial' | 'refund'
  - `amount`, `currency_code`, `payment_method`
  - `payment_date`, `received_at`, `status`
- **关联**: 
  - `order_id` → orders

### 签证记录（Legacy）

#### 20. visa_records（签证记录表）
- **用途**: 签证服务记录（历史数据）
- **关键字段**: 
  - `id`, `customer_id`, `customer_name`
  - `passport_id`, `entry_city`, `currency_code`, `fx_rate`, `payment_amount`
- **关联**: 
  - `customer_id` → customers

## 表关系图

### 核心关系

```
organizations (统一组织表)
  ├── organization_type: 'internal' | 'vendor' | 'agent'
  ├── parent_id → organizations [组织层级，主要用于内部组织]
  ├── vendor_extensions (供应商扩展)
  ├── agent_extensions (渠道代理扩展)
  └── organization_employees (统一员工表)
      └── user_id → users (系统用户，可选)
users (系统用户)
  ├── organization_id → organizations [主要组织]
  └── user_roles → roles (角色)
product_categories (产品分类)
products (产品)
  ├── vendor_id → organizations (organization_type = 'vendor')
  └── product_categories (分类)
customers (客户)
  ├── owner_user_id → users (SALES) [内部客户]
  ├── agent_id → organizations (organization_type = 'agent') [渠道客户]
  ├── agent_user_id → users (AGENT用户，已废弃) [渠道客户]
  ├── parent_customer_id → customers [组织层级]
  └── contacts (联系人) [组织客户]
orders (订单)
  ├── customers (客户)
  ├── products (产品)
  ├── sales_user_id → users (SALES)
  ├── order_assignments (分配)
  │   └── assigned_to_user_id → users (OPERATION)
  ├── order_stages (阶段)
  │   └── assigned_to_user_id → users
  ├── deliverables (交付物)
  └── payments (收款)
users (用户)
  └── user_roles → roles (角色)
visa_records (签证记录)
  └── customers (客户)
```

### 外键关系汇总

| 表名 | 外键字段 | 关联表 | 说明 |
|------|---------|--------|------|
| **products** | `vendor_id` | organizations | 供应商组织 |
| **products** | `category_id` | product_categories | 产品分类 |
| **vendor_extensions** | `organization_id` | organizations | 供应商组织 |
| **agent_extensions** | `organization_id` | organizations | 渠道代理组织 |
| **organizations** | `parent_id` | organizations | 上级组织（自关联，主要用于内部组织） |
| **organization_employees** | `organization_id` | organizations | 组织（统一） |
| **organization_employees** | `user_id` | users | 系统用户（可选，内部组织必须） |
| **users** | `organization_id` | organizations | 主要组织（快速访问） |
| **customers** | `owner_user_id` | users | 内部客户所有者（销售） |
| **customers** | `agent_id` | organizations | 渠道客户所有者（推荐） |
| **customers** | `agent_user_id` | users | 渠道客户所有者（已废弃） |
| **customers** | `parent_customer_id` | customers | 组织层级（自关联） |
| **contacts** | `customer_id` | customers | 组织客户 |
| **orders** | `customer_id` | customers | 客户 |
| **orders** | `product_id` | products | 产品 |
| **orders** | `sales_user_id` | users | 创建订单的销售 |
| **orders** | `status_id` | order_statuses | 订单状态 |
| **order_assignments** | `order_id` | orders | 订单 |
| **order_assignments** | `assigned_to_user_id` | users | 内部做单人员 |
| **order_assignments** | `assigned_by_user_id` | users | 分配者 |
| **order_assignments** | `vendor_id` | organizations | 供应商组织 |
| **order_assignments** | `organization_employee_id` | organization_employees | 组织员工 |
| **order_assignments** | `vendor_employee_id` | organization_employees | 供应商员工（已废弃） |
| **order_stages** | `order_id` | orders | 订单 |
| **order_stages** | `assigned_to_user_id` | users | 阶段负责人 |
| **deliverables** | `order_id` | orders | 订单 |
| **deliverables** | `order_stage_id` | order_stages | 订单阶段 |
| **payments** | `order_id` | orders | 订单 |
| **visa_records** | `customer_id` | customers | 客户 |
| **user_roles** | `user_id` | users | 用户 |
| **user_roles** | `role_id` | roles | 角色 |

## 唯一约束与索引

### 唯一约束

- `users(organization_id, username)` - 用户名在同一组织内唯一
- `users.email` - 邮箱全局唯一（可空）
- `roles.code` - 角色代码唯一
- `product_categories.code` - 产品分类代码唯一
- `products.code` - 产品代码唯一（可空）
- `customers.code` - 客户代码唯一（可空）
- `orders.order_number` - 订单编号唯一
- `contacts(customer_id)` WHERE `is_primary = TRUE` - 每个组织唯一主要联系人

### 重要索引

- 所有外键字段都有索引
- `users.email`, `users.phone`
- `organizations.email`, `organizations.phone`
- `contacts.email`, `contacts.phone`
- `orders.status_code`, `orders.created_at`
- `order_assignments(order_id, assigned_to_user_id)` WHERE `unassigned_at IS NULL`
- `payments.status`, `payments.payment_date`

## 业务规则

### 客户分类规则

1. **客户来源** (`customer_source_type`)
   - `'own'`: 内部客户，必须有 `owner_user_id`（销售），不能有 `agent_user_id`
   - `'agent'`: 渠道客户，必须有 `agent_user_id`（agent），不能有 `owner_user_id`

2. **客户类型** (`customer_type`)
   - `'individual'`: 个人客户，可以独立或挂到组织下
   - `'organization'`: 组织客户，可以包含联系人和子客户

3. **组织联系人**
   - 每个组织客户必须至少有一个主要联系人 (`is_primary = TRUE`)
   - 主要联系人在同一组织内唯一

### 订单流程规则

1. **订单状态流转**: draft → submitted → assigned → in_progress → completed
2. **订单分配**: 通过 `order_assignments` 分配给做单人员
3. **阶段进度**: 通过 `order_stages` 跟踪各阶段进度（0-100%）
4. **收款**: 通过 `payments` 记录收款，支持部分收款和退款

## 审计字段

所有核心表都包含：
- `created_at` - 创建时间
- `updated_at` - 更新时间（通过触发器自动维护）
- `created_by` / `updated_by` - 创建者/更新者（部分表）

部分表包含源系统映射字段：
- `*_external` - 外部系统ID
- `*_at_src` - 源系统时间戳
- `*_name` - 源系统名称（冗余字段）

## ER 图文件

- `RELATIONSHIPS.txt` - 文本格式的关系说明
- `RELATIONSHIPS.dot` - Graphviz DOT 格式（可生成图片）
- `RELATIONSHIPS.mmd` - Mermaid 格式（可在 Markdown 中渲染）
- `RELATIONSHIPS.png` - PNG 图片（已生成）
- `RELATIONSHIPS.svg` - SVG 矢量图（已生成）

生成图片：
```bash
cd sql
dot -Tpng RELATIONSHIPS.dot -o RELATIONSHIPS.png
dot -Tsvg RELATIONSHIPS.dot -o RELATIONSHIPS.svg
```
