# BANTU CRM 文件功能参考手册

> 本文档详细说明每个文件的功能和作用，帮助开发者快速定位和理解代码。

## 📋 目录

- [前端文件功能说明](#前端文件功能说明)
- [后端文件功能说明](#后端文件功能说明)
- [配置文件说明](#配置文件说明)

---

## 前端文件功能说明

### API 客户端 (`src/api/`)

#### `auth.ts`
**功能**: 用户认证相关 API
- `login(username, password)` - 用户登录，返回 Token 和用户信息
- `getUserInfo()` - 获取当前登录用户信息
- `refreshToken()` - 刷新 Token

#### `users.ts`
**功能**: 用户管理 API
- `getUsers(params)` - 获取用户列表（支持分页、筛选）
- `getUserById(id)` - 获取用户详情
- `createUser(data)` - 创建用户
- `updateUser(id, data)` - 更新用户信息
- `deleteUser(id)` - 删除用户
- `enableUser(id)` - 启用用户
- `disableUser(id)` - 禁用用户

#### `organizations.ts`
**功能**: 组织管理 API
- `getOrganizations(params)` - 获取组织列表
- `getOrganizationById(id)` - 获取组织详情
- `createOrganization(data)` - 创建组织
- `updateOrganization(id, data)` - 更新组织信息
- `deleteOrganization(id)` - 删除组织

#### `customers.ts`
**功能**: 客户管理 API
- `getCustomers(params)` - 获取客户列表（支持筛选、排序）
- `getCustomerById(id)` - 获取客户详情
- `createCustomer(data)` - 创建客户
- `updateCustomer(id, data)` - 更新客户信息
- `deleteCustomer(id)` - 删除客户
- `getCustomerFollowUps(customerId)` - 获取客户跟进记录
- `createCustomerFollowUp(customerId, data)` - 创建跟进记录
- `getCustomerNotes(customerId)` - 获取客户备注
- `createCustomerNote(customerId, data)` - 创建备注

#### `orders.ts`
**功能**: 订单管理 API
- `getOrders(params)` - 获取订单列表
- `getOrderById(id)` - 获取订单详情
- `createOrder(data)` - 创建订单
- `updateOrder(id, data)` - 更新订单信息
- `assignOrder(id, userId)` - 分配订单给用户
- `updateOrderStatus(id, status)` - 更新订单状态
- `getOrderComments(orderId)` - 获取订单评论
- `createOrderComment(orderId, data)` - 创建订单评论
- `getOrderFiles(orderId)` - 获取订单文件列表
- `uploadOrderFile(orderId, file)` - 上传订单文件

#### `leads.ts`
**功能**: 线索管理 API
- `getLeads(params)` - 获取线索列表
- `getLeadById(id)` - 获取线索详情
- `createLead(data)` - 创建线索
- `updateLead(id, data)` - 更新线索信息
- `assignLead(id, userId)` - 分配线索给用户
- `convertToCustomer(id)` - 将线索转换为客户
- `convertToOpportunity(id)` - 将线索转换为商机
- `moveToPool(id)` - 将线索移入线索池
- `checkDuplicate(data)` - 检查重复线索
- `getLeadFollowUps(leadId)` - 获取线索跟进记录
- `createLeadFollowUp(leadId, data)` - 创建跟进记录
- `getLeadNotes(leadId)` - 获取线索备注
- `createLeadNote(leadId, data)` - 创建备注

#### `opportunities.ts`
**功能**: 商机管理 API
- `getOpportunities(params)` - 获取商机列表
- `getOpportunityById(id)` - 获取商机详情
- `createOpportunity(data)` - 创建商机
- `updateOpportunity(id, data)` - 更新商机信息
- `assignOpportunity(id, userId)` - 分配商机给用户
- `updateStage(id, stage)` - 更新商机阶段
- `convert(id)` - 将商机转换为订单
- `getOpportunityFollowUps(opportunityId)` - 获取商机跟进记录
- `createOpportunityFollowUp(opportunityId, data)` - 创建跟进记录
- `getOpportunityNotes(opportunityId)` - 获取商机备注
- `createOpportunityNote(opportunityId, data)` - 创建备注

#### `products.ts`
**功能**: 产品管理 API
- `getProducts(params)` - 获取产品列表
- `getProductById(id)` - 获取产品详情
- `createProduct(data)` - 创建产品
- `updateProduct(id, data)` - 更新产品信息
- `deleteProduct(id)` - 删除产品
- `getProductsByVendor(vendorId)` - 获取供应商的产品列表

#### `prices.ts`
**功能**: 价格管理 API
- `getPrices(params)` - 获取价格列表
- `getPriceById(id)` - 获取价格详情
- `createPrice(data)` - 创建价格
- `updatePrice(id, data)` - 更新价格
- `deletePrice(id)` - 删除价格
- `getPriceHistory(productId)` - 获取价格历史记录
- `batchUpdatePrices(data)` - 批量更新价格

#### `exchangeRates.ts`
**功能**: 汇率管理 API
- `getExchangeRates(params)` - 获取汇率列表
- `getExchangeRateById(id)` - 获取汇率详情
- `createExchangeRate(data)` - 创建汇率
- `updateExchangeRate(id, data)` - 更新汇率
- `getCurrentRate(fromCurrency, toCurrency)` - 获取当前汇率

#### `auditLogs.ts`
**功能**: 审计日志 API
- `getAuditLogs(params)` - 查询审计日志（支持多条件筛选）
- `getAuditLogById(id)` - 获取审计日志详情
- `getUserAuditLogs(userId, params)` - 查询用户审计日志
- `getResourceAuditLogs(resourceType, resourceId, params)` - 查询资源审计日志
- `exportAuditLogs(params, format)` - 导出审计日志（JSON/CSV）

#### `config.ts`
**功能**: API 配置
- `API_CONFIG` - API 基础配置（BASE_URL、TIMEOUT）
- `API_PATHS` - 所有 API 路径定义（常量对象）

#### `client.ts`
**功能**: HTTP 客户端封装
- `apiClient` - Axios 实例，配置了请求/响应拦截器
- 自动添加 Token 到请求头
- 统一错误处理
- Token 过期自动刷新

### 页面组件 (`src/pages/`)

#### 官网页面

##### `Home.tsx`
**功能**: 官网首页
- 展示公司介绍和核心服务
- 多语言支持

##### `About.tsx`
**功能**: 关于我们页面
- 公司详细信息展示

##### `Services.tsx`
**功能**: 服务介绍页面
- 详细的服务说明

##### `Contact.tsx`
**功能**: 联系我们页面
- 联系表单和联系方式

#### 管理后台页面 (`src/pages/admin/`)

##### `Login.tsx`
**功能**: 用户登录页面
- 用户名密码登录
- 记住登录状态
- 登录后跳转到仪表板

##### `Dashboard.tsx`
**功能**: 管理后台仪表板
- 数据概览（订单数、客户数、销售额等）
- 图表展示（销售趋势、订单状态分布等）
- 快捷操作入口

##### `CustomerList.tsx`
**功能**: 客户列表页面
- 客户列表展示（表格）
- 搜索和筛选功能
- 分页功能
- 跳转到客户详情

##### `CustomerDetail.tsx`
**功能**: 客户详情页面
- 客户基本信息展示
- 客户跟进记录
- 客户备注
- 关联订单列表
- 编辑客户信息

##### `OrderList.tsx`
**功能**: 订单列表页面
- 订单列表展示（表格）
- 搜索和筛选功能
- 订单状态筛选
- 分页功能
- 跳转到订单详情

##### `OrderDetail.tsx`
**功能**: 订单详情页面
- 订单基本信息展示
- 订单项列表
- 订单评论（支持回复、置顶）
- 订单文件（上传、下载）
- 订单状态流转
- 分配订单

##### `LeadList.tsx`
**功能**: 线索列表页面
- 线索列表展示（表格）
- 搜索和筛选功能
- 线索状态筛选
- 分页功能
- 跳转到线索详情
- 转换为客户/商机

##### `LeadDetail.tsx`
**功能**: 线索详情页面
- 线索基本信息展示
- 线索跟进记录
- 线索备注
- 转换为客户/商机
- 分配线索

##### `OpportunityList.tsx`
**功能**: 商机列表页面
- 商机列表展示（表格）
- 搜索和筛选功能
- 商机阶段筛选
- 分页功能
- 跳转到商机详情

##### `OpportunityDetail.tsx`
**功能**: 商机详情页面
- 商机基本信息展示
- 商机产品列表
- 付款阶段
- 商机跟进记录
- 商机备注
- 转换为订单
- 分配商机

##### `ProductManagement.tsx`
**功能**: 产品管理页面
- 产品列表展示
- 产品分类树
- 创建/编辑产品
- 产品详情抽屉（多标签页）
  - 概览
  - 价格
  - 供应商
  - 规则
  - 历史记录
  - 统计信息

##### `PriceManagement.tsx`
**功能**: 价格管理页面
- 产品价格列表
- 汇率管理面板
- 价格变更日志
- 价格历史记录
- 批量价格编辑
- 即将生效的价格变更

##### `EmployeeList.tsx`
**功能**: 员工列表页面
- 员工列表展示
- 搜索和筛选
- 启用/禁用员工
- 跳转到员工管理

##### `EmployeeManagement.tsx`
**功能**: 员工管理页面
- 创建/编辑员工
- 分配角色
- 分配组织

##### `RoleManagement.tsx`
**功能**: 角色管理页面
- 角色列表展示
- 创建/编辑角色
- 分配权限

##### `Organizations.tsx` / `OrganizationsNew.tsx`
**功能**: 组织管理页面
- 组织列表展示
- 创建/编辑组织
- 组织员工管理
- 组织领域管理

##### `AuditLogs.tsx`
**功能**: 审计日志页面
- 审计日志列表（表格）
- 多条件筛选（用户、操作类型、资源类型、时间范围）
- 分页功能
- 导出功能（JSON/CSV）
- 日志详情查看

##### `SystemStatus.tsx`
**功能**: 系统状态页面
- 系统指标展示（CPU、内存、错误率）
- 实时监控图表
- 预警信息

##### `SystemLogs.tsx`
**功能**: 系统日志页面
- MongoDB 日志查询
- 日志级别筛选
- 时间范围筛选
- 日志详情查看

### 组件 (`src/components/`)

#### `Header.tsx`
**功能**: 官网头部组件
- 导航菜单
- 语言切换
- Logo 展示

#### `Footer.tsx`
**功能**: 官网页脚组件
- 公司信息
- 联系方式
- 版权信息

#### `Toast.tsx` / `ToastContainer.tsx`
**功能**: 消息提示组件
- 成功/错误/警告/信息提示
- 自动消失
- 手动关闭

#### `admin/Sidebar.tsx`
**功能**: 管理后台侧边栏
- 菜单导航
- 权限控制（根据角色显示菜单）
- 折叠/展开功能
- 当前路由高亮

#### `admin/TopBar.tsx`
**功能**: 管理后台顶部栏
- 用户信息展示
- 退出登录
- 语言切换
- 通知中心（待实现）

#### `admin/PermissionGuard.tsx`
**功能**: 权限守卫组件
- 检查用户角色/权限
- 无权限时显示提示或重定向

#### `admin/Breadcrumb.tsx`
**功能**: 面包屑导航组件
- 显示当前页面路径
- 支持点击跳转

#### `admin/PageHeader.tsx`
**功能**: 页面头部组件
- 页面标题
- 操作按钮区域
- 面包屑导航

#### `admin/price/` 目录
**功能**: 价格管理相关组件
- `PriceEditModal.tsx` - 价格编辑弹窗
- `ExchangeRatePanel.tsx` - 汇率管理面板
- `PriceHistoryPanel.tsx` - 价格历史记录面板
- `PriceChangeLogs.tsx` - 价格变更日志组件
- `UpcomingPriceChanges.tsx` - 即将生效的价格变更组件
- `ProductPriceTable.tsx` - 产品价格表格组件

#### `admin/product/` 目录
**功能**: 产品管理相关组件
- `ProductDetailDrawer.tsx` - 产品详情抽屉
- `ProductDetailTabs/` - 产品详情标签页
  - `OverviewTab.tsx` - 概览标签页
  - `PriceTab.tsx` - 价格标签页
  - `SupplierTab.tsx` - 供应商标签页
  - `RulesTab.tsx` - 规则标签页
  - `HistoryTab.tsx` - 历史记录标签页
  - `StatisticsTab.tsx` - 统计信息标签页
  - `OperationsTab.tsx` - 操作标签页

### 配置 (`src/config/`)

#### `menu.ts`
**功能**: 菜单配置
- `adminMenuItems` - 管理后台菜单项数组
- 每个菜单项包含：key、label（i18n key）、icon、path、permission、role、children
- 支持多级菜单
- 支持权限控制

#### `permissions.ts`
**功能**: 权限配置
- `Role` 枚举 - 角色定义（ADMIN、SALES、AGENT、OPERATION、FINANCE）
- `Permission` 枚举 - 权限定义（USER_CREATE、CUSTOMER_READ 等）
- `ROLE_INFO` - 角色信息映射（名称、描述）

### 上下文 (`src/contexts/`)

#### `AuthContext.tsx`
**功能**: 认证上下文
- `user` - 当前登录用户信息
- `isAuthenticated` - 是否已登录
- `login()` - 登录方法
- `logout()` - 退出登录方法
- `refreshUserInfo()` - 刷新用户信息

#### `SidebarContext.tsx`
**功能**: 侧边栏上下文
- `isCollapsed` - 侧边栏是否折叠
- `toggleCollapse()` - 切换折叠状态

#### `TabsContext.tsx`
**功能**: 标签页上下文
- `tabs` - 打开的标签页列表
- `activeTab` - 当前激活的标签页
- `openTab()` - 打开新标签页
- `closeTab()` - 关闭标签页
- `setActiveTab()` - 设置激活标签页

### 工具函数 (`src/utils/`)

#### `cn.ts`
**功能**: className 合并工具
- 合并多个 className 字符串
- 处理条件 className

#### `formatPrice.ts`
**功能**: 价格格式化工具
- 格式化价格显示（货币符号、千分位）
- 支持多币种

#### `storage.ts`
**功能**: 本地存储工具
- `setItem(key, value)` - 设置存储项
- `getItem(key)` - 获取存储项
- `removeItem(key)` - 删除存储项
- `clear()` - 清空存储

---

## 后端文件功能说明

### API 路由 (`foundation_service/api/v1/`)

#### `auth.py`
**功能**: 认证 API
- `POST /login` - 用户登录
- `POST /refresh` - 刷新 Token
- `GET /user-info` - 获取当前用户信息

#### `users.py`
**功能**: 用户管理 API
- `GET /` - 获取用户列表
- `POST /` - 创建用户
- `GET /{id}` - 获取用户详情
- `PUT /{id}` - 更新用户
- `DELETE /{id}` - 删除用户
- `POST /{id}/enable` - 启用用户
- `POST /{id}/disable` - 禁用用户

#### `organizations.py`
**功能**: 组织管理 API
- `GET /` - 获取组织列表
- `POST /` - 创建组织
- `GET /{id}` - 获取组织详情
- `PUT /{id}` - 更新组织
- `DELETE /{id}` - 删除组织
- `GET /{id}/employees` - 获取组织员工列表

#### `roles.py`
**功能**: 角色管理 API
- `GET /` - 获取角色列表
- `POST /` - 创建角色
- `GET /{id}` - 获取角色详情
- `PUT /{id}` - 更新角色
- `DELETE /{id}` - 删除角色
- `POST /{id}/permissions` - 分配权限

#### `customers.py`
**功能**: 客户管理 API
- `GET /` - 获取客户列表
- `POST /` - 创建客户
- `GET /{id}` - 获取客户详情
- `PUT /{id}` - 更新客户
- `DELETE /{id}` - 删除客户
- `GET /{id}/follow-ups` - 获取跟进记录
- `POST /{id}/follow-ups` - 创建跟进记录
- `GET /{id}/notes` - 获取备注
- `POST /{id}/notes` - 创建备注

#### `orders.py`
**功能**: 订单管理 API
- `GET /` - 获取订单列表
- `POST /` - 创建订单
- `GET /{id}` - 获取订单详情
- `PUT /{id}` - 更新订单
- `POST /{id}/assign` - 分配订单
- `POST /{id}/update-status` - 更新订单状态

#### `leads.py`
**功能**: 线索管理 API
- `GET /` - 获取线索列表
- `POST /` - 创建线索
- `GET /{id}` - 获取线索详情
- `PUT /{id}` - 更新线索
- `POST /{id}/assign` - 分配线索
- `POST /{id}/convert-to-customer` - 转换为客户
- `POST /{id}/convert-to-opportunity` - 转换为商机
- `POST /{id}/move-to-pool` - 移入线索池
- `POST /check-duplicate` - 检查重复线索

#### `opportunities.py`
**功能**: 商机管理 API
- `GET /` - 获取商机列表
- `POST /` - 创建商机
- `GET /{id}` - 获取商机详情
- `PUT /{id}` - 更新商机
- `POST /{id}/assign` - 分配商机
- `POST /{id}/update-stage` - 更新商机阶段
- `POST /{id}/convert` - 转换为订单

#### `products.py`
**功能**: 产品管理 API
- `GET /` - 获取产品列表
- `POST /` - 创建产品
- `GET /{id}` - 获取产品详情
- `PUT /{id}` - 更新产品
- `DELETE /{id}` - 删除产品
- `GET /vendors/{vendor_id}` - 获取供应商的产品列表

#### `product_prices.py`
**功能**: 价格管理 API
- `GET /` - 获取价格列表
- `POST /` - 创建价格
- `GET /{id}` - 获取价格详情
- `PUT /{id}` - 更新价格
- `DELETE /{id}` - 删除价格
- `POST /batch-update` - 批量更新价格

#### `exchange_rates.py`
**功能**: 汇率管理 API
- `GET /` - 获取汇率列表
- `POST /` - 创建汇率
- `GET /{id}` - 获取汇率详情
- `PUT /{id}` - 更新汇率
- `GET /current` - 获取当前汇率

#### `audit_logs.py`
**功能**: 审计日志 API
- `GET /` - 查询审计日志列表
- `GET /{id}` - 获取审计日志详情
- `GET /users/{user_id}` - 查询用户审计日志
- `GET /resources/{resource_type}/{resource_id}` - 查询资源审计日志
- `POST /export` - 导出审计日志

#### `analytics.py`
**功能**: 数据分析 API
- `GET /sales-statistics` - 销售统计
- `GET /order-statistics` - 订单统计
- `GET /customer-statistics` - 客户统计
- `GET /revenue-trend` - 收入趋势

#### `monitoring.py`
**功能**: 系统监控 API
- `GET /metrics` - 获取系统指标
- `GET /health` - 健康检查
- `GET /alerts` - 获取预警信息

#### `logs.py`
**功能**: 日志查询 API
- `GET /` - 查询应用日志（MongoDB）
- `GET /{id}` - 获取日志详情

### 业务服务 (`foundation_service/services/`)

#### `auth_service.py`
**功能**: 认证服务
- `authenticate(username, password)` - 验证用户名密码
- `create_access_token(user_id, roles)` - 创建访问 Token
- `verify_token(token)` - 验证 Token
- `get_current_user(user_id)` - 获取当前用户信息

#### `user_service.py`
**功能**: 用户服务
- `create_user(data)` - 创建用户（业务逻辑处理）
- `update_user(user_id, data)` - 更新用户
- `delete_user(user_id)` - 删除用户
- `enable_user(user_id)` - 启用用户
- `disable_user(user_id)` - 禁用用户

#### `customer_service.py`
**功能**: 客户服务
- `create_customer(data)` - 创建客户
- `update_customer(customer_id, data)` - 更新客户
- `get_customer_with_relations(customer_id)` - 获取客户及关联数据
- `create_follow_up(customer_id, data)` - 创建跟进记录
- `create_note(customer_id, data)` - 创建备注

#### `order_service.py`
**功能**: 订单服务
- `create_order(data)` - 创建订单（包含价格快照）
- `update_order(order_id, data)` - 更新订单
- `assign_order(order_id, user_id)` - 分配订单
- `update_order_status(order_id, status)` - 更新订单状态（触发工作流）

#### `lead_service.py`
**功能**: 线索服务
- `create_lead(data)` - 创建线索
- `update_lead(lead_id, data)` - 更新线索
- `convert_to_customer(lead_id)` - 转换为客户
- `convert_to_opportunity(lead_id)` - 转换为商机
- `check_duplicate(data)` - 检查重复线索

#### `opportunity_service.py`
**功能**: 商机服务
- `create_opportunity(data)` - 创建商机
- `update_opportunity(opportunity_id, data)` - 更新商机
- `update_stage(opportunity_id, stage)` - 更新商机阶段
- `convert_to_order(opportunity_id)` - 转换为订单

#### `product_service.py`
**功能**: 产品服务
- `create_product(data)` - 创建产品
- `update_product(product_id, data)` - 更新产品
- `delete_product(product_id)` - 删除产品
- `get_product_with_relations(product_id)` - 获取产品及关联数据

#### `product_price_service.py`
**功能**: 价格服务
- `create_price(data)` - 创建价格
- `update_price(price_id, data)` - 更新价格（记录历史）
- `get_price_history(product_id)` - 获取价格历史
- `calculate_price(product_id, customer_level, currency)` - 计算价格

#### `exchange_rate_service.py`
**功能**: 汇率服务
- `create_exchange_rate(data)` - 创建汇率
- `update_exchange_rate(rate_id, data)` - 更新汇率
- `get_current_rate(from_currency, to_currency)` - 获取当前汇率
- `convert_amount(amount, from_currency, to_currency)` - 转换金额

#### `audit_service.py`
**功能**: 审计服务
- `get_audit_logs(params)` - 查询审计日志
- `get_audit_log_by_id(log_id)` - 获取审计日志详情
- `export_audit_logs(params, format)` - 导出审计日志

#### `analytics_service.py`
**功能**: 分析服务
- `get_sales_statistics(params)` - 获取销售统计
- `get_order_statistics(params)` - 获取订单统计
- `get_customer_statistics(params)` - 获取客户统计
- `get_revenue_trend(params)` - 获取收入趋势

#### `monitoring_service.py`
**功能**: 监控服务
- `collect_metrics()` - 收集系统指标
- `check_health()` - 健康检查
- `get_alerts()` - 获取预警信息

### 数据访问层 (`foundation_service/repositories/`)

#### `user_repository.py`
**功能**: 用户数据访问
- `create(user)` - 创建用户记录
- `get_by_id(user_id)` - 根据 ID 查询用户
- `get_by_username(username)` - 根据用户名查询用户
- `get_all(params)` - 查询用户列表
- `update(user_id, data)` - 更新用户记录
- `delete(user_id)` - 删除用户记录

#### `customer_repository.py`
**功能**: 客户数据访问
- `create(customer)` - 创建客户记录
- `get_by_id(customer_id)` - 根据 ID 查询客户
- `get_all(params)` - 查询客户列表
- `update(customer_id, data)` - 更新客户记录
- `delete(customer_id)` - 删除客户记录

#### `order_repository.py`
**功能**: 订单数据访问
- `create(order)` - 创建订单记录
- `get_by_id(order_id)` - 根据 ID 查询订单
- `get_all(params)` - 查询订单列表
- `update(order_id, data)` - 更新订单记录
- `get_order_items(order_id)` - 获取订单项列表

#### `lead_repository.py`
**功能**: 线索数据访问
- `create(lead)` - 创建线索记录
- `get_by_id(lead_id)` - 根据 ID 查询线索
- `get_all(params)` - 查询线索列表
- `update(lead_id, data)` - 更新线索记录
- `check_duplicate(data)` - 检查重复线索

#### `product_repository.py`
**功能**: 产品数据访问
- `create(product)` - 创建产品记录
- `get_by_id(product_id)` - 根据 ID 查询产品
- `get_all(params)` - 查询产品列表
- `update(product_id, data)` - 更新产品记录
- `delete(product_id)` - 删除产品记录

#### `audit_repository.py`
**功能**: 审计日志数据访问
- `create(audit_log)` - 创建审计日志记录
- `get_by_id(log_id)` - 根据 ID 查询审计日志
- `get_all(params)` - 查询审计日志列表（支持多条件筛选）
- `get_by_user(user_id, params)` - 查询用户审计日志
- `get_by_resource(resource_type, resource_id, params)` - 查询资源审计日志

### 数据模型 (`common/models/`)

#### `user.py`
**功能**: 用户模型定义
- `User` - 用户表模型
- 字段：id、username、email、password_hash、full_name、phone、status、organization_id、created_at、updated_at

#### `organization.py`
**功能**: 组织模型定义
- `Organization` - 组织表模型
- 字段：id、name、code、type、status、created_at、updated_at

#### `customer.py`
**功能**: 客户模型定义
- `Customer` - 客户表模型
- 字段：id、name、code、type、level_id、source_id、industry_id、organization_id、created_at、updated_at

#### `order.py`
**功能**: 订单模型定义
- `Order` - 订单表模型
- 字段：id、order_number、customer_id、status、total_amount、assigned_to、organization_id、created_at、updated_at

#### `lead.py`
**功能**: 线索模型定义
- `Lead` - 线索表模型
- 字段：id、name、phone、email、status、source_id、assigned_to、organization_id、created_at、updated_at

#### `product.py`
**功能**: 产品模型定义
- `Product` - 产品表模型
- 字段：id、name、code、category_id、description、status、created_at、updated_at

#### `product_price.py`
**功能**: 价格模型定义
- `ProductPrice` - 产品价格表模型
- 字段：id、product_id、customer_level_id、currency、price、effective_date、created_at、updated_at

#### `audit_log.py`
**功能**: 审计日志模型定义
- `AuditLog` - 审计日志表模型
- 字段：id、user_id、action、resource_type、resource_id、request_data、response_status、ip_address、user_agent、created_at

### 中间件 (`foundation_service/middleware/`)

#### `audit_middleware.py`
**功能**: 审计日志中间件
- 自动拦截所有 HTTP 请求
- 记录请求信息到 `audit_logs` 表
- 过滤敏感信息（如密码）
- 记录用户身份、操作类型、资源信息、请求参数、响应状态

#### `access_log_filter.py`
**功能**: 访问日志过滤器
- 过滤健康检查日志（减少日志噪音）

### 工具函数 (`foundation_service/utils/`)

#### `jwt.py`
**功能**: JWT 工具
- `create_access_token(user_id, roles)` - 创建访问 Token
- `verify_token(token)` - 验证 Token
- `decode_token(token)` - 解码 Token

#### `password.py`
**功能**: 密码工具
- `hash_password(password)` - 密码加密
- `verify_password(password, hashed)` - 密码验证

#### `audit_decorator.py`
**功能**: 审计装饰器
- `@audit_log(action, resource_type)` - 手动记录审计日志的装饰器

---

## 配置文件说明

### 前端配置

#### `package.json`
**功能**: 项目依赖配置
- 定义项目依赖和开发依赖
- 定义 npm scripts（dev、build、preview、lint）

#### `vite.config.ts`
**功能**: Vite 构建配置
- 配置开发服务器
- 配置代理（API 转发）
- 配置构建选项

#### `tsconfig.json`
**功能**: TypeScript 配置
- 编译选项
- 路径别名
- 类型检查规则

#### `tailwind.config.js`
**功能**: Tailwind CSS 配置
- 主题配置
- 自定义颜色
- 响应式断点

### 后端配置

#### `requirements.txt`
**功能**: Python 依赖配置
- 列出所有 Python 包及其版本

#### `foundation_service/config.py`
**功能**: 服务配置
- 数据库连接配置
- Redis 配置
- MongoDB 配置
- JWT 配置
- 业务配置（订单号前缀、文件大小限制等）

#### `foundation_service/main.py`
**功能**: 应用入口
- FastAPI 应用初始化
- 中间件注册
- 路由注册
- 生命周期管理

### 数据库配置

#### `init-scripts/schema.sql`
**功能**: 数据库 Schema
- 所有表的创建语句
- 索引定义
- 外键约束

#### `init-scripts/migrations/`
**功能**: 数据库迁移脚本
- 按时间顺序组织的迁移脚本
- 每个脚本包含特定的数据库变更

---

**最后更新**: 2024-11-09
