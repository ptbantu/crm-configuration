# 微服务架构对比：适度拆分 vs 过度拆分

## 架构方案对比

### 方案 A: 适度拆分（推荐）

**服务数量**: 5 个服务

```
crm-gateway-service          # API 网关
crm-foundation-service        # 基础服务（用户、组织、权限）
crm-business-service         # 业务服务（客户、产品、订单、交付）
crm-workflow-service         # 工作流服务
crm-finance-service          # 财务服务
```

**优势**:
- ✅ 服务数量适中，易于管理
- ✅ 职责清晰，按业务域划分
- ✅ 部署和运维复杂度可控
- ✅ 团队协作清晰（每个服务 1-2 人负责）
- ✅ 服务间调用关系简单

**适用场景**:
- 中小型团队（5-10 人）
- 业务复杂度中等
- 需要快速迭代

---

### 方案 B: 过度拆分（不推荐）

**服务数量**: 15+ 个服务

```
crm-gateway-service
crm-user-service
crm-organization-service
crm-role-service
crm-customer-service
crm-contact-service
crm-product-service
crm-product-category-service
crm-order-service
crm-order-assignment-service
crm-order-stage-service
crm-delivery-service
crm-payment-service
crm-workflow-service
crm-report-service
...
```

**劣势**:
- ❌ 服务数量过多，管理复杂
- ❌ 服务间调用关系复杂（网状调用）
- ❌ 部署和运维成本高
- ❌ 团队协作困难（服务边界不清晰）
- ❌ 开发效率低（需要频繁跨服务调试）

**适用场景**:
- 大型团队（20+ 人）
- 业务非常复杂
- 需要独立扩展某些功能

---

## 推荐方案：适度拆分

### 服务职责划分

| 服务 | 职责 | 包含功能 | 数据库表 |
|------|------|---------|---------|
| **foundation-service** | 基础管理 | 用户、组织、角色、权限、认证 | users, organizations, roles, user_roles, organization_employees |
| **business-service** | 核心业务 | 客户、产品、订单、交付 | customers, contacts, products, orders, order_assignments, order_stages, deliverables |
| **workflow-service** | 工作流 | Activiti 引擎、流程管理 | ACT_* (Activiti 表) |
| **finance-service** | 财务管理 | 收款、付款、报表 | payments |

### 服务间调用关系

```
gateway-service
    ↓
    ├──→ foundation-service (用户、组织查询)
    ├──→ business-service (业务操作)
    │       ├──→ foundation-service (获取用户/组织信息)
    │       └──→ workflow-service (启动工作流)
    ├──→ workflow-service (工作流操作)
    │       └──→ business-service (获取业务数据)
    └──→ finance-service (财务操作)
            ├──→ business-service (获取订单信息)
            └──→ workflow-service (启动审批流程)
```

**调用特点**:
- 调用关系简单，主要是单向调用
- 避免循环依赖
- 网关作为统一入口

---

## 数据管理策略

### 共享数据库（初期推荐）

**方案**: 所有服务共享同一个 MySQL 数据库

**优势**:
- ✅ 简化部署（只需一个数据库）
- ✅ 支持跨服务事务（如果需要）
- ✅ 降低数据一致性复杂度
- ✅ 便于数据查询和分析

**规则**:
- 每个服务只写自己的表
- 读取其他服务的数据通过服务调用

### 独立数据库（后期演进）

**方案**: 每个服务独立数据库

**适用场景**:
- 服务规模扩大
- 需要独立扩展
- 数据安全要求高

**迁移策略**:
- 逐步拆分数据库
- 通过事件同步数据
- 使用分布式事务或最终一致性

---

## 服务间通信

### 同步调用（HTTP REST）

**使用 Feign 客户端**:

```java
// 定义接口（在 crm-common 中）
@FeignClient(name = "crm-foundation-service")
public interface FoundationClient {
    @GetMapping("/api/foundation/users/{id}")
    Result<UserResponse> getUser(@PathVariable String id);
}

// 使用（在 business-service 中）
@Service
public class OrderService {
    @Autowired
    private FoundationClient foundationClient;
    
    public OrderResponse getOrder(String orderId) {
        Order order = orderMapper.selectById(orderId);
        // 调用 foundation-service 获取用户信息
        UserResponse user = foundationClient.getUser(order.getSalesUserId()).getData();
        // ...
    }
}
```

### 异步调用（消息队列，可选）

**使用场景**:
- 订单状态变更通知
- 工作流事件通知

**实现方式**:
- RabbitMQ
- Kafka

**初期**: 可以不使用，通过 HTTP 同步调用

---

## 部署架构

### Kubernetes 部署

```yaml
# 每个服务独立的 Deployment 和 Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: crm-foundation-service
spec:
  replicas: 2
  template:
    spec:
      containers:
      - name: foundation
        image: crm-foundation-service:latest
        ports:
        - containerPort: 8081
---
apiVersion: v1
kind: Service
metadata:
  name: crm-foundation-service
spec:
  selector:
    app: crm-foundation-service
  ports:
  - port: 8081
    targetPort: 8081
```

### 服务发现

使用 Kubernetes Service 进行服务发现，无需额外的服务注册中心。

---

## 开发建议

### 1. 先从单体开始（可选）

如果团队规模小，可以先开发单体应用验证业务逻辑，再拆分为微服务。

### 2. 逐步拆分

不要一开始就拆分所有服务，可以：
1. 先开发 foundation-service 和 business-service
2. 验证服务间调用
3. 再拆分 workflow-service 和 finance-service

### 3. 保持服务独立性

- 每个服务可以独立开发、测试、部署
- 服务间通过明确的接口通信
- 避免直接访问其他服务的数据库

### 4. 统一技术栈

初期保持技术栈统一（Spring Boot + MyBatis-Plus），降低学习成本。

---

## 总结

**推荐架构**: 适度拆分，5 个服务

- **数量适中**: 不会过度拆分导致管理混乱
- **职责清晰**: 按业务域划分，易于理解
- **易于管理**: 部署、运维、监控都相对简单
- **灵活扩展**: 可以根据需要独立扩展某个服务

**关键原则**:
- 按业务域拆分，而不是按技术层拆分
- 保持服务数量在可控范围内（3-5 个）
- 共享数据库降低复杂度
- 使用 Feign 简化服务间调用

