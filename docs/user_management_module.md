# 用户管理模块设计文档

## 1. 模块概述

用户管理模块是 BANTU CRM 系统的核心基础模块，负责用户认证、授权、组织管理和权限控制。本模块基于组织架构设计，支持多组织、多角色的权限管理体系。

---

## 2. 核心概念

### 2.1 组织架构 (Organizations)

系统采用统一的组织表 (`organizations`) 管理所有组织类型：

- **内部组织 (internal)**: 系统内部的组织结构（公司、部门、团队）
- **供应商组织 (vendor)**: 外部供应商组织
- **渠道代理组织 (agent)**: 渠道代理组织

**组织特性**：
- 支持层级结构（`parent_id`）
- 每个组织有唯一的 `code`
- 组织可以启用/禁用 (`is_active`)
- 组织可以锁定 (`is_locked`)

### 2.2 用户 (Users)

用户表 (`users`) 存储系统所有用户信息：

**关键字段**：
- `username`: 用户名（在组织内唯一）
- `email`: 邮箱（全局唯一，可为空）
- `organization_id`: 所属组织（可为空，支持跨组织用户）
- `password_hash`: 密码哈希值
- `is_active`: 是否启用

**用户名唯一性规则**：
- 用户名在**组织内唯一**，不同组织可以有相同用户名
- 唯一约束：`(organization_id, username)`

### 2.3 组织员工 (Organization Employees)

`organization_employees` 表记录用户在组织中的员工身份：

- 一个用户可以在多个组织中担任员工
- 每个员工记录包含：姓名、职位、部门、联系方式等
- 支持主要员工标记 (`is_primary`)
- 支持员工状态管理（启用/禁用、入职/离职时间）

### 2.4 角色 (Roles)

系统预定义角色：

| 角色代码 | 角色名称 | 描述 |
|---------|---------|------|
| ADMIN | Administrator | 系统管理员，拥有所有权限 |
| SALES | Sales | 内部销售代表 |
| AGENT | Channel Agent | 外部渠道代理销售 |
| OPERATION | Operation | 订单处理人员 |
| FINANCE | Finance | 财务人员，负责应收应付和报表 |

**角色特性**：
- 角色通过 `user_roles` 表分配给用户
- 一个用户可以拥有多个角色
- 角色权限在应用层控制

---

## 3. 功能模块设计

### 3.1 用户认证 (Authentication)

#### 3.1.1 登录流程

```
1. 用户输入用户名和密码
2. 系统根据用户名查找用户（需要考虑组织上下文）
3. 验证密码哈希
4. 检查用户状态（is_active）
5. 检查组织状态（organizations.is_active）
6. 生成 JWT Token（包含用户ID、组织ID、角色列表）
7. 更新 last_login_at
8. 返回 Token 和用户信息
```

#### 3.1.2 登录接口设计

**POST /api/auth/login**

请求体：
```json
{
  "username": "zhangsan",
  "password": "password123",
  "organization_code": "BANTU" // 可选，用于多组织场景
}
```

响应：
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "username": "zhangsan",
    "display_name": "张三",
    "email": "zhangsan@example.com",
    "organization": {
      "id": "uuid",
      "name": "BANTU 公司",
      "code": "BANTU",
      "type": "internal"
    },
    "roles": ["SALES", "OPERATION"],
    "permissions": ["customer:read", "order:create", ...]
  }
}
```

#### 3.1.3 密码管理

- 密码存储：使用 bcrypt 或 argon2 哈希
- 密码强度要求：
  - 最少 8 位
  - 包含大小写字母、数字
  - 可选：特殊字符
- 密码重置流程：
  1. 用户请求重置密码（通过邮箱验证）
  2. 生成重置 Token（有效期 1 小时）
  3. 用户通过 Token 设置新密码

### 3.2 用户管理 (User Management)

#### 3.2.1 用户创建

**POST /api/users**

权限要求：`ADMIN` 或组织管理员

请求体：
```json
{
  "username": "lisi",
  "email": "lisi@example.com",
  "password": "password123",
  "display_name": "李四",
  "phone": "13800138000",
  "organization_id": "uuid",
  "roles": ["SALES"],
  "employee_info": {
    "first_name": "李",
    "last_name": "四",
    "position": "销售经理",
    "department": "销售部",
    "is_primary": true
  }
}
```

**业务规则**：
1. 检查用户名在组织内是否唯一
2. 检查邮箱是否全局唯一（如果提供）
3. 创建用户记录
4. 如果提供 `employee_info`，创建 `organization_employees` 记录
5. 分配角色

#### 3.2.2 用户查询

**GET /api/users**

查询参数：
- `organization_id`: 按组织筛选
- `role`: 按角色筛选
- `is_active`: 按状态筛选
- `search`: 搜索用户名、邮箱、显示名称
- `page`, `limit`: 分页

响应：
```json
{
  "data": [
    {
      "id": "uuid",
      "username": "zhangsan",
      "display_name": "张三",
      "email": "zhangsan@example.com",
      "organization": {
        "id": "uuid",
        "name": "BANTU 公司",
        "code": "BANTU"
      },
      "roles": ["SALES"],
      "is_active": true,
      "last_login_at": "2025-11-06T09:00:00Z",
      "created_at": "2025-10-01T10:00:00Z"
    }
  ],
  "total": 100,
  "page": 1,
  "limit": 20
}
```

#### 3.2.3 用户更新

**PUT /api/users/:id**

权限要求：
- `ADMIN`: 可以更新所有用户
- 其他用户：只能更新自己的信息（部分字段）

可更新字段：
- `display_name`
- `email`（需验证唯一性）
- `phone`
- `is_active`（仅 ADMIN）
- `organization_id`（仅 ADMIN）
- `roles`（仅 ADMIN）

#### 3.2.4 用户删除/禁用

**DELETE /api/users/:id** 或 **POST /api/users/:id/disable**

权限要求：`ADMIN`

**软删除策略**：
- 不直接删除用户记录（保持数据完整性）
- 设置 `is_active = false`
- 如果用户有关联数据（订单、客户等），不允许删除

### 3.3 组织管理 (Organization Management)

#### 3.3.1 组织创建

**POST /api/organizations**

权限要求：`ADMIN`

请求体：
```json
{
  "name": "销售部",
  "code": "SALES_DEPT",
  "organization_type": "internal",
  "parent_id": "uuid", // 可选，父组织
  "email": "sales@bantu.com",
  "phone": "010-12345678",
  "is_active": true
}
```

#### 3.3.2 组织查询

**GET /api/organizations**

查询参数：
- `type`: 组织类型（internal/vendor/agent）
- `parent_id`: 父组织
- `is_active`: 状态
- `search`: 搜索名称、代码

#### 3.3.3 组织树结构

**GET /api/organizations/tree**

返回组织层级树：
```json
{
  "id": "uuid",
  "name": "BANTU 公司",
  "code": "BANTU",
  "type": "internal",
  "children": [
    {
      "id": "uuid",
      "name": "销售部",
      "code": "SALES_DEPT",
      "children": [...]
    }
  ]
}
```

### 3.4 角色管理 (Role Management)

#### 3.4.1 角色查询

**GET /api/roles**

返回所有可用角色列表。

#### 3.4.2 用户角色分配

**POST /api/users/:id/roles**

权限要求：`ADMIN`

请求体：
```json
{
  "role_ids": ["uuid1", "uuid2"]
}
```

### 3.5 权限控制 (Permission Control)

#### 3.5.1 权限定义

权限采用基于角色的访问控制 (RBAC)：

| 模块 | 权限代码 | 描述 |
|------|---------|------|
| 用户管理 | `user:create` | 创建用户 |
| 用户管理 | `user:read` | 查看用户 |
| 用户管理 | `user:update` | 更新用户 |
| 用户管理 | `user:delete` | 删除用户 |
| 组织管理 | `org:create` | 创建组织 |
| 组织管理 | `org:read` | 查看组织 |
| 组织管理 | `org:update` | 更新组织 |
| 组织管理 | `org:delete` | 删除组织 |
| 客户管理 | `customer:create` | 创建客户 |
| 客户管理 | `customer:read` | 查看客户 |
| 客户管理 | `customer:update` | 更新客户 |
| 订单管理 | `order:create` | 创建订单 |
| 订单管理 | `order:read` | 查看订单 |
| 订单管理 | `order:update` | 更新订单 |
| 财务管理 | `finance:read` | 查看财务数据 |
| 财务管理 | `finance:write` | 操作财务数据 |

#### 3.5.2 角色权限映射

```javascript
const rolePermissions = {
  ADMIN: ['*'], // 所有权限
  SALES: [
    'customer:create', 'customer:read', 'customer:update',
    'order:create', 'order:read', 'order:update',
    'product:read'
  ],
  AGENT: [
    'customer:create', 'customer:read', // 仅限自己的客户
    'order:read', // 仅限自己的订单
    'product:read'
  ],
  OPERATION: [
    'order:read', 'order:update',
    'deliverable:create', 'deliverable:read', 'deliverable:update'
  ],
  FINANCE: [
    'order:read',
    'payment:create', 'payment:read', 'payment:update',
    'finance:read', 'finance:write'
  ]
};
```

#### 3.5.3 权限中间件

```javascript
// 检查用户是否有特定权限
function hasPermission(user, permission) {
  // ADMIN 拥有所有权限
  if (user.roles.includes('ADMIN')) {
    return true;
  }
  
  // 检查用户的所有角色是否包含该权限
  return user.roles.some(role => {
    const permissions = rolePermissions[role] || [];
    return permissions.includes(permission) || permissions.includes('*');
  });
}

// 中间件示例
function requirePermission(permission) {
  return (req, res, next) => {
    if (!hasPermission(req.user, permission)) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
}
```

---

## 4. 数据访问控制

### 4.1 组织级数据隔离

- 用户只能访问自己组织的数据（除非是 ADMIN）
- 查询时自动添加组织过滤条件

### 4.2 用户级数据访问

- **SALES**: 只能访问自己创建的客户和订单（`owner_user_id`）
- **AGENT**: 只能访问自己带来的客户和订单（`agent_user_id`）
- **OPERATION**: 只能访问分配给自己的订单（`order_assignments`）
- **FINANCE**: 可以访问所有订单的财务信息

### 4.3 数据访问查询示例

```sql
-- SALES 用户查询自己的客户
SELECT * FROM customers 
WHERE owner_user_id = :current_user_id
  AND customer_source_type = 'own';

-- AGENT 用户查询自己的客户
SELECT * FROM customers 
WHERE agent_user_id = :current_user_id
  AND customer_source_type = 'agent';

-- OPERATION 用户查询分配给自己的订单
SELECT o.* FROM orders o
JOIN order_assignments oa ON oa.order_id = o.id
WHERE oa.assigned_to_user_id = :current_user_id
  AND oa.unassigned_at IS NULL;
```

---

## 5. API 端点设计

### 5.1 认证相关

| 方法 | 路径 | 描述 | 权限 |
|------|------|------|------|
| POST | `/api/auth/login` | 用户登录 | 公开 |
| POST | `/api/auth/logout` | 用户登出 | 需要认证 |
| POST | `/api/auth/refresh` | 刷新 Token | 需要认证 |
| POST | `/api/auth/forgot-password` | 忘记密码 | 公开 |
| POST | `/api/auth/reset-password` | 重置密码 | 公开（需 Token） |

### 5.2 用户管理

| 方法 | 路径 | 描述 | 权限 |
|------|------|------|------|
| GET | `/api/users` | 查询用户列表 | `user:read` |
| GET | `/api/users/:id` | 获取用户详情 | `user:read` |
| POST | `/api/users` | 创建用户 | `user:create` |
| PUT | `/api/users/:id` | 更新用户 | `user:update` |
| DELETE | `/api/users/:id` | 删除用户 | `user:delete` |
| POST | `/api/users/:id/roles` | 分配角色 | `user:update` |
| POST | `/api/users/:id/password` | 修改密码 | 自己或 `user:update` |

### 5.3 组织管理

| 方法 | 路径 | 描述 | 权限 |
|------|------|------|------|
| GET | `/api/organizations` | 查询组织列表 | `org:read` |
| GET | `/api/organizations/tree` | 获取组织树 | `org:read` |
| GET | `/api/organizations/:id` | 获取组织详情 | `org:read` |
| POST | `/api/organizations` | 创建组织 | `org:create` |
| PUT | `/api/organizations/:id` | 更新组织 | `org:update` |
| DELETE | `/api/organizations/:id` | 删除组织 | `org:delete` |

### 5.4 角色管理

| 方法 | 路径 | 描述 | 权限 |
|------|------|------|------|
| GET | `/api/roles` | 查询角色列表 | `user:read` |
| GET | `/api/roles/:id` | 获取角色详情 | `user:read` |

---

## 6. 数据库设计要点

### 6.1 用户表 (users)

- `username` + `organization_id` 唯一约束
- `email` 全局唯一（可为空）
- `password_hash` 存储加密后的密码
- `organization_id` 可为空（支持跨组织用户）

### 6.2 组织员工表 (organization_employees)

- 一个用户可以在多个组织中
- `user_id` + `organization_id` 唯一约束（活跃记录）
- `is_primary` 标记主要组织

### 6.3 用户角色表 (user_roles)

- 多对多关系
- `user_id` + `role_id` 复合主键

---

## 7. 安全考虑

### 7.1 密码安全

- 使用强哈希算法（bcrypt/argon2）
- 密码不存储在日志中
- 密码重置 Token 有时效性

### 7.2 Token 安全

- JWT Token 包含用户ID、组织ID、角色
- Token 有过期时间（如 24 小时）
- 支持 Token 刷新机制
- 登出时使 Token 失效（使用黑名单或 Redis）

### 7.3 权限验证

- 所有 API 都需要认证（除登录、注册等公开接口）
- 权限检查在中间件层统一处理
- 数据访问控制基于用户角色和组织

### 7.4 审计日志

- 记录用户登录/登出
- 记录敏感操作（用户创建、删除、权限变更）
- 记录数据访问（可选）

---

## 8. 实现优先级

### 第一阶段（MVP）

1. ✅ 用户登录/登出
2. ✅ 用户基本信息管理（CRUD）
3. ✅ 基础权限控制（基于角色）
4. ✅ 组织查询

### 第二阶段

5. 组织管理（CRUD）
6. 用户角色分配
7. 密码重置功能
8. Token 刷新机制

### 第三阶段

9. 组织树结构管理
10. 多组织用户支持
11. 权限细粒度控制
12. 审计日志

---

## 9. 技术栈建议

- **认证**: JWT (jsonwebtoken)
- **密码加密**: bcrypt 或 argon2
- **权限中间件**: 自定义中间件
- **数据验证**: Joi 或 class-validator
- **API 文档**: Swagger/OpenAPI

---

## 10. 测试要点

- 用户登录/登出流程
- 密码验证和加密
- 权限控制（不同角色的访问限制）
- 组织内用户名唯一性
- 邮箱全局唯一性
- 数据访问隔离（组织级、用户级）
- Token 过期和刷新
- 密码重置流程

