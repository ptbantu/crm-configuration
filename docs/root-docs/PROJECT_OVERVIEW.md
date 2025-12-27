# BANTU CRM 项目概览文档

> 本文档旨在帮助 AI Agent 和开发者快速理解 BANTU CRM 系统的整体架构、文件结构和功能模块。

## 📋 目录

- [项目概述](#项目概述)
- [技术架构](#技术架构)
- [项目结构](#项目结构)
- [核心功能模块](#核心功能模块)
- [数据库模型](#数据库模型)
- [API 结构](#api-结构)
- [文件功能说明](#文件功能说明)
- [开发指南](#开发指南)

---

## 项目概述

BANTU CRM 是一个企业级客户关系管理系统，为班兔企业服务提供全流程的 CRM 解决方案。系统采用前后端分离架构，支持多租户、多语言、多角色权限管理。

### 核心特性

- ✅ **多租户架构**：每个公司/组织作为独立租户，数据完全隔离
- ✅ **权限系统**：基于角色的权限控制（RBAC）
- ✅ **审计日志**：自动记录所有用户操作，支持查询和导出
- ✅ **工作流引擎**：支持业务流程管理和自动化流转
- ✅ **价格管理**：支持多币种、汇率管理、价格历史记录
- ✅ **多语言支持**：中文、印尼语
- ✅ **响应式设计**：支持 Web 端和移动端

### 用户角色

- **ADMIN**：系统管理员，拥有所有权限
- **SALES**：内部销售，负责客户开发和订单创建
- **AGENT**：渠道代理销售，管理渠道客户
- **OPERATION**：做单人员，负责订单执行
- **FINANCE**：财务人员，负责应收应付和报表

---

## 技术架构

### 前端技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| React | 18.2.0 | UI 框架 |
| TypeScript | 5.2.2 | 类型安全 |
| Vite | 6.0.9 | 构建工具 |
| React Router | 6.20.0 | 路由管理 |
| Tailwind CSS | 3.3.6 | 样式框架 |
| React i18next | 13.5.0 | 国际化 |
| Chakra UI | 2.8.2 | UI 组件库 |
| Recharts | 3.5.1 | 图表库 |

### 后端技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| FastAPI | 0.104.1 | Web 框架 |
| SQLAlchemy | 2.0.23 | ORM（异步） |
| Pydantic | 2.5.0 | 数据验证 |
| MySQL | - | 主数据库（业务数据） |
| MongoDB | - | 日志存储（应用日志） |
| Redis | 5.0.1 | 缓存和会话管理 |
| Motor | 3.3.2 | MongoDB 异步驱动 |
| python-jose | 3.3.0 | JWT 认证 |

### 基础设施

- **容器化**：Docker + Kubernetes
- **CI/CD**：Jenkins + Harbor
- **对象存储**：阿里云 OSS / MinIO
- **监控**：Prometheus + Grafana

---

## 项目结构

```
/home/bantu/
├── crm-bantu-website/          # 前端项目
├── crm-backend-python/         # 后端项目
├── crm-configuration/          # 配置项目
└── bantu-data/                 # 数据文件（MySQL 数据文件）
```

### 1. 前端项目 (`crm-bantu-website`)

```
crm-bantu-website/
├── src/
│   ├── api/                    # API 客户端封装
│   │   ├── auth.ts            # 认证相关 API
│   │   ├── users.ts           # 用户管理 API
│   │   ├── organizations.ts   # 组织管理 API
│   │   ├── customers.ts       # 客户管理 API
│   │   ├── orders.ts          # 订单管理 API
│   │   ├── leads.ts           # 线索管理 API
│   │   ├── opportunities.ts  # 商机管理 API
│   │   ├── products.ts        # 产品管理 API
│   │   ├── prices.ts          # 价格管理 API
│   │   ├── auditLogs.ts       # 审计日志 API
│   │   └── config.ts          # API 配置
│   ├── components/            # 组件
│   │   ├── admin/             # 管理后台组件
│   │   │   ├── Sidebar.tsx    # 侧边栏导航
│   │   │   ├── TopBar.tsx     # 顶部栏
│   │   │   ├── PermissionGuard.tsx  # 权限守卫
│   │   │   ├── price/         # 价格管理组件
│   │   │   └── product/       # 产品管理组件
│   │   ├── Header.tsx         # 官网头部
│   │   ├── Footer.tsx         # 官网页脚
│   │   └── Toast.tsx          # 消息提示
│   ├── pages/                 # 页面组件
│   │   ├── Home.tsx           # 官网首页
│   │   ├── About.tsx          # 关于我们
│   │   ├── Services.tsx       # 服务介绍
│   │   ├── Contact.tsx        # 联系我们
│   │   ├── Login.tsx          # 登录页
│   │   ├── Dashboard.tsx      # 仪表板
│   │   └── admin/              # 管理后台页面
│   │       ├── CustomerList.tsx      # 客户列表
│   │       ├── CustomerDetail.tsx    # 客户详情
│   │       ├── OrderList.tsx         # 订单列表
│   │       ├── OrderDetail.tsx       # 订单详情
│   │       ├── LeadList.tsx          # 线索列表
│   │       ├── LeadDetail.tsx        # 线索详情
│   │       ├── OpportunityList.tsx   # 商机列表
│   │       ├── OpportunityDetail.tsx # 商机详情
│   │       ├── ProductManagement.tsx # 产品管理
│   │       ├── PriceManagement.tsx    # 价格管理
│   │       ├── EmployeeList.tsx      # 员工列表
│   │       ├── RoleManagement.tsx    # 角色管理
│   │       ├── Organizations.tsx     # 组织管理
│   │       ├── AuditLogs.tsx         # 审计日志
│   │       └── SystemStatus.tsx      # 系统状态
│   ├── config/                # 配置文件
│   │   ├── menu.ts            # 菜单配置
│   │   └── permissions.ts     # 权限配置
│   ├── contexts/              # Context 上下文
│   │   ├── AuthContext.tsx    # 认证上下文
│   │   ├── SidebarContext.tsx # 侧边栏上下文
│   │   └── TabsContext.tsx    # 标签页上下文
│   ├── hooks/                 # 自定义 Hooks
│   │   ├── useAuth.ts         # 认证 Hook
│   │   └── useMenu.ts         # 菜单 Hook
│   ├── layouts/               # 布局组件
│   │   └── AdminLayout.tsx    # 管理后台布局
│   ├── i18n/                  # 国际化
│   │   ├── config.ts          # i18n 配置
│   │   └── locales/           # 翻译文件
│   │       ├── zh-CN.json     # 中文
│   │       └── id-ID.json     # 印尼语
│   ├── utils/                 # 工具函数
│   │   ├── cn.ts              # className 合并
│   │   ├── formatPrice.ts     # 价格格式化
│   │   └── storage.ts          # 本地存储
│   ├── App.tsx                # 主应用组件
│   └── main.tsx               # 入口文件
├── public/                    # 静态资源
├── k8s/                       # Kubernetes 配置
├── package.json               # 依赖配置
└── vite.config.ts             # Vite 配置
```

### 2. 后端项目 (`crm-backend-python`)

```
crm-backend-python/
├── common/                    # 公共模块
│   ├── models/                # 共享数据模型
│   │   ├── user.py           # 用户模型
│   │   ├── organization.py   # 组织模型
│   │   ├── role.py           # 角色模型
│   │   ├── customer.py       # 客户模型
│   │   ├── order.py          # 订单模型
│   │   ├── lead.py           # 线索模型
│   │   ├── opportunity.py    # 商机模型
│   │   ├── product.py        # 产品模型
│   │   ├── product_price.py  # 价格模型
│   │   ├── audit_log.py      # 审计日志模型
│   │   └── ...               # 其他模型
│   ├── utils/                # 工具类
│   │   ├── repository.py     # Repository 基类
│   │   └── service.py        # Service 基类
│   ├── database.py           # 数据库连接
│   ├── redis_client.py       # Redis 客户端
│   └── mongodb_client.py     # MongoDB 客户端
├── foundation_service/        # 基础服务（单体服务）
│   ├── api/v1/               # API 路由
│   │   ├── auth.py           # 认证 API
│   │   ├── users.py           # 用户管理 API
│   │   ├── organizations.py   # 组织管理 API
│   │   ├── roles.py           # 角色管理 API
│   │   ├── customers.py       # 客户管理 API
│   │   ├── orders.py          # 订单管理 API
│   │   ├── leads.py           # 线索管理 API
│   │   ├── opportunities.py  # 商机管理 API
│   │   ├── products.py        # 产品管理 API
│   │   ├── product_prices.py  # 价格管理 API
│   │   ├── audit_logs.py      # 审计日志 API
│   │   ├── analytics.py       # 数据分析 API
│   │   ├── monitoring.py      # 系统监控 API
│   │   └── logs.py            # 日志查询 API
│   ├── services/              # 业务服务层
│   │   ├── auth_service.py    # 认证服务
│   │   ├── user_service.py    # 用户服务
│   │   ├── customer_service.py # 客户服务
│   │   ├── order_service.py   # 订单服务
│   │   ├── lead_service.py    # 线索服务
│   │   ├── opportunity_service.py # 商机服务
│   │   ├── product_service.py # 产品服务
│   │   ├── price_service.py   # 价格服务
│   │   ├── audit_service.py   # 审计服务
│   │   └── ...               # 其他服务
│   ├── repositories/         # 数据访问层
│   │   ├── user_repository.py # 用户仓库
│   │   ├── customer_repository.py # 客户仓库
│   │   ├── order_repository.py # 订单仓库
│   │   └── ...               # 其他仓库
│   ├── schemas/               # Pydantic Schema
│   │   ├── auth.py            # 认证 Schema
│   │   ├── user.py            # 用户 Schema
│   │   ├── customer.py        # 客户 Schema
│   │   └── ...               # 其他 Schema
│   ├── middleware/            # 中间件
│   │   ├── audit_middleware.py # 审计日志中间件
│   │   └── access_log_filter.py # 访问日志过滤
│   ├── utils/                 # 工具函数
│   │   ├── jwt.py             # JWT 工具
│   │   ├── password.py        # 密码工具
│   │   └── audit_decorator.py # 审计装饰器
│   ├── config.py              # 服务配置
│   ├── database.py            # 数据库初始化
│   └── main.py                # 应用入口
├── init-scripts/              # 数据库初始化脚本
│   ├── schema.sql             # 数据库 Schema
│   ├── seed_data.sql          # 种子数据
│   └── migrations/            # 数据库迁移脚本
│       ├── create_audit_logs_table.sql
│       ├── create_product_prices_table.sql
│       └── ...               # 其他迁移脚本
├── docs/                      # 项目文档
│   ├── api/                   # API 文档
│   └── ...                   # 其他文档
├── k8s/                       # Kubernetes 配置
├── requirements.txt           # Python 依赖
└── Dockerfile                 # Docker 配置
```

### 3. 配置项目 (`crm-configuration`)

```
crm-configuration/
├── config/                    # 配置文件
│   └── database.yml           # 数据库配置
├── k8s/                       # Kubernetes 配置
│   ├── helm/                  # Helm Charts
│   ├── mysql/                 # MySQL 配置
│   ├── mongodb/               # MongoDB 配置
│   ├── redis/                 # Redis 配置
│   └── crm-services/          # CRM 服务配置
├── docs/                      # 文档
│   ├── module_architecture.md # 模块架构
│   ├── visa_service_workflow_implementation.md # 业务流程
│   └── customer_classification_guide.md # 客户分类指南
└── data-excel/                # Excel 数据文件
```

---

## 核心功能模块

### 1. Foundation Service（基础服务）

**功能**：
- 用户认证与登录（JWT）
- 用户管理（CRUD）
- 组织管理（多租户）
- 角色权限管理（RBAC）
- 审计日志（自动记录所有操作）

**关键文件**：
- `foundation_service/api/v1/auth.py` - 认证 API
- `foundation_service/api/v1/users.py` - 用户管理 API
- `foundation_service/api/v1/organizations.py` - 组织管理 API
- `foundation_service/api/v1/audit_logs.py` - 审计日志 API
- `foundation_service/middleware/audit_middleware.py` - 审计中间件

### 2. Order Workflow Service（订单与工作流）

**功能**：
- 订单管理（创建、查询、更新、分配）
- 订单项管理
- 订单评论和文件管理
- 线索管理（创建、跟进、转换）
- 商机管理（创建、跟进、转换）
- 工作流管理（Activiti）
- 催款任务管理
- 临时链接生成

**关键文件**：
- `foundation_service/api/v1/orders.py` - 订单 API
- `foundation_service/api/v1/leads.py` - 线索 API
- `foundation_service/api/v1/opportunities.py` - 商机 API
- `foundation_service/services/order_service.py` - 订单服务
- `foundation_service/services/lead_service.py` - 线索服务

### 3. Service Management（服务管理）

**功能**：
- 客户管理（CRUD、跟进、备注）
- 联系人管理
- 产品/服务管理
- 产品分类管理
- 供应商管理
- 供应商产品管理
- 服务记录管理
- 行业管理
- 客户来源管理

**关键文件**：
- `foundation_service/api/v1/customers.py` - 客户 API
- `foundation_service/api/v1/products.py` - 产品 API
- `foundation_service/api/v1/suppliers.py` - 供应商 API
- `foundation_service/services/customer_service.py` - 客户服务
- `foundation_service/services/product_service.py` - 产品服务

### 4. Price Management（价格管理）

**功能**：
- 产品价格管理（定价、渠道价、成本价）
- 汇率管理
- 价格变更日志
- 价格历史记录
- 客户等级价格
- 批量价格编辑

**关键文件**：
- `foundation_service/api/v1/product_prices.py` - 价格 API
- `foundation_service/api/v1/exchange_rates.py` - 汇率 API
- `foundation_service/api/v1/price_change_logs.py` - 价格变更日志 API
- `foundation_service/services/product_price_service.py` - 价格服务
- `foundation_service/services/exchange_rate_service.py` - 汇率服务

### 5. Analytics & Monitoring（数据分析与监控）

**功能**：
- 数据分析（销售统计、订单统计、客户分析）
- 系统监控（CPU、内存、错误率）
- 日志查询（MongoDB 日志查询）
- 预警管理

**关键文件**：
- `foundation_service/api/v1/analytics.py` - 数据分析 API
- `foundation_service/api/v1/monitoring.py` - 系统监控 API
- `foundation_service/api/v1/logs.py` - 日志查询 API
- `foundation_service/services/analytics_service.py` - 分析服务
- `foundation_service/services/monitoring_service.py` - 监控服务

---

## 数据库模型

### 核心业务模型

#### 用户与权限
- **User** (`common/models/user.py`) - 用户表
- **Organization** (`common/models/organization.py`) - 组织表（租户）
- **Role** (`common/models/role.py`) - 角色表
- **Permission** (`common/models/permission.py`) - 权限表
- **UserRole** (`common/models/user_role.py`) - 用户角色关联表
- **RolePermission** (`common/models/permission.py`) - 角色权限关联表
- **OrganizationEmployee** (`common/models/organization_employee.py`) - 组织员工关联表

#### 客户管理
- **Customer** (`common/models/customer.py`) - 客户表
- **Contact** (`common/models/contact.py`) - 联系人表
- **CustomerFollowUp** (`common/models/customer_follow_up.py`) - 客户跟进记录
- **CustomerNote** (`common/models/customer_note.py`) - 客户备注
- **CustomerSource** (`common/models/customer_source.py`) - 客户来源
- **CustomerChannel** (`common/models/customer_channel.py`) - 客户渠道
- **CustomerLevel** (`common/models/customer_level.py`) - 客户等级
- **Industry** (`common/models/industry.py`) - 行业

#### 订单与工作流
- **Order** (`common/models/order.py`) - 订单表
- **OrderItem** (`common/models/order_item.py`) - 订单项表
- **OrderComment** (`common/models/order_comment.py`) - 订单评论
- **OrderFile** (`common/models/order_file.py`) - 订单文件
- **Lead** (`common/models/lead.py`) - 线索表
- **LeadFollowUp** (`common/models/lead_follow_up.py`) - 线索跟进记录
- **LeadNote** (`common/models/lead_note.py`) - 线索备注
- **LeadPool** (`common/models/lead_pool.py`) - 线索池
- **Opportunity** (`common/models/opportunity.py`) - 商机表
- **OpportunityProduct** (`common/models/opportunity.py`) - 商机产品关联表
- **OpportunityPaymentStage** (`common/models/opportunity.py`) - 商机付款阶段
- **WorkflowDefinition** (`common/models/workflow_definition.py`) - 工作流定义
- **WorkflowInstance** (`common/models/workflow_instance.py`) - 工作流实例
- **WorkflowTask** (`common/models/workflow_task.py`) - 工作流任务
- **WorkflowTransition** (`common/models/workflow_transition.py`) - 工作流转换

#### 产品与服务
- **Product** (`common/models/product.py`) - 产品表
- **ProductCategory** (`common/models/product_category.py`) - 产品分类表
- **ProductDependency** (`common/models/product_dependency.py`) - 产品依赖关系
- **VendorProduct** (`common/models/vendor_product.py`) - 供应商产品表
- **ServiceType** (`common/models/service_type.py`) - 服务类型表
- **ServiceRecord** (`common/models/service_record.py`) - 服务记录表

#### 价格管理
- **ProductPrice** (`common/models/product_price.py`) - 产品价格表
- **ProductPriceHistory** (`common/models/product_price_history.py`) - 价格历史记录
- **ExchangeRateHistory** (`common/models/exchange_rate_history.py`) - 汇率历史记录
- **PriceChangeLog** (`common/models/price_change_log.py`) - 价格变更日志
- **CustomerLevelPrice** (`common/models/customer_level_price.py`) - 客户等级价格
- **OrderPriceSnapshot** (`common/models/order_price_snapshot.py`) - 订单价格快照
- **VendorProductFinancial** (`common/models/vendor_product_financial.py`) - 供应商产品财务信息

#### 其他
- **AuditLog** (`common/models/audit_log.py`) - 审计日志表
- **Notification** (`common/models/notification.py`) - 通知表
- **CollectionTask** (`common/models/collection_task.py`) - 催款任务表
- **TemporaryLink** (`common/models/temporary_link.py`) - 临时链接表
- **FollowUpStatus** (`common/models/follow_up_status.py`) - 跟进状态表

---

## API 结构

### API 路径前缀

- `/api/foundation/*` - 基础服务 API
- `/api/order-workflow/*` - 订单与工作流 API
- `/api/service-management/*` - 服务管理 API
- `/api/analytics-monitoring/*` - 数据分析与监控 API

### 主要 API 端点

#### 认证相关
- `POST /api/foundation/auth/login` - 用户登录
- `GET /api/foundation/auth/user-info` - 获取用户信息
- `POST /api/foundation/auth/refresh` - 刷新 Token

#### 用户管理
- `GET /api/foundation/users` - 获取用户列表
- `POST /api/foundation/users` - 创建用户
- `GET /api/foundation/users/{id}` - 获取用户详情
- `PUT /api/foundation/users/{id}` - 更新用户
- `DELETE /api/foundation/users/{id}` - 删除用户

#### 组织管理
- `GET /api/foundation/organizations` - 获取组织列表
- `POST /api/foundation/organizations` - 创建组织
- `GET /api/foundation/organizations/{id}` - 获取组织详情
- `PUT /api/foundation/organizations/{id}` - 更新组织

#### 客户管理
- `GET /api/service-management/customers` - 获取客户列表
- `POST /api/service-management/customers` - 创建客户
- `GET /api/service-management/customers/{id}` - 获取客户详情
- `PUT /api/service-management/customers/{id}` - 更新客户

#### 订单管理
- `GET /api/order-workflow/orders` - 获取订单列表
- `POST /api/order-workflow/orders` - 创建订单
- `GET /api/order-workflow/orders/{id}` - 获取订单详情
- `PUT /api/order-workflow/orders/{id}` - 更新订单
- `POST /api/order-workflow/orders/{id}/assign` - 分配订单

#### 线索管理
- `GET /api/order-workflow/leads` - 获取线索列表
- `POST /api/order-workflow/leads` - 创建线索
- `GET /api/order-workflow/leads/{id}` - 获取线索详情
- `POST /api/order-workflow/leads/{id}/convert-to-customer` - 转换为客户
- `POST /api/order-workflow/leads/{id}/convert-to-opportunity` - 转换为商机

#### 产品管理
- `GET /api/service-management/products` - 获取产品列表
- `POST /api/service-management/products` - 创建产品
- `GET /api/service-management/products/{id}` - 获取产品详情
- `PUT /api/service-management/products/{id}` - 更新产品

#### 价格管理
- `GET /api/foundation/product-prices` - 获取价格列表
- `POST /api/foundation/product-prices` - 创建价格
- `PUT /api/foundation/product-prices/{id}` - 更新价格
- `GET /api/foundation/exchange-rates` - 获取汇率列表
- `GET /api/foundation/price-change-logs` - 获取价格变更日志

#### 审计日志
- `GET /api/foundation/audit-logs` - 查询审计日志
- `GET /api/foundation/audit-logs/{id}` - 获取审计日志详情
- `GET /api/foundation/audit-logs/users/{user_id}` - 查询用户审计日志
- `POST /api/foundation/audit-logs/export` - 导出审计日志

---

## 文件功能说明

### 前端关键文件

#### API 客户端 (`src/api/`)

| 文件 | 功能 |
|------|------|
| `auth.ts` | 用户认证相关 API（登录、获取用户信息） |
| `users.ts` | 用户管理 API（CRUD） |
| `organizations.ts` | 组织管理 API（CRUD） |
| `customers.ts` | 客户管理 API（CRUD、跟进、备注） |
| `orders.ts` | 订单管理 API（CRUD、分配、评论、文件） |
| `leads.ts` | 线索管理 API（CRUD、转换、跟进） |
| `opportunities.ts` | 商机管理 API（CRUD、转换、跟进） |
| `products.ts` | 产品管理 API（CRUD） |
| `prices.ts` | 价格管理 API（CRUD、历史记录） |
| `exchangeRates.ts` | 汇率管理 API |
| `auditLogs.ts` | 审计日志 API（查询、导出） |
| `config.ts` | API 配置（基础 URL、路径定义） |
| `client.ts` | HTTP 客户端封装（请求拦截、错误处理） |

#### 页面组件 (`src/pages/`)

| 文件 | 功能 |
|------|------|
| `Home.tsx` | 官网首页 |
| `About.tsx` | 关于我们页面 |
| `Services.tsx` | 服务介绍页面 |
| `Contact.tsx` | 联系我们页面 |
| `Login.tsx` | 用户登录页面 |
| `Dashboard.tsx` | 管理后台仪表板 |
| `admin/CustomerList.tsx` | 客户列表页面 |
| `admin/CustomerDetail.tsx` | 客户详情页面 |
| `admin/OrderList.tsx` | 订单列表页面 |
| `admin/OrderDetail.tsx` | 订单详情页面 |
| `admin/LeadList.tsx` | 线索列表页面 |
| `admin/LeadDetail.tsx` | 线索详情页面 |
| `admin/OpportunityList.tsx` | 商机列表页面 |
| `admin/OpportunityDetail.tsx` | 商机详情页面 |
| `admin/ProductManagement.tsx` | 产品管理页面 |
| `admin/PriceManagement.tsx` | 价格管理页面 |
| `admin/EmployeeList.tsx` | 员工列表页面 |
| `admin/RoleManagement.tsx` | 角色管理页面 |
| `admin/Organizations.tsx` | 组织管理页面 |
| `admin/AuditLogs.tsx` | 审计日志页面 |
| `admin/SystemStatus.tsx` | 系统状态页面 |

#### 配置 (`src/config/`)

| 文件 | 功能 |
|------|------|
| `menu.ts` | 菜单配置（菜单项、权限要求、图标） |
| `permissions.ts` | 权限配置（角色枚举、权限枚举） |

#### 上下文 (`src/contexts/`)

| 文件 | 功能 |
|------|------|
| `AuthContext.tsx` | 认证上下文（用户信息、登录状态） |
| `SidebarContext.tsx` | 侧边栏上下文（展开/收起状态） |
| `TabsContext.tsx` | 标签页上下文（多标签页管理） |

### 后端关键文件

#### API 路由 (`foundation_service/api/v1/`)

| 文件 | 功能 |
|------|------|
| `auth.py` | 认证 API（登录、刷新 Token、获取用户信息） |
| `users.py` | 用户管理 API（CRUD、启用/禁用） |
| `organizations.py` | 组织管理 API（CRUD） |
| `roles.py` | 角色管理 API（CRUD、权限分配） |
| `permissions.py` | 权限管理 API（查询权限列表） |
| `customers.py` | 客户管理 API（CRUD、跟进、备注） |
| `contacts.py` | 联系人管理 API（CRUD） |
| `orders.py` | 订单管理 API（CRUD、分配、状态更新） |
| `order_items.py` | 订单项管理 API（CRUD） |
| `order_comments.py` | 订单评论 API（CRUD、回复、置顶） |
| `order_files.py` | 订单文件 API（上传、下载、验证） |
| `leads.py` | 线索管理 API（CRUD、转换、分配、跟进） |
| `opportunities.py` | 商机管理 API（CRUD、转换、分配、跟进） |
| `products.py` | 产品管理 API（CRUD） |
| `product_prices.py` | 价格管理 API（CRUD、批量更新） |
| `exchange_rates.py` | 汇率管理 API（CRUD） |
| `price_change_logs.py` | 价格变更日志 API（查询） |
| `suppliers.py` | 供应商管理 API（CRUD） |
| `audit_logs.py` | 审计日志 API（查询、导出） |
| `analytics.py` | 数据分析 API（销售统计、订单统计） |
| `monitoring.py` | 系统监控 API（CPU、内存、错误率） |
| `logs.py` | 日志查询 API（MongoDB 日志查询） |

#### 业务服务 (`foundation_service/services/`)

| 文件 | 功能 |
|------|------|
| `auth_service.py` | 认证服务（登录验证、Token 生成） |
| `user_service.py` | 用户服务（业务逻辑处理） |
| `customer_service.py` | 客户服务（业务逻辑处理） |
| `order_service.py` | 订单服务（业务逻辑处理、状态流转） |
| `lead_service.py` | 线索服务（业务逻辑处理、转换逻辑） |
| `opportunity_service.py` | 商机服务（业务逻辑处理、转换逻辑） |
| `product_service.py` | 产品服务（业务逻辑处理） |
| `product_price_service.py` | 价格服务（价格计算、历史记录） |
| `exchange_rate_service.py` | 汇率服务（汇率转换） |
| `audit_service.py` | 审计服务（日志查询、导出） |
| `analytics_service.py` | 分析服务（数据统计、报表生成） |
| `monitoring_service.py` | 监控服务（系统指标收集、预警） |

#### 数据访问层 (`foundation_service/repositories/`)

| 文件 | 功能 |
|------|------|
| `user_repository.py` | 用户数据访问（数据库操作） |
| `customer_repository.py` | 客户数据访问（数据库操作） |
| `order_repository.py` | 订单数据访问（数据库操作） |
| `lead_repository.py` | 线索数据访问（数据库操作） |
| `product_repository.py` | 产品数据访问（数据库操作） |
| `audit_repository.py` | 审计日志数据访问（数据库操作） |

#### 数据模型 (`common/models/`)

| 文件 | 功能 |
|------|------|
| `user.py` | 用户模型定义 |
| `organization.py` | 组织模型定义 |
| `customer.py` | 客户模型定义 |
| `order.py` | 订单模型定义 |
| `lead.py` | 线索模型定义 |
| `opportunity.py` | 商机模型定义 |
| `product.py` | 产品模型定义 |
| `product_price.py` | 价格模型定义 |
| `audit_log.py` | 审计日志模型定义 |

#### 中间件 (`foundation_service/middleware/`)

| 文件 | 功能 |
|------|------|
| `audit_middleware.py` | 审计日志中间件（自动记录所有 HTTP 请求） |
| `access_log_filter.py` | 访问日志过滤器（过滤健康检查日志） |

#### 工具函数 (`foundation_service/utils/`)

| 文件 | 功能 |
|------|------|
| `jwt.py` | JWT 工具（Token 生成、验证） |
| `password.py` | 密码工具（加密、验证） |
| `audit_decorator.py` | 审计装饰器（手动记录审计日志） |
| `audit_helper.py` | 审计辅助函数（提取请求信息） |

---

## 开发指南

### 前端开发

#### 添加新页面

1. 在 `src/pages/admin/` 创建新页面组件
2. 在 `src/App.tsx` 中添加路由
3. 在 `src/config/menu.ts` 中添加菜单项
4. 在 `src/i18n/locales/` 中添加翻译文本

#### 添加新 API

1. 在 `src/api/` 创建新的 API 文件
2. 使用 `src/api/client.ts` 中的 `apiClient` 发送请求
3. 在 `src/api/config.ts` 中添加 API 路径定义

#### 权限控制

使用 `PermissionGuard` 组件包裹需要权限的页面：

```tsx
<PermissionGuard role={Role.ADMIN}>
  <YourComponent />
</PermissionGuard>
```

### 后端开发

#### 添加新 API 端点

1. 在 `foundation_service/api/v1/` 创建新的路由文件
2. 在 `foundation_service/services/` 创建对应的服务文件
3. 在 `foundation_service/repositories/` 创建对应的仓库文件
4. 在 `foundation_service/schemas/` 创建对应的 Schema 文件
5. 在 `foundation_service/main.py` 中注册路由

#### 添加新数据模型

1. 在 `common/models/` 创建新的模型文件
2. 在 `common/models/__init__.py` 中导出模型
3. 在 `init-scripts/migrations/` 创建数据库迁移脚本

#### 数据库迁移

1. 在 `init-scripts/migrations/` 创建 SQL 迁移脚本
2. 使用命名规范：`YYYYMMDD_description.sql`
3. 确保迁移脚本可以重复执行（使用 `IF NOT EXISTS` 等）

### 代码规范

#### 前端

- 使用 TypeScript 进行类型检查
- 遵循 React Hooks 最佳实践
- 使用 Tailwind CSS 进行样式设计
- 组件使用函数式组件和 Hooks
- 事件处理函数使用 `handle` 前缀命名

#### 后端

- 使用类型提示（Type Hints）
- 遵循 PEP 8 代码规范
- 使用 Pydantic 进行数据验证
- 遵循 RORO 模式（Receive an Object, Return an Object）
- 使用异步操作（async/await）处理 I/O 操作

---

## 重要说明

### 多租户架构

- 每个公司/组织是一个独立的租户
- 数据通过 `organization_id` 字段隔离
- 用户只能访问自己所属组织的数据

### 权限系统

- 基于角色的权限控制（RBAC）
- 角色：ADMIN、SALES、AGENT、OPERATION、FINANCE
- 权限可以细化到具体的操作（CREATE、READ、UPDATE、DELETE）

### 审计日志

- 所有 HTTP 请求自动记录到 `audit_logs` 表
- 记录信息包括：用户、操作类型、资源、请求参数、响应状态
- 敏感信息（如密码）自动过滤

### 价格管理

- 支持多币种（IDR、USD、CNY 等）
- 支持汇率管理
- 价格变更自动记录历史
- 订单创建时保存价格快照

---

## 相关文档

- [后端 README](../crm-backend-python/README.md)
- [前端 README](../crm-bantu-website/README.md)
- [配置项目 README](../crm-configuration/README.md)
- [API 文档](../crm-backend-python/docs/api/API_DOCUMENTATION.md)
- [模块架构文档](../crm-configuration/docs/module_architecture.md)

---

**最后更新**: 2024-11-09
