# 客户分类结构图

## 客户分类层级

```
客户 (customers)
├── 来源分类 (customer_source_type)
│   ├── 内部客户 (own)
│   │   └── 所有者: owner_user_id → users (SALES)
│   │
│   └── 渠道客户 (agent)
│       └── 所有者: agent_user_id → users (AGENT)
│
└── 类型分类 (customer_type)
    ├── 个人客户 (individual)
    │   ├── 独立个人客户
    │   │   └── 无 parent_customer_id
    │   │
    │   └── 组织下的个人
    │       └── parent_customer_id → 组织客户
    │
    └── 组织客户 (organization)
        ├── 基本信息 (customers 表)
        ├── 联系人 (contacts 表)
        │   ├── 主要联系人 (is_primary = TRUE) - 唯一
        │   └── 其他联系人 (is_primary = FALSE)
        │
        └── 子客户 (customers 表，parent_customer_id 指向此组织)
            └── 个人客户列表
```

## 数据关系图

```
┌─────────────────────────────────────────────────────────┐
│                    customers                             │
│  ┌───────────────────────────────────────────────────┐   │
│  │ customer_source_type: 'own' | 'agent'            │   │
│  │ customer_type: 'individual' | 'organization'     │   │
│  │ owner_user_id → users (SALES) [if own]           │   │
│  │ agent_user_id → users (AGENT) [if agent]         │   │
│  │ parent_customer_id → customers (organization)    │   │
│  └───────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
         │                        │
         │                        │
         ▼                        ▼
┌─────────────────┐      ┌─────────────────┐
│   contacts      │      │   customers     │
│  (组织的联系人)  │      │  (组织下的个人)  │
│                 │      │                 │
│ customer_id ────┼──────┼─► parent_customer_id
│ is_primary      │      │ customer_type = 'individual'
│ is_decision_maker│     └─────────────────┘
└─────────────────┘
```

## 业务场景示例

### 场景A: 内部组织客户

```
customers:
  id: cust-001
  name: "ABC公司"
  customer_source_type: "own"
  customer_type: "organization"
  owner_user_id: sales-user-001 (内部销售张三)

contacts:
  - id: contact-001
    customer_id: cust-001
    name: "李四 (财务经理)"
    is_primary: TRUE
  
  - id: contact-002
    customer_id: cust-001
    name: "王五 (技术负责人)"
    is_primary: FALSE
```

### 场景B: 组织下的个人客户

```
customers:
  - id: cust-002
    name: "XYZ集团"
    customer_source_type: "own"
    customer_type: "organization"
    owner_user_id: sales-user-001
  
  - id: cust-003
    name: "赵六"
    customer_source_type: "own"
    customer_type: "individual"
    parent_customer_id: cust-002 (挂到XYZ集团下)
    owner_user_id: sales-user-001
```

### 场景C: Agent 的渠道客户

```
customers:
  id: cust-004
  name: "DEF企业"
  customer_source_type: "agent"
  customer_type: "organization"
  agent_user_id: agent-user-001 (渠道代理山海图)

contacts:
  - id: contact-003
    customer_id: cust-004
    name: "孙七 (总经理)"
    is_primary: TRUE
```

## 权限矩阵

| 角色 | 内部客户 (own) | 渠道客户 (agent) |
|------|----------------|-----------------|
| **SALES** | 只能看到自己开发的 (`owner_user_id = 自己`) | 不可见 |
| **AGENT** | 不可见 | 只能看到自己带来的 (`agent_user_id = 自己`) |
| **ADMIN** | 所有内部客户 | 所有渠道客户 |
| **OPERATION** | 只能看到分配给自己订单的客户 | 只能看到分配给自己订单的客户 |

## 关键约束

1. **客户来源约束**
   - `customer_source_type = 'own'` → 必须有 `owner_user_id`，不能有 `agent_user_id`
   - `customer_source_type = 'agent'` → 必须有 `agent_user_id`，不能有 `owner_user_id`

2. **组织联系人约束**
   - 每个组织客户必须至少有一个主要联系人 (`is_primary = TRUE`)
   - 主要联系人在同一组织内唯一

3. **层级约束**
   - 个人客户的 `parent_customer_id` 必须指向组织客户
   - 组织客户不能有 `parent_customer_id`（除非是组织层级关系）

4. **继承规则**
   - 组织下的个人客户继承组织的 `customer_source_type`

