# BANTU CRM 快速参考指南

> 本文档提供快速查找常用信息和代码位置的索引。

## 📋 目录

- [快速查找](#快速查找)
- [常用代码位置](#常用代码位置)
- [API 端点速查](#api-端点速查)
- [数据库表速查](#数据库表速查)
- [常见任务](#常见任务)

---

## 快速查找

### 我想了解...

| 需求 | 查看文档 |
|------|---------|
| 项目整体架构 | [PROJECT_OVERVIEW.md](./PROJECT_OVERVIEW.md) |
| 某个文件的功能 | [FILE_FUNCTION_REFERENCE.md](./FILE_FUNCTION_REFERENCE.md) |
| 如何添加新功能 | [PROJECT_OVERVIEW.md - 开发指南](./PROJECT_OVERVIEW.md#开发指南) |
| API 端点列表 | [本文档 - API 端点速查](#api-端点速查) |
| 数据库表结构 | [本文档 - 数据库表速查](#数据库表速查) |

---

## 常用代码位置

### 前端

#### 添加新页面
1. **创建页面组件**: `crm-bantu-website/src/pages/admin/YourPage.tsx`
2. **添加路由**: `crm-bantu-website/src/App.tsx`
3. **添加菜单**: `crm-bantu-website/src/config/menu.ts`
4. **添加翻译**: `crm-bantu-website/src/i18n/locales/zh-CN.json` 和 `id-ID.json`

#### 添加新 API
1. **创建 API 文件**: `crm-bantu-website/src/api/yourApi.ts`
2. **添加路径定义**: `crm-bantu-website/src/api/config.ts` (API_PATHS)
3. **在页面中使用**: 导入并使用 API 函数

#### 权限控制
- **权限配置**: `crm-bantu-website/src/config/permissions.ts`
- **权限守卫组件**: `crm-bantu-website/src/components/admin/PermissionGuard.tsx`
- **使用示例**: 
  ```tsx
  <PermissionGuard role={Role.ADMIN}>
    <YourComponent />
  </PermissionGuard>
  ```

### 后端

#### 添加新 API 端点
1. **创建路由文件**: `crm-backend-python/foundation_service/api/v1/your_api.py`
2. **创建服务文件**: `crm-backend-python/foundation_service/services/your_service.py`
3. **创建仓库文件**: `crm-backend-python/foundation_service/repositories/your_repository.py`
4. **创建 Schema 文件**: `crm-backend-python/foundation_service/schemas/your_schema.py`
5. **注册路由**: `crm-backend-python/foundation_service/main.py`

#### 添加新数据模型
1. **创建模型文件**: `crm-backend-python/common/models/your_model.py`
2. **导出模型**: `crm-backend-python/common/models/__init__.py`
3. **创建迁移脚本**: `crm-backend-python/init-scripts/migrations/create_your_table.sql`

#### 审计日志
- **自动记录**: 所有 HTTP 请求自动记录（通过中间件）
- **手动记录**: 使用装饰器 `@audit_log(action, resource_type)`
- **查询 API**: `/api/foundation/audit-logs`
- **中间件**: `crm-backend-python/foundation_service/middleware/audit_middleware.py`

---

## API 端点速查

### 认证相关
```
POST   /api/foundation/auth/login          # 登录
POST   /api/foundation/auth/refresh        # 刷新 Token
GET    /api/foundation/auth/user-info      # 获取用户信息
```

### 用户管理
```
GET    /api/foundation/users               # 获取用户列表
POST   /api/foundation/users               # 创建用户
GET    /api/foundation/users/{id}          # 获取用户详情
PUT    /api/foundation/users/{id}          # 更新用户
DELETE /api/foundation/users/{id}          # 删除用户
POST   /api/foundation/users/{id}/enable   # 启用用户
POST   /api/foundation/users/{id}/disable  # 禁用用户
```

### 组织管理
```
GET    /api/foundation/organizations       # 获取组织列表
POST   /api/foundation/organizations       # 创建组织
GET    /api/foundation/organizations/{id}  # 获取组织详情
PUT    /api/foundation/organizations/{id}  # 更新组织
DELETE /api/foundation/organizations/{id}  # 删除组织
```

### 客户管理
```
GET    /api/service-management/customers                    # 获取客户列表
POST   /api/service-management/customers                    # 创建客户
GET    /api/service-management/customers/{id}              # 获取客户详情
PUT    /api/service-management/customers/{id}                # 更新客户
DELETE /api/service-management/customers/{id}               # 删除客户
GET    /api/service-management/customers/{id}/follow-ups    # 获取跟进记录
POST   /api/service-management/customers/{id}/follow-ups    # 创建跟进记录
GET    /api/service-management/customers/{id}/notes         # 获取备注
POST   /api/service-management/customers/{id}/notes         # 创建备注
```

### 订单管理
```
GET    /api/order-workflow/orders              # 获取订单列表
POST   /api/order-workflow/orders              # 创建订单
GET    /api/order-workflow/orders/{id}         # 获取订单详情
PUT    /api/order-workflow/orders/{id}         # 更新订单
POST   /api/order-workflow/orders/{id}/assign  # 分配订单
POST   /api/order-workflow/orders/{id}/update-status  # 更新订单状态
```

### 线索管理
```
GET    /api/order-workflow/leads                              # 获取线索列表
POST   /api/order-workflow/leads                              # 创建线索
GET    /api/order-workflow/leads/{id}                         # 获取线索详情
PUT    /api/order-workflow/leads/{id}                         # 更新线索
POST   /api/order-workflow/leads/{id}/assign                  # 分配线索
POST   /api/order-workflow/leads/{id}/convert-to-customer     # 转换为客户
POST   /api/order-workflow/leads/{id}/convert-to-opportunity # 转换为商机
POST   /api/order-workflow/leads/{id}/move-to-pool            # 移入线索池
POST   /api/order-workflow/leads/check-duplicate              # 检查重复线索
```

### 商机管理
```
GET    /api/order-workflow/opportunities           # 获取商机列表
POST   /api/order-workflow/opportunities           # 创建商机
GET    /api/order-workflow/opportunities/{id}      # 获取商机详情
PUT    /api/order-workflow/opportunities/{id}      # 更新商机
POST   /api/order-workflow/opportunities/{id}/assign      # 分配商机
POST   /api/order-workflow/opportunities/{id}/update-stage # 更新商机阶段
POST   /api/order-workflow/opportunities/{id}/convert      # 转换为订单
```

### 产品管理
```
GET    /api/service-management/products              # 获取产品列表
POST   /api/service-management/products              # 创建产品
GET    /api/service-management/products/{id}         # 获取产品详情
PUT    /api/service-management/products/{id}         # 更新产品
DELETE /api/service-management/products/{id}        # 删除产品
GET    /api/service-management/products/vendors/{vendor_id}  # 获取供应商的产品列表
```

### 价格管理
```
GET    /api/foundation/product-prices                # 获取价格列表
POST   /api/foundation/product-prices               # 创建价格
GET    /api/foundation/product-prices/{id}          # 获取价格详情
PUT    /api/foundation/product-prices/{id}          # 更新价格
DELETE /api/foundation/product-prices/{id}          # 删除价格
POST   /api/foundation/product-prices/batch-update  # 批量更新价格
GET    /api/foundation/product-prices/history/{product_id}  # 获取价格历史
```

### 汇率管理
```
GET    /api/foundation/exchange-rates               # 获取汇率列表
POST   /api/foundation/exchange-rates               # 创建汇率
GET    /api/foundation/exchange-rates/{id}          # 获取汇率详情
PUT    /api/foundation/exchange-rates/{id}          # 更新汇率
GET    /api/foundation/exchange-rates/current       # 获取当前汇率
```

### 审计日志
```
GET    /api/foundation/audit-logs                              # 查询审计日志列表
GET    /api/foundation/audit-logs/{id}                         # 获取审计日志详情
GET    /api/foundation/audit-logs/users/{user_id}             # 查询用户审计日志
GET    /api/foundation/audit-logs/resources/{resource_type}/{resource_id}  # 查询资源审计日志
POST   /api/foundation/audit-logs/export                       # 导出审计日志
```

### 数据分析
```
GET    /api/analytics-monitoring/analytics/sales-statistics   # 销售统计
GET    /api/analytics-monitoring/analytics/order-statistics   # 订单统计
GET    /api/analytics-monitoring/analytics/customer-statistics # 客户统计
GET    /api/analytics-monitoring/analytics/revenue-trend       # 收入趋势
```

### 系统监控
```
GET    /api/analytics-monitoring/monitoring/metrics  # 获取系统指标
GET    /api/analytics-monitoring/monitoring/health   # 健康检查
GET    /api/analytics-monitoring/monitoring/alerts   # 获取预警信息
```

---

## 数据库表速查

### 用户与权限
- `users` - 用户表
- `organizations` - 组织表（租户）
- `roles` - 角色表
- `permissions` - 权限表
- `user_roles` - 用户角色关联表
- `role_permissions` - 角色权限关联表
- `organization_employees` - 组织员工关联表

### 客户管理
- `customers` - 客户表
- `contacts` - 联系人表
- `customer_follow_ups` - 客户跟进记录表
- `customer_notes` - 客户备注表
- `customer_sources` - 客户来源表
- `customer_channels` - 客户渠道表
- `customer_levels` - 客户等级表
- `industries` - 行业表

### 订单与工作流
- `orders` - 订单表
- `order_items` - 订单项表
- `order_comments` - 订单评论表
- `order_files` - 订单文件表
- `leads` - 线索表
- `lead_follow_ups` - 线索跟进记录表
- `lead_notes` - 线索备注表
- `lead_pools` - 线索池表
- `opportunities` - 商机表
- `opportunity_products` - 商机产品关联表
- `opportunity_payment_stages` - 商机付款阶段表
- `workflow_definitions` - 工作流定义表
- `workflow_instances` - 工作流实例表
- `workflow_tasks` - 工作流任务表
- `workflow_transitions` - 工作流转换表

### 产品与服务
- `products` - 产品表
- `product_categories` - 产品分类表
- `product_dependencies` - 产品依赖关系表
- `vendor_products` - 供应商产品表
- `service_types` - 服务类型表
- `service_records` - 服务记录表

### 价格管理
- `product_prices` - 产品价格表
- `product_price_history` - 价格历史记录表
- `exchange_rate_history` - 汇率历史记录表
- `price_change_logs` - 价格变更日志表
- `customer_level_prices` - 客户等级价格表
- `order_price_snapshots` - 订单价格快照表
- `vendor_product_financial` - 供应商产品财务信息表

### 其他
- `audit_logs` - 审计日志表
- `notifications` - 通知表
- `collection_tasks` - 催款任务表
- `temporary_links` - 临时链接表
- `follow_up_statuses` - 跟进状态表

---

## 常见任务

### 1. 添加新的管理页面

**前端步骤**:
1. 在 `crm-bantu-website/src/pages/admin/` 创建页面组件
2. 在 `crm-bantu-website/src/App.tsx` 添加路由：
   ```tsx
   <Route
     path="/admin/your-module/list"
     element={
       <AdminLayout>
         <PermissionGuard role={Role.ADMIN}>
           <YourPage />
         </PermissionGuard>
       </AdminLayout>
     }
   />
   ```
3. 在 `crm-bantu-website/src/config/menu.ts` 添加菜单项
4. 在 `crm-bantu-website/src/i18n/locales/zh-CN.json` 添加翻译

**后端步骤**:
1. 创建 API 路由文件 `foundation_service/api/v1/your_api.py`
2. 创建服务文件 `foundation_service/services/your_service.py`
3. 创建仓库文件 `foundation_service/repositories/your_repository.py`
4. 创建 Schema 文件 `foundation_service/schemas/your_schema.py`
5. 在 `foundation_service/main.py` 注册路由：
   ```python
   app.include_router(your_api.router, prefix="/api/your-module/your-resource", tags=["Your Module"])
   ```

### 2. 添加新的数据模型

**步骤**:
1. 在 `crm-backend-python/common/models/` 创建模型文件 `your_model.py`
2. 定义 SQLAlchemy 模型类
3. 在 `crm-backend-python/common/models/__init__.py` 导出模型
4. 创建数据库迁移脚本 `crm-backend-python/init-scripts/migrations/create_your_table.sql`
5. 执行迁移脚本

### 3. 添加权限控制

**前端**:
```tsx
import { PermissionGuard } from './components/admin/PermissionGuard'
import { Role } from './config/permissions'

<PermissionGuard role={Role.ADMIN}>
  <YourComponent />
</PermissionGuard>
```

**后端**:
```python
from foundation_service.dependencies import get_current_user, require_role

@router.get("/")
async def your_endpoint(
    current_user: User = Depends(require_role(["ADMIN"]))
):
    # 只有 ADMIN 角色可以访问
    pass
```

### 4. 记录审计日志

**自动记录**:
- 所有 HTTP 请求自动记录（通过中间件）
- 无需额外代码

**手动记录**:
```python
from foundation_service.decorators.audit_log import audit_log

@audit_log(action="CREATE", resource_type="CUSTOMER")
async def create_customer(data: CustomerCreate):
    # 创建客户
    pass
```

### 5. 添加价格管理功能

**相关文件**:
- 前端: `crm-bantu-website/src/pages/admin/PriceManagement.tsx`
- 后端 API: `crm-backend-python/foundation_service/api/v1/product_prices.py`
- 后端服务: `crm-backend-python/foundation_service/services/product_price_service.py`
- 数据模型: `crm-backend-python/common/models/product_price.py`

**价格计算**:
```python
from foundation_service.services.product_price_service import ProductPriceService

price_service = ProductPriceService()
price = await price_service.calculate_price(
    product_id=product_id,
    customer_level_id=customer_level_id,
    currency="IDR"
)
```

### 6. 多租户数据隔离

**原则**:
- 所有业务表都有 `organization_id` 字段
- 查询时自动过滤 `organization_id`
- 用户只能访问自己所属组织的数据

**实现**:
```python
# 在 Repository 中自动过滤
async def get_all(self, organization_id: str, params: dict):
    query = select(self.model).where(
        self.model.organization_id == organization_id
    )
    # ...
```

### 7. 多语言支持

**前端**:
```tsx
import { useTranslation } from 'react-i18next'

const { t } = useTranslation()
<h1>{t('menu.dashboard')}</h1>
```

**添加翻译**:
1. 在 `crm-bantu-website/src/i18n/locales/zh-CN.json` 添加中文翻译
2. 在 `crm-bantu-website/src/i18n/locales/id-ID.json` 添加印尼语翻译

**后端**:
```python
from foundation_service.utils.i18n import get_text

message = get_text("error.user_not_found", lang="zh-CN")
```

---

## 重要提示

### 开发环境
- 前端开发: `cd crm-bantu-website && npm run dev`
- 后端开发: `cd crm-backend-python/foundation_service && uvicorn main:app --reload`
- API 文档: `http://localhost:8081/docs`

### 代码规范
- 前端: TypeScript + ESLint
- 后端: Python + Black + Ruff
- 提交前运行 lint 检查

### 数据库迁移
- 所有数据库变更必须通过迁移脚本
- 迁移脚本命名: `YYYYMMDD_description.sql`
- 确保迁移脚本可以重复执行

### 测试
- 前端: 暂无测试（待添加）
- 后端: pytest（待完善）

---

**最后更新**: 2024-11-09
