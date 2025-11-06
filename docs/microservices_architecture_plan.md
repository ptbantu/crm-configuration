# BANTU CRM 微服务架构规划

## 1. 架构设计原则

### 1.1 微服务拆分原则

- **按业务域拆分**：而不是按技术层拆分
- **适度拆分**：保持服务数量在 3-5 个，避免过度拆分
- **高内聚低耦合**：相关业务放在同一服务内
- **独立部署**：每个服务可独立部署和扩展
- **共享数据库**：初期使用共享数据库，降低复杂度

### 1.2 服务边界划分

基于业务域和团队规模，采用**粗粒度微服务**架构：

```
BANTU CRM 微服务架构
├── crm-gateway-service          # API 网关服务
├── crm-foundation-service       # 基础服务（用户、组织、权限）
├── crm-business-service         # 业务服务（客户、产品、订单、交付）
├── crm-workflow-service         # 工作流服务（Activiti）
└── crm-finance-service          # 财务服务（收款、付款、报表）
```

**服务数量**: 5 个服务（含网关），适中且易管理

---

## 2. 微服务详细设计

### 2.1 crm-gateway-service（API 网关服务）

**职责**:
- 统一入口，路由转发
- 认证授权（JWT 验证）
- 请求限流
- 跨域处理
- 请求日志

**技术栈**:
- Spring Cloud Gateway 或 Spring Cloud Zuul
- 或使用 Nginx + Kong

**端口**: 8080

**路由规则**:
```
/api/foundation/*  -> crm-foundation-service:8081
/api/business/*    -> crm-business-service:8082
/api/workflow/*    -> crm-workflow-service:8083
/api/finance/*     -> crm-finance-service:8084
```

---

### 2.2 crm-foundation-service（基础服务）

**职责**:
- 用户管理（CRUD、登录认证）
- 组织管理（组织 CRUD、组织树）
- 角色管理（角色 CRUD、权限管理）
- 用户组织关联管理

**包含模块**:
- 用户管理
- 组织管理
- 角色管理
- 认证授权

**数据库表**:
- `users`
- `organizations`
- `roles`
- `user_roles`
- `organization_employees`

**端口**: 8081

**API 路径**: `/api/foundation/*`

**技术栈**:
- Spring Boot
- MyBatis-Plus
- JWT（Token 生成和验证）

---

### 2.3 crm-business-service（业务服务）

**职责**:
- 客户管理（客户 CRUD、联系人管理）
- 产品管理（产品 CRUD、分类管理）
- 订单管理（订单 CRUD、订单分配、订单阶段）
- 交付管理（交付物上传、审核）

**包含模块**:
- 客户管理模块
- 产品管理模块
- 订单管理模块
- 交付管理模块

**数据库表**:
- `customers`
- `contacts`
- `customer_sources`
- `customer_channels`
- `products`
- `product_categories`
- `orders`
- `order_assignments`
- `order_stages`
- `order_statuses`
- `deliverables`

**端口**: 8082

**API 路径**: `/api/business/*`

**技术栈**:
- Spring Boot
- MyBatis-Plus
- 文件上传（OSS 或本地存储）

**服务间调用**:
- 调用 `crm-foundation-service` 获取用户/组织信息
- 调用 `crm-workflow-service` 启动订单工作流

---

### 2.4 crm-workflow-service（工作流服务）

**职责**:
- 工作流引擎（Activiti）
- 流程定义管理（部署、查询）
- 流程实例管理（启动、查询、挂起）
- 任务管理（查询、完成、分配）
- 历史记录查询

**包含模块**:
- Activiti 工作流引擎
- 工作流 API
- BPMN 流程定义管理

**数据库表**:
- Activiti 表（`ACT_*` 前缀）
- 与业务表共享数据库

**端口**: 8083

**API 路径**: `/api/workflow/*`

**技术栈**:
- Spring Boot
- Spring Activiti 7.1.0
- MyBatis-Plus（如果需要自定义查询）

**服务间调用**:
- 被 `crm-business-service` 调用（启动订单工作流）
- 被 `crm-finance-service` 调用（启动付款审批工作流）

---

### 2.5 crm-finance-service（财务服务）

**职责**:
- 收款管理（收款记录 CRUD、确认）
- 付款管理（付款记录 CRUD、审批）
- 财务报表（收入、成本、利润）
- 财务统计

**包含模块**:
- 收款管理
- 付款管理
- 财务报表
- 财务统计

**数据库表**:
- `payments`
- 订单相关表（只读，通过服务调用获取）

**端口**: 8084

**API 路径**: `/api/finance/*`

**技术栈**:
- Spring Boot
- MyBatis-Plus

**服务间调用**:
- 调用 `crm-business-service` 获取订单信息
- 调用 `crm-workflow-service` 启动付款审批工作流

---

## 3. 服务间通信

### 3.1 同步通信（HTTP REST）

**使用场景**:
- 实时查询（获取用户信息、订单信息）
- 业务流程调用（启动工作流）

**实现方式**:
- Spring Cloud OpenFeign（推荐）
- RestTemplate
- WebClient（响应式）

**示例**:
```java
// 在 crm-business-service 中调用 foundation-service
@FeignClient(name = "crm-foundation-service", path = "/api/foundation")
public interface FoundationClient {
    @GetMapping("/users/{id}")
    Result<UserResponse> getUser(@PathVariable String id);
    
    @GetMapping("/organizations/{id}")
    Result<OrganizationResponse> getOrganization(@PathVariable String id);
}
```

### 3.2 异步通信（消息队列，可选）

**使用场景**:
- 订单状态变更通知
- 工作流事件通知
- 财务数据同步

**实现方式**:
- RabbitMQ
- Kafka
- RocketMQ

**初期**: 可以不使用消息队列，通过 HTTP 同步调用

---

## 4. 数据管理策略

### 4.1 数据库策略

**初期方案：共享数据库**

- 所有服务共享同一个 MySQL 数据库（`bantu_crm`）
- 每个服务只操作自己的表
- 通过服务间调用获取其他服务的数据

**优势**:
- 简化部署和运维
- 支持跨服务事务（如果需要）
- 降低数据一致性复杂度

**劣势**:
- 服务间存在数据耦合
- 数据库成为单点

**演进方案**:
- 当服务规模扩大后，可以逐步拆分数据库
- 每个服务独立数据库
- 通过事件同步数据

### 4.2 数据访问规则

| 服务 | 可写表 | 只读表（通过服务调用） |
|------|--------|----------------------|
| foundation-service | users, organizations, roles, user_roles, organization_employees | - |
| business-service | customers, contacts, products, orders, order_assignments, order_stages, deliverables | users, organizations（通过 foundation-service） |
| workflow-service | ACT_* (Activiti 表) | orders（通过 business-service） |
| finance-service | payments | orders（通过 business-service） |

---

## 5. 服务注册与发现

### 5.1 方案选择

**方案 1: Spring Cloud Eureka（推荐用于小规模）**
- 简单易用
- 适合中小规模项目

**方案 2: Nacos**
- 功能更丰富（配置中心 + 服务发现）
- 阿里开源

**方案 3: Consul**
- 功能完整
- 支持健康检查

**方案 4: Kubernetes Service（推荐，如果使用 K8s）**
- 利用 K8s 原生服务发现
- 无需额外组件

**推荐**: 如果部署在 Kubernetes，直接使用 K8s Service，无需额外的服务注册中心

---

## 6. 配置管理

### 6.1 配置策略

**方案 1: 配置文件（初期）**
- 每个服务独立的 `application.yml`
- 通过 ConfigMap 管理（K8s）

**方案 2: 配置中心（后期）**
- Nacos Config
- Spring Cloud Config
- Apollo

**推荐**: 初期使用配置文件 + ConfigMap，后期根据需要引入配置中心

---

## 7. 项目结构规划

### 7.1 整体项目结构

```
crm-backend/
│
├── crm-gateway/                    # API 网关服务
│   ├── pom.xml
│   └── src/main/java/com/bantu/gateway/
│
├── crm-foundation-service/         # 基础服务
│   ├── pom.xml
│   └── src/main/java/com/bantu/foundation/
│       ├── controller/
│       ├── service/
│       ├── mapper/
│       └── entity/
│
├── crm-business-service/           # 业务服务
│   ├── pom.xml
│   └── src/main/java/com/bantu/business/
│       ├── controller/
│       ├── service/
│       ├── mapper/
│       ├── entity/
│       └── client/                 # Feign 客户端
│
├── crm-workflow-service/           # 工作流服务
│   ├── pom.xml
│   └── src/main/java/com/bantu/workflow/
│       ├── controller/
│       ├── service/
│       └── resources/processes/   # BPMN 文件
│
├── crm-finance-service/            # 财务服务
│   ├── pom.xml
│   └── src/main/java/com/bantu/finance/
│
└── crm-common/                     # 公共模块（共享）
    ├── pom.xml
    └── src/main/java/com/bantu/common/
        ├── result/                 # 统一返回结果
        ├── exception/              # 异常类
        ├── dto/                    # 公共 DTO
        └── client/                 # Feign 客户端接口定义
```

### 7.2 公共模块设计

**crm-common 模块包含**:
- 统一返回结果（Result, PageResult）
- 异常类（BusinessException, SystemException）
- 工具类（DateUtil, StringUtil）
- Feign 客户端接口定义（供各服务实现）
- 公共配置类

**依赖关系**:
- 所有服务都依赖 `crm-common`
- 服务间通过 Feign 客户端接口通信

---

## 8. 服务间调用示例

### 8.1 business-service 调用 foundation-service

```java
// crm-common 中定义接口
package com.bantu.common.client;

@FeignClient(name = "crm-foundation-service", path = "/api/foundation")
public interface FoundationClient {
    @GetMapping("/users/{id}")
    Result<UserResponse> getUser(@PathVariable String id);
    
    @GetMapping("/organizations/{id}")
    Result<OrganizationResponse> getOrganization(@PathVariable String id);
}

// business-service 中使用
@Service
public class OrderService {
    @Autowired
    private FoundationClient foundationClient;
    
    public OrderResponse getOrderWithUser(String orderId) {
        Order order = orderMapper.selectById(orderId);
        
        // 调用 foundation-service 获取用户信息
        Result<UserResponse> userResult = foundationClient.getUser(order.getSalesUserId());
        UserResponse user = userResult.getData();
        
        // 组装返回结果
        OrderResponse response = new OrderResponse();
        response.setOrder(order);
        response.setSalesUser(user);
        return response;
    }
}
```

### 8.2 business-service 调用 workflow-service

```java
// crm-common 中定义接口
@FeignClient(name = "crm-workflow-service", path = "/api/workflow")
public interface WorkflowClient {
    @PostMapping("/process/start")
    Result<ProcessInstanceResponse> startProcess(@RequestBody StartProcessRequest request);
    
    @GetMapping("/tasks/user/{userId}")
    Result<List<TaskResponse>> getTasksByUser(@PathVariable String userId);
}

// business-service 中使用
@Service
public class OrderService {
    @Autowired
    private WorkflowClient workflowClient;
    
    public void createOrderWithWorkflow(OrderCreateRequest request) {
        // 1. 创建订单
        Order order = createOrder(request);
        
        // 2. 启动工作流
        StartProcessRequest workflowRequest = new StartProcessRequest();
        workflowRequest.setProcessKey("orderApproval");
        workflowRequest.setVariables(Map.of("orderId", order.getId()));
        
        Result<ProcessInstanceResponse> result = workflowClient.startProcess(workflowRequest);
        ProcessInstanceResponse processInstance = result.getData();
        
        // 3. 关联流程实例ID
        order.setProcessInstanceId(processInstance.getId());
        orderMapper.updateById(order);
    }
}
```

---

## 9. 认证授权方案

### 9.1 JWT Token 策略

**Token 生成**:
- 由 `crm-foundation-service` 生成（登录接口）
- 包含用户ID、组织ID、角色列表

**Token 验证**:
- 在 `crm-gateway-service` 统一验证
- 验证通过后，将用户信息放入请求头传递给后端服务

**Token 传递**:
- 通过 HTTP Header: `Authorization: Bearer {token}`
- 各服务从 Header 中获取用户信息

### 9.2 权限控制

- **网关层**: 统一认证（JWT 验证）
- **服务层**: 基于角色的权限控制（RBAC）
- **数据层**: 组织级数据隔离

---

## 10. 部署架构

### 10.1 Kubernetes 部署

```
Kubernetes Cluster
├── Namespace: crm
│   ├── Gateway Service
│   │   ├── Deployment: crm-gateway
│   │   └── Service: crm-gateway (NodePort/LoadBalancer)
│   │
│   ├── Foundation Service
│   │   ├── Deployment: crm-foundation-service
│   │   └── Service: crm-foundation-service (ClusterIP)
│   │
│   ├── Business Service
│   │   ├── Deployment: crm-business-service
│   │   └── Service: crm-business-service (ClusterIP)
│   │
│   ├── Workflow Service
│   │   ├── Deployment: crm-workflow-service
│   │   └── Service: crm-workflow-service (ClusterIP)
│   │
│   ├── Finance Service
│   │   ├── Deployment: crm-finance-service
│   │   └── Service: crm-finance-service (ClusterIP)
│   │
│   └── MySQL
│       ├── Deployment: mysql
│       └── Service: mysql (ClusterIP)
```

### 10.2 服务发现（Kubernetes）

使用 Kubernetes Service 进行服务发现：

```yaml
# foundation-service 的 Service
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

Feign 客户端配置：
```yaml
# application.yml
feign:
  client:
    config:
      crm-foundation-service:
        url: http://crm-foundation-service:8081
```

---

## 11. 监控与日志

### 11.1 日志管理

**方案 1: 集中式日志（推荐）**
- ELK Stack（Elasticsearch + Logstash + Kibana）
- 或 Loki + Grafana

**方案 2: 分布式日志**
- 每个服务独立日志文件
- 通过日志收集工具汇总

### 11.2 监控

- **应用监控**: Spring Boot Actuator + Prometheus + Grafana
- **链路追踪**: Spring Cloud Sleuth + Zipkin（可选）
- **健康检查**: Actuator Health Endpoint

---

## 12. 开发优先级

### 第一阶段：基础服务（2-3周）

1. **crm-foundation-service**
   - 用户管理
   - 组织管理
   - 角色管理
   - 登录认证

2. **crm-gateway-service**
   - 路由配置
   - JWT 认证
   - 请求转发

### 第二阶段：业务服务（3-4周）

3. **crm-business-service**
   - 客户管理
   - 产品管理
   - 订单管理
   - 交付管理

4. **crm-workflow-service**
   - Activiti 集成
   - 工作流 API
   - 流程定义管理

### 第三阶段：财务服务（2周）

5. **crm-finance-service**
   - 收款管理
   - 付款管理
   - 财务报表

### 第四阶段：优化（持续）

6. 服务间调用优化
7. 性能优化
8. 监控完善

---

## 13. 技术栈汇总

### 13.1 各服务技术栈

| 服务 | Spring Boot | MyBatis-Plus | Activiti | 其他 |
|------|------------|--------------|----------|------|
| gateway-service | ✅ | ❌ | ❌ | Spring Cloud Gateway |
| foundation-service | ✅ | ✅ | ❌ | JWT |
| business-service | ✅ | ✅ | ❌ | Feign Client |
| workflow-service | ✅ | ✅ | ✅ | - |
| finance-service | ✅ | ✅ | ❌ | Feign Client |

### 13.2 公共技术栈

- **Java**: 17（推荐）或 11
- **Spring Boot**: 3.1.0 或 2.7.x
- **Spring Cloud**: OpenFeign（服务调用）
- **MyBatis-Plus**: 3.5.3.1
- **Activiti**: 7.1.0
- **MySQL**: 8.0+
- **Lombok**: 1.18.28

---

## 14. 优势与挑战

### 14.1 优势

✅ **适度拆分**: 5 个服务，易于管理
✅ **职责清晰**: 每个服务有明确的业务边界
✅ **独立部署**: 可以独立部署和扩展
✅ **技术选型灵活**: 各服务可以使用不同技术栈（如果需要）
✅ **团队协作**: 不同团队可以负责不同服务

### 14.2 挑战与应对

⚠️ **服务间调用复杂度**
- 应对: 使用 Feign 简化调用，统一异常处理

⚠️ **数据一致性**
- 应对: 初期共享数据库，后期考虑分布式事务或最终一致性

⚠️ **部署复杂度**
- 应对: 使用 Kubernetes 统一部署和管理

⚠️ **调试困难**
- 应对: 完善的日志和链路追踪

---

## 15. 演进路径

### 阶段 1: 单体应用（可选，快速验证）

如果团队规模小，可以先开发单体应用，验证业务逻辑。

### 阶段 2: 粗粒度微服务（当前规划）

按业务域拆分为 5 个服务，共享数据库。

### 阶段 3: 细粒度微服务（未来，如果需要）

- 订单服务独立
- 客户服务独立
- 产品服务独立
- 每个服务独立数据库

### 阶段 4: 服务网格（未来，大规模）

引入 Istio 等服务网格，统一管理服务间通信。

---

## 16. 总结

### 16.1 服务拆分总结

**5 个服务**:
1. **crm-gateway-service** - API 网关
2. **crm-foundation-service** - 基础管理
3. **crm-business-service** - 核心业务
4. **crm-workflow-service** - 工作流引擎
5. **crm-finance-service** - 财务管理

**特点**:
- 数量适中，不会过度拆分
- 职责清晰，易于理解
- 独立部署，灵活扩展
- 共享数据库，降低复杂度

### 16.2 下一步行动

1. 创建各服务的 Maven 项目结构
2. 配置服务间调用（Feign）
3. 实现第一个服务（foundation-service）
4. 配置网关路由
5. 实现服务间调用示例

