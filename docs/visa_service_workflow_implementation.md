# 签证服务业务流程实现说明

## 业务流程数据流

### 1. 销售（SALES）创建订单流程

```sql
-- 步骤1: 创建/查找客户（企业或个人）
INSERT INTO customers (name, customer_type, customer_source_type, ...)
VALUES (...);

-- 步骤2: 创建订单
INSERT INTO orders (
  order_number, title,
  customer_id, product_id, sales_user_id,
  quantity, unit_price, total_amount, final_amount,
  status_code, requirements, customer_notes
)
VALUES (...);

-- 步骤3: 订单状态自动为 'submitted'（已提交）
-- 系统自动创建初始订单状态记录
```

### 2. 做单人员（OPERATION）接单流程

```sql
-- 步骤1: 查看待分配的订单
SELECT o.*, c.name as customer_name, p.name as product_name
FROM orders o
JOIN customers c ON c.id = o.customer_id
LEFT JOIN products p ON p.id = o.product_id
WHERE o.status_code = 'submitted';

-- 步骤2: 分配订单给做单人员
INSERT INTO order_assignments (
  order_id, assigned_to_user_id, assigned_by_user_id, assignment_type
)
VALUES (:order_id, :operation_user_id, :assigner_user_id, 'operation');

-- 步骤3: 更新订单状态
UPDATE orders 
SET status_code = 'assigned', 
    status_id = (SELECT id FROM order_statuses WHERE code = 'assigned')
WHERE id = :order_id;

-- 步骤4: 创建订单阶段（如：资料审核、办理中、交付等）
INSERT INTO order_stages (order_id, stage_name, stage_code, stage_order, status)
VALUES 
  (:order_id, '资料审核', 'doc_review', 1, 'pending'),
  (:order_id, '办理中', 'processing', 2, 'pending'),
  (:order_id, '交付', 'delivery', 3, 'pending');
```

### 3. 分阶段做单流程

```sql
-- 步骤1: 开始某个阶段
UPDATE order_stages 
SET status = 'in_progress',
    started_at = NOW(),
    assigned_to_user_id = :user_id,
    updated_by = :user_id
WHERE id = :stage_id;

-- 步骤2: 更新阶段进度
UPDATE order_stages 
SET progress_percent = :progress,
    notes = :notes,
    updated_by = :user_id
WHERE id = :stage_id;

-- 步骤3: 完成阶段
UPDATE order_stages 
SET status = 'completed',
    completed_at = NOW(),
    progress_percent = 100,
    updated_by = :user_id
WHERE id = :stage_id;
```

### 4. 交付成果流程

```sql
-- 步骤1: 上传交付物
INSERT INTO deliverables (
  order_id, order_stage_id,
  deliverable_type, name, description,
  file_path, file_url, file_size, mime_type,
  uploaded_by
)
VALUES (...);

-- 步骤2: 验证交付物（可选）
UPDATE deliverables 
SET is_verified = TRUE,
    verified_by = :verifier_id,
    verified_at = NOW()
WHERE id = :deliverable_id;
```

### 5. 收款流程

```sql
-- 步骤1: 记录收款
INSERT INTO payments (
  order_id,
  payment_type, amount, currency_code,
  payment_method, payment_date, received_at,
  transaction_id, payer_name,
  status, created_by
)
VALUES (...);

-- 步骤2: 确认收款（财务人员）
UPDATE payments 
SET status = 'confirmed',
    confirmed_by = :finance_user_id,
    confirmed_at = NOW()
WHERE id = :payment_id;

-- 步骤3: 完成订单（所有阶段完成且收款确认后）
UPDATE orders 
SET status_code = 'completed',
    status_id = (SELECT id FROM order_statuses WHERE code = 'completed'),
    actual_completion_date = CURRENT_DATE
WHERE id = :order_id
  AND NOT EXISTS (
    SELECT 1 FROM order_stages 
    WHERE order_id = :order_id AND status != 'completed'
  );
```

## 查询示例

### 销售查看自己的订单

```sql
SELECT o.*, c.name as customer_name, os.name as status_name
FROM orders o
JOIN customers c ON c.id = o.customer_id
LEFT JOIN order_statuses os ON os.id = o.status_id
WHERE o.sales_user_id = :sales_user_id
ORDER BY o.created_at DESC;
```

### 做单人员查看分配给自己的订单

```sql
SELECT DISTINCT o.*, c.name as customer_name, p.name as product_name
FROM orders o
JOIN customers c ON c.id = o.customer_id
LEFT JOIN products p ON p.id = o.product_id
JOIN order_assignments oa ON oa.order_id = o.id
WHERE oa.assigned_to_user_id = :operation_user_id
  AND oa.unassigned_at IS NULL
  AND o.status_code IN ('assigned', 'in_progress')
ORDER BY o.created_at DESC;
```

### 查看订单进度

```sql
SELECT os.*, u.display_name as assigned_to_name
FROM order_stages os
LEFT JOIN users u ON u.id = os.assigned_to_user_id
WHERE os.order_id = :order_id
ORDER BY os.stage_order;
```

### 查看订单交付物

```sql
SELECT d.*, u.display_name as uploaded_by_name
FROM deliverables d
LEFT JOIN users u ON u.id = d.uploaded_by
WHERE d.order_id = :order_id
ORDER BY d.created_at DESC;
```

### 查看订单收款情况

```sql
SELECT p.*, 
       SUM(p.amount) FILTER (WHERE p.status = 'confirmed') OVER (PARTITION BY p.order_id) as total_received
FROM payments p
WHERE p.order_id = :order_id
ORDER BY p.payment_date DESC;
```

## 业务逻辑验证

### ✅ 支持的功能

1. **销售创建客户** ✅
   - `customers` 表支持企业/个人（customer_type）
   - 支持多租户隔离

2. **销售创建订单** ✅
   - `orders` 表连接客户、产品、销售
   - 支持订单编号、金额、状态管理

3. **一个客户多个服务记录** ✅
   - `orders` 表通过 `customer_id` 关联
   - 一个客户可以有多个订单

4. **做单人员接单** ✅
   - `order_assignments` 表记录分配关系
   - 支持查看分配给自己的订单

5. **分阶段做单** ✅
   - `order_stages` 表记录各阶段
   - 支持进度跟踪（progress_percent）
   - 支持阶段状态（pending/in_progress/completed）

6. **交付成果** ✅
   - `deliverables` 表存储交付物
   - 支持文件路径、URL、验证状态

7. **收款** ✅
   - `payments` 表记录收款信息
   - 支持部分收款、全款、退款
   - 支持收款确认流程

## 总结

✅ **数据库设计完全支持签证服务的业务流程！**

所有核心功能都已通过表结构实现：
- 客户管理（支持企业/个人）
- 订单创建和管理
- 订单分配和跟踪
- 分阶段进度管理
- 交付物管理
- 收款管理

可以使用 `sql/0007_orders_schema.sql` 创建这些表结构。

