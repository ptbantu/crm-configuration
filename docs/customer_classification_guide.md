# 客户分类管理指南

## 客户分类结构

### 1. 客户来源（customer_source_type）

#### 1.1 内部客户（own）
- **定义**: BANTU 自己开发的客户
- **所有者**: `owner_user_id` 指向开发此客户的销售（SALES）
- **权限**: 
  - 内部销售只能看到自己开发的客户
  - ADMIN 可以看到所有内部客户

#### 1.2 渠道客户（agent）
- **定义**: 由渠道代理（AGENT）带来的客户
- **所有者**: `agent_user_id` 指向带来此客户的 agent
- **权限**: 
  - Agent 只能看到自己带来的渠道客户
  - 所有渠道客户都挂到 agent 名下

### 2. 客户类型（customer_type）

#### 2.1 个人客户（individual）
- **定义**: 单个自然人客户
- **特点**: 
  - 可以直接挂到组织下（通过 `parent_customer_id`）
  - 如果是组织下的个人，继承组织的来源（own/agent）

#### 2.2 组织客户（organization）
- **定义**: 企业、机构等组织客户
- **特点**: 
  - 可以包含多个联系人（通过 `contacts` 表）
  - 可以包含多个个人客户（子客户）
  - 可以有多个联系人，但只有一个主要联系人

## 数据结构示例

### 场景1: 内部个人客户

```sql
-- 销售创建内部个人客户
INSERT INTO customers (
  name, customer_source_type, customer_type,
  owner_user_id, phone, email
)
VALUES (
  '张三', 'own', 'individual',
  :sales_user_id, '13800138000', 'zhangsan@example.com'
);
```

### 场景2: 内部组织客户（带联系人）

```sql
-- 1. 创建组织客户
INSERT INTO customers (
  name, customer_source_type, customer_type,
  owner_user_id, industry
)
VALUES (
  'ABC公司', 'own', 'organization',
  :sales_user_id, '互联网'
)
RETURNING id;

-- 2. 添加组织下的联系人
INSERT INTO contacts (
  customer_id, first_name, last_name,
  email, phone, position, is_primary, is_decision_maker
)
VALUES 
  (:customer_id, '李', '四', 'lisi@abc.com', '13900139000', '财务经理', TRUE, TRUE),
  (:customer_id, '王', '五', 'wangwu@abc.com', '13900139001', '技术负责人', FALSE, FALSE);
```

### 场景3: 组织下的个人客户

```sql
-- 1. 先创建组织客户
INSERT INTO customers (name, customer_source_type, customer_type, owner_user_id)
VALUES ('XYZ集团', 'own', 'organization', :sales_user_id)
RETURNING id;

-- 2. 创建组织下的个人客户
INSERT INTO customers (
  name, customer_source_type, customer_type,
  parent_customer_id, owner_user_id
)
VALUES (
  '赵六', 'own', 'individual',
  :organization_id, :sales_user_id
);
-- 注意: 个人客户继承父组织的来源类型
```

### 场景4: Agent 带来的渠道客户

```sql
-- Agent 创建渠道客户（组织）
INSERT INTO customers (
  name, customer_source_type, customer_type,
  agent_id, agent_user_id, industry
)
VALUES (
  'DEF企业', 'agent', 'organization',
  :agent_organization_id, :agent_user_id, '制造业'
)
RETURNING id;

-- 添加渠道客户下的联系人
INSERT INTO contacts (
  customer_id, first_name, last_name,
  email, phone, position, is_primary
)
VALUES (
  :customer_id, '孙', '七', 
  'sunqi@def.com', '13700137000', '总经理', TRUE
);
```

## 查询示例

### 查询销售自己的客户

```sql
-- 内部销售查看自己开发的客户
SELECT c.*, 
       CASE WHEN c.customer_type = 'organization' THEN 
         (SELECT COUNT(*) FROM contacts ct WHERE ct.customer_id = c.id)
       ELSE 0 END as contacts_count
FROM customers c
WHERE c.customer_source_type = 'own'
  AND c.owner_user_id = :sales_user_id
ORDER BY c.created_at DESC;
```

### 查询 Agent 的渠道客户

```sql
-- Agent 查看自己带来的渠道客户
SELECT c.*,
       CASE WHEN c.customer_type = 'organization' THEN 
         (SELECT COUNT(*) FROM contacts ct WHERE ct.customer_id = c.id)
       ELSE 0 END as contacts_count
FROM customers c
WHERE c.customer_source_type = 'agent'
  AND c.agent_user_id = :agent_user_id
ORDER BY c.created_at DESC;
```

### 查询组织下的所有联系人

```sql
SELECT ct.*, c.name as organization_name
FROM contacts ct
JOIN customers c ON c.id = ct.customer_id
WHERE c.id = :organization_id
  AND ct.is_active = TRUE
ORDER BY ct.is_primary DESC, ct.created_at;
```

### 查询组织及其下的个人客户

```sql
-- 查询组织客户及其下的所有个人客户
SELECT 
  parent.id as organization_id,
  parent.name as organization_name,
  child.id as individual_id,
  child.name as individual_name
FROM customers parent
LEFT JOIN customers child ON child.parent_customer_id = parent.id
WHERE parent.customer_type = 'organization'
  AND parent.id = :organization_id;
```

## 业务规则

### 1. 客户来源规则

- ✅ **内部客户** (`customer_source_type = 'own'`)
  - 必须设置 `owner_user_id`（开发此客户的销售）
  - 不能设置 `agent_user_id`
  - 内部销售只能操作自己开发的客户

- ✅ **渠道客户** (`customer_source_type = 'agent'`)
  - 必须设置 `agent_user_id`（带来此客户的 agent）
  - 不能设置 `owner_user_id`
  - 所有渠道客户都挂到 agent 名下
  - Agent 只能操作自己带来的渠道客户

### 2. 客户类型规则

- ✅ **个人客户** (`customer_type = 'individual'`)
  - 可以是独立的个人客户（无 parent）
  - 可以挂到组织下（有 parent_customer_id）
  - 如果挂到组织下，继承组织的来源类型

- ✅ **组织客户** (`customer_type = 'organization'`)
  - 可以包含多个联系人（contacts 表）
  - 可以有多个个人客户作为子客户
  - 必须至少有一个主要联系人（is_primary = TRUE）

### 3. 权限控制

- **内部销售**: 只能查看/操作 `owner_user_id = 自己` 的客户
- **Agent**: 只能查看/操作 `agent_user_id = 自己` 的渠道客户
- **ADMIN**: 可以查看所有客户
- **做单人员**: 只能看到分配给自己订单的客户

## 数据迁移建议

如果已有客户数据，需要设置：

```sql
-- 1. 设置客户来源类型（根据业务逻辑判断）
UPDATE customers 
SET customer_source_type = 'own'  -- 或 'agent'
WHERE customer_source_type IS NULL;

-- 2. 设置客户类型
UPDATE customers 
SET customer_type = 'individual'  -- 或 'organization'
WHERE customer_type IS NULL;

-- 3. 设置 owner_user_id 或 agent_user_id（根据 created_by 等信息）
-- 需要根据业务规则判断
```

