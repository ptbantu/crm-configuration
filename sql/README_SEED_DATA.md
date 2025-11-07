# 种子数据说明

## 概述

种子数据（Seed Data）用于初始化系统的基础数据，确保系统可以正常运行。

## 文件说明

- `seed_data.sql` - 种子数据 SQL 文件

## 包含的数据

### 1. BANTU 根组织

- **组织名称**: BANTU Enterprise Services
- **组织编码**: BANTU
- **组织类型**: internal（内部组织）
- **组织 ID**: `00000000-0000-0000-0000-000000000001`（固定 UUID）

**重要说明**：
- 这是系统的根组织，所有用户创建都需要依赖此组织
- 组织 ID 使用固定 UUID，确保可重复执行而不会创建重复数据
- 使用 `INSERT IGNORE` 语句，避免重复插入

## 执行顺序

1. **先执行表结构创建**：
   ```bash
   mysql -u user -p database < sql/schema_unified.sql
   ```

2. **再执行种子数据**：
   ```bash
   mysql -u user -p database < sql/seed_data.sql
   ```

## 验证数据

执行种子数据后，可以验证数据是否创建成功：

```sql
-- 检查 BANTU 组织
SELECT 
    id,
    name,
    code,
    organization_type,
    is_active,
    is_locked,
    created_at
FROM organizations 
WHERE code = 'BANTU';
```

## 使用场景

### 创建用户时

所有用户创建都需要指定 `organizationId`，可以使用 BANTU 组织的 ID：

```sql
-- 获取 BANTU 组织 ID
SELECT id FROM organizations WHERE code = 'BANTU';

-- 创建用户时使用此 ID
INSERT INTO users (id, username, email, password_hash, ...)
VALUES (UUID(), 'admin', 'admin@bantu.sbs', '...', ...);

-- 创建组织员工记录
INSERT INTO organization_employees (
    id, user_id, organization_id, is_primary, is_active
)
VALUES (
    UUID(),
    (SELECT id FROM users WHERE email = 'admin@bantu.sbs'),
    (SELECT id FROM organizations WHERE code = 'BANTU'),
    TRUE,
    TRUE
);
```

### 在应用代码中

```java
// 获取 BANTU 组织 ID
String bantuOrgId = organizationMapper.selectByCode("BANTU").getId();

// 创建用户时使用
UserCreateRequest request = new UserCreateRequest();
request.setOrganizationId(bantuOrgId);
// ... 其他字段
userService.createUser(request);
```

## 注意事项

1. **不要删除此组织**：这是系统的根组织，删除会导致用户创建失败
2. **可以修改信息**：可以使用 UPDATE 语句修改组织信息，但不要修改 `id` 和 `code`
3. **示例数据**：部分字段（如工商信息、财务信息）为示例数据，实际使用时需要替换为真实数据
4. **认证状态**：`is_verified` 默认为 `FALSE`，需要管理员手动认证

## 扩展种子数据

如果需要添加更多种子数据（如预设用户、测试数据等），可以在 `seed_data.sql` 文件中继续添加。

建议的扩展：
- 预设管理员用户
- 测试组织（用于开发测试）
- 示例供应商（vendor）
- 示例渠道代理（agent）

