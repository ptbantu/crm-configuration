# BANTU CRM 后端架构规划文档

## 1. 技术栈选型

### 1.1 核心框架

| 技术 | 版本 | 用途 | 说明 |
|------|------|------|------|
| **Spring Boot** | 2.7.x / 3.x | 应用框架 | 微服务基础框架 |
| **MyBatis-Plus** | 3.5.x | ORM 框架 | 数据库操作，推荐使用 Plus 版本 |
| **Spring Activiti** | 7.1.0 | 工作流引擎 | 业务流程管理 |
| **MySQL** | 8.0+ | 数据库 | 已部署在 K8s |
| **Java** | 11 / 17 | 开发语言 | 推荐 Java 17 |

### 1.2 技术选型说明

#### Spring Boot
- **优势**: 
  - 快速开发，约定优于配置
  - 丰富的 Starter 生态
  - 与 Activiti 集成良好
- **版本建议**: 
  - 如果使用 Java 17+，推荐 Spring Boot 3.x
  - 如果使用 Java 11，使用 Spring Boot 2.7.x

#### MyBatis-Plus vs MyBatis
- **推荐 MyBatis-Plus**:
  - 提供 CRUD 自动生成
  - 分页插件内置
  - 代码生成器
  - 条件构造器简化查询
  - 与 MyBatis 完全兼容
- **MyBatis**: 
  - 如果项目已有 MyBatis 基础，可继续使用
  - 需要手动编写更多代码

#### Spring Activiti
- **版本**: Activiti 7.1.0（最新稳定版）
- **集成方式**: 
  - `activiti-spring-boot-starter`
  - 与 Spring Boot 无缝集成
  - 自动配置数据源

---

## 2. 项目结构规划

### 2.1 标准 Maven 多模块结构

```
crm-backend/
├── pom.xml                          # 父 POM
├── README.md
├── .gitignore
│
├── crm-common/                      # 公共模块
│   ├── src/main/java/com/bantu/common/
│   │   ├── constant/                # 常量定义
│   │   ├── exception/               # 异常类
│   │   ├── util/                    # 工具类
│   │   ├── result/                  # 统一返回结果
│   │   └── config/                  # 公共配置
│   └── pom.xml
│
├── crm-database/                    # 数据库模块
│   ├── src/main/java/com/bantu/database/
│   │   ├── entity/                  # 实体类（对应数据库表）
│   │   ├── mapper/                  # MyBatis Mapper
│   │   └── service/                 # 基础 Service
│   └── pom.xml
│
├── crm-workflow/                    # 工作流模块（Activiti）
│   ├── src/main/java/com/bantu/workflow/
│   │   ├── service/                 # 工作流服务
│   │   ├── controller/              # 工作流 API
│   │   └── config/                  # Activiti 配置
│   ├── src/main/resources/
│   │   └── processes/               # BPMN 流程定义文件
│   └── pom.xml
│
├── crm-module-foundation/           # 基础管理模块
│   ├── src/main/java/com/bantu/foundation/
│   │   ├── controller/              # 组织、用户、角色管理
│   │   ├── service/
│   │   └── dto/                     # 数据传输对象
│   └── pom.xml
│
├── crm-module-product/              # 产品管理模块
│   ├── src/main/java/com/bantu/product/
│   │   ├── controller/
│   │   ├── service/
│   │   └── dto/
│   └── pom.xml
│
├── crm-module-customer/             # 客户管理模块
│   ├── src/main/java/com/bantu/customer/
│   │   ├── controller/
│   │   ├── service/
│   │   └── dto/
│   └── pom.xml
│
├── crm-module-order/                # 订单管理模块
│   ├── src/main/java/com/bantu/order/
│   │   ├── controller/
│   │   ├── service/
│   │   ├── workflow/                # 订单工作流集成
│   │   └── dto/
│   └── pom.xml
│
├── crm-module-delivery/             # 交付管理模块
│   └── ...
│
├── crm-module-finance/              # 财务管理模块
│   └── ...
│
├── crm-module-vendor/               # 供应商管理模块
│   └── ...
│
├── crm-module-agent/                # 渠道代理模块
│   └── ...
│
└── crm-api/                         # API 网关/主应用
    ├── src/main/java/com/bantu/api/
    │   ├── CrmApplication.java      # 启动类
    │   ├── config/                  # 全局配置
    │   │   ├── WebConfig.java       # Web 配置
    │   │   ├── SecurityConfig.java  # 安全配置
    │   │   ├── MyBatisConfig.java   # MyBatis 配置
    │   │   └── ActivitiConfig.java  # Activiti 配置
    │   ├── interceptor/             # 拦截器
    │   └── filter/                  # 过滤器
    ├── src/main/resources/
    │   ├── application.yml          # 主配置
    │   ├── application-dev.yml      # 开发环境
    │   ├── application-prod.yml     # 生产环境
    │   └── mapper/                  # MyBatis XML（如果需要）
    └── pom.xml
```

### 2.2 包结构规范

#### 2.2.1 标准包结构（每个模块）

```
com.bantu.{module}/
├── controller/          # 控制器层
│   ├── {Entity}Controller.java
│   └── ...
├── service/             # 服务层
│   ├── {Entity}Service.java
│   ├── impl/
│   │   └── {Entity}ServiceImpl.java
│   └── ...
├── mapper/              # 数据访问层（MyBatis）
│   ├── {Entity}Mapper.java
│   └── ...
├── entity/              # 实体类（对应数据库表）
│   ├── {Entity}.java
│   └── ...
├── dto/                 # 数据传输对象
│   ├── request/         # 请求 DTO
│   │   ├── {Entity}CreateRequest.java
│   │   └── {Entity}UpdateRequest.java
│   ├── response/        # 响应 DTO
│   │   └── {Entity}Response.java
│   └── query/           # 查询 DTO
│       └── {Entity}Query.java
├── vo/                  # 视图对象（可选）
└── config/              # 模块特定配置
```

---

## 3. 依赖管理规划

### 3.1 父 POM 依赖管理

```xml
<properties>
    <java.version>17</java.version>
    <spring-boot.version>3.1.0</spring-boot.version>
    <mybatis-plus.version>3.5.3.1</mybatis-plus.version>
    <activiti.version>7.1.0</activiti.version>
    <mysql.version>8.0.33</mysql.version>
    <lombok.version>1.18.28</lombok.version>
</properties>

<dependencyManagement>
    <dependencies>
        <!-- Spring Boot -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-dependencies</artifactId>
            <version>${spring-boot.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
        
        <!-- MyBatis-Plus -->
        <dependency>
            <groupId>com.baomidou</groupId>
            <artifactId>mybatis-plus-boot-starter</artifactId>
            <version>${mybatis-plus.version}</version>
        </dependency>
        
        <!-- Activiti -->
        <dependency>
            <groupId>org.activiti</groupId>
            <artifactId>activiti-spring-boot-starter</artifactId>
            <version>${activiti.version}</version>
        </dependency>
        
        <!-- MySQL -->
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>${mysql.version}</version>
        </dependency>
    </dependencies>
</dependencyManagement>
```

### 3.2 各模块依赖

#### crm-common 模块
```xml
<dependencies>
    <!-- Spring Boot Web -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    
    <!-- Lombok -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>
    
    <!-- 工具类 -->
    <dependency>
        <groupId>cn.hutool</groupId>
        <artifactId>hutool-all</artifactId>
        <version>5.8.20</version>
    </dependency>
</dependencies>
```

#### crm-database 模块
```xml
<dependencies>
    <!-- MyBatis-Plus -->
    <dependency>
        <groupId>com.baomidou</groupId>
        <artifactId>mybatis-plus-boot-starter</artifactId>
    </dependency>
    
    <!-- MySQL Driver -->
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
    </dependency>
    
    <!-- 依赖 common -->
    <dependency>
        <groupId>com.bantu</groupId>
        <artifactId>crm-common</artifactId>
        <version>${project.version}</version>
    </dependency>
</dependencies>
```

#### crm-workflow 模块
```xml
<dependencies>
    <!-- Activiti Spring Boot Starter -->
    <dependency>
        <groupId>org.activiti</groupId>
        <artifactId>activiti-spring-boot-starter</artifactId>
    </dependency>
    
    <!-- 依赖 database（需要实体类） -->
    <dependency>
        <groupId>com.bantu</groupId>
        <artifactId>crm-database</artifactId>
        <version>${project.version}</version>
    </dependency>
</dependencies>
```

#### crm-api 主应用
```xml
<dependencies>
    <!-- 所有业务模块 -->
    <dependency>
        <groupId>com.bantu</groupId>
        <artifactId>crm-module-foundation</artifactId>
        <version>${project.version}</version>
    </dependency>
    <!-- ... 其他模块 -->
    
    <!-- 工作流模块 -->
    <dependency>
        <groupId>com.bantu</groupId>
        <artifactId>crm-workflow</artifactId>
        <version>${project.version}</version>
    </dependency>
    
    <!-- Spring Boot Actuator（健康检查） -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
</dependencies>
```

---

## 4. 配置文件规划

### 4.1 application.yml 结构

```yaml
spring:
  application:
    name: bantu-crm-api
  
  # 数据源配置（复用现有 MySQL）
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://mysql:3306/bantu_crm?useSSL=false&serverTimezone=UTC&characterEncoding=utf8&useUnicode=true&allowPublicKeyRetrieval=true
    username: ${DB_USER:bantu_user}
    password: ${DB_PASSWORD:bantu_user_password_2024}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
  
  # MyBatis-Plus 配置
  mybatis-plus:
    mapper-locations: classpath*:mapper/**/*.xml
    type-aliases-package: com.bantu.database.entity
    configuration:
      map-underscore-to-camel-case: true
      log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
    global-config:
      db-config:
        id-type: assign_id  # UUID 主键策略
        logic-delete-field: deleted
        logic-delete-value: 1
        logic-not-delete-value: 0
  
  # Activiti 配置
  activiti:
    database-schema-update: true  # 自动创建/更新表
    async-executor-activate: true  # 启用异步执行器
    history-level: full  # 完整历史记录
    check-process-definitions: true  # 检查流程定义
    process-definition-location-prefix: classpath:/processes/
    process-definition-location-suffixes: .bpmn20.xml,.bpmn

# MyBatis-Plus 分页配置
mybatis-plus:
  configuration:
    # 分页插件
    plugins:
      - com.baomidou.mybatis-plus.extension.plugins.pagination.PageInterceptor

# 服务器配置
server:
  port: 8080
  servlet:
    context-path: /api

# 日志配置
logging:
  level:
    com.bantu: DEBUG
    org.activiti: INFO
    com.baomidou.mybatisplus: DEBUG
```

### 4.2 环境配置分离

- `application.yml`: 公共配置
- `application-dev.yml`: 开发环境（本地 MySQL）
- `application-prod.yml`: 生产环境（K8s MySQL）

---

## 5. 数据库集成规划

### 5.1 实体类设计原则

1. **对应数据库表**: 每个实体类对应一个数据库表
2. **使用 MyBatis-Plus 注解**:
   - `@TableName`: 表名映射
   - `@TableId`: 主键配置（UUID）
   - `@TableField`: 字段映射
3. **继承 BaseEntity**（可选）:
   ```java
   public class BaseEntity {
       @TableId(type = IdType.ASSIGN_ID)
       private String id;
       private LocalDateTime createdAt;
       private LocalDateTime updatedAt;
   }
   ```

### 5.2 Mapper 设计

1. **继承 BaseMapper**: 自动获得 CRUD 方法
   ```java
   @Mapper
   public interface UserMapper extends BaseMapper<User> {
       // 自定义查询方法
   }
   ```

2. **使用 MyBatis-Plus 条件构造器**:
   ```java
   QueryWrapper<User> wrapper = new QueryWrapper<>();
   wrapper.eq("organization_id", orgId)
          .eq("is_active", true);
   List<User> users = userMapper.selectList(wrapper);
   ```

### 5.3 与现有 Schema 的映射

根据 `schema_mysql.sql`，需要创建以下实体类：

- `Organization` → `organizations` 表
- `User` → `users` 表
- `Role` → `roles` 表
- `UserRole` → `user_roles` 表
- `OrganizationEmployee` → `organization_employees` 表
- `Product` → `products` 表
- `Customer` → `customers` 表
- `Order` → `orders` 表
- `OrderAssignment` → `order_assignments` 表
- `Payment` → `payments` 表
- ... 等

---

## 6. Activiti 工作流集成规划

### 6.1 Activiti 服务注入

```java
@Service
public class WorkflowService {
    
    @Autowired
    private RuntimeService runtimeService;  // 流程实例管理
    
    @Autowired
    private TaskService taskService;  // 任务管理
    
    @Autowired
    private RepositoryService repositoryService;  // 流程定义管理
    
    @Autowired
    private HistoryService historyService;  // 历史查询
}
```

### 6.2 工作流与业务集成

#### 6.2.1 订单工作流集成

```java
@Service
public class OrderService {
    
    @Autowired
    private RuntimeService runtimeService;
    
    @Autowired
    private OrderMapper orderMapper;
    
    /**
     * 创建订单并启动工作流
     */
    public Order createOrder(OrderCreateRequest request) {
        // 1. 创建订单记录
        Order order = new Order();
        // ... 设置订单信息
        orderMapper.insert(order);
        
        // 2. 启动工作流
        Map<String, Object> variables = new HashMap<>();
        variables.put("orderId", order.getId());
        variables.put("customerId", order.getCustomerId());
        
        ProcessInstance processInstance = runtimeService
            .startProcessInstanceByKey("orderApproval", variables);
        
        // 3. 关联流程实例ID
        order.setProcessInstanceId(processInstance.getId());
        orderMapper.updateById(order);
        
        return order;
    }
}
```

#### 6.2.2 任务查询与处理

```java
@Service
public class OrderWorkflowService {
    
    @Autowired
    private TaskService taskService;
    
    /**
     * 查询用户待办任务
     */
    public List<Task> getPendingTasks(String userId) {
        return taskService.createTaskQuery()
            .taskAssignee(userId)
            .active()
            .list();
    }
    
    /**
     * 完成任务
     */
    public void completeTask(String taskId, Map<String, Object> variables) {
        taskService.complete(taskId, variables);
    }
}
```

### 6.3 BPMN 流程定义位置

- 位置: `crm-workflow/src/main/resources/processes/`
- 文件格式: `.bpmn20.xml` 或 `.bpmn`
- 示例流程:
  - `order-approval.bpmn20.xml` - 订单审批流程
  - `delivery-review.bpmn20.xml` - 交付物审核流程
  - `payment-approval.bpmn20.xml` - 付款审批流程

---

## 7. 模块开发优先级

### 第一阶段（MVP - 2-3周）

1. **crm-common** - 公共模块
   - 统一返回结果
   - 异常处理
   - 工具类

2. **crm-database** - 数据库模块
   - 核心实体类（User, Organization, Role）
   - Mapper 接口
   - 基础 Service

3. **crm-module-foundation** - 基础管理模块
   - 用户管理 API
   - 组织管理 API
   - 角色管理 API
   - 登录认证

4. **crm-api** - 主应用
   - 项目结构搭建
   - 配置整合
   - 启动验证

### 第二阶段（核心业务 - 3-4周）

5. **crm-module-customer** - 客户管理
6. **crm-module-product** - 产品管理
7. **crm-module-order** - 订单管理
8. **crm-workflow** - 工作流模块（基础）

### 第三阶段（工作流集成 - 2-3周）

9. **crm-workflow** - 工作流完整实现
   - 订单审批流程
   - 交付物审核流程
   - 工作流 API

10. **crm-module-order** - 订单工作流集成

### 第四阶段（扩展功能 - 持续）

11. **crm-module-delivery** - 交付管理
12. **crm-module-finance** - 财务管理
13. **crm-module-vendor** - 供应商管理
14. **crm-module-agent** - 渠道代理管理

---

## 8. 技术规范

### 8.1 编码规范

- **命名规范**: 
  - 类名: 大驼峰（PascalCase）
  - 方法名/变量名: 小驼峰（camelCase）
  - 常量: 大写下划线（UPPER_SNAKE_CASE）
- **包名**: 全小写，使用点分隔
- **注释**: 类和方法必须有 JavaDoc

### 8.2 接口设计规范

- **RESTful API**:
  - GET: 查询
  - POST: 创建
  - PUT: 更新
  - DELETE: 删除
- **统一返回格式**:
  ```java
  {
    "code": 200,
    "message": "success",
    "data": {...}
  }
  ```

### 8.3 异常处理

- **统一异常处理**: 使用 `@ControllerAdvice`
- **自定义异常**: 业务异常、系统异常
- **错误码**: 统一错误码定义

### 8.4 日志规范

- 使用 SLF4J + Logback
- 日志级别: DEBUG（开发）、INFO（生产）
- 关键操作记录日志

---

## 9. 安全规划

### 9.1 认证授权

- **JWT Token**: 用户认证
- **Spring Security**: 安全框架（可选）
- **权限控制**: 基于角色的访问控制（RBAC）

### 9.2 数据安全

- **SQL 注入防护**: MyBatis 参数化查询
- **XSS 防护**: 输入验证和转义
- **敏感数据加密**: 密码等敏感信息加密存储

---

## 10. 测试规划

### 10.1 单元测试

- **JUnit 5**: 测试框架
- **Mockito**: Mock 框架
- **覆盖率**: 核心业务逻辑 > 80%

### 10.2 集成测试

- **Spring Boot Test**: 集成测试
- **Testcontainers**: 数据库测试容器（可选）

---

## 11. 部署规划

### 11.1 Docker 镜像构建

- **Dockerfile**: 多阶段构建
- **镜像标签**: 版本号 + 构建时间
- **基础镜像**: `openjdk:17-jre-slim`

### 11.2 Kubernetes 部署

- **Deployment**: 应用部署
- **Service**: 服务暴露
- **ConfigMap**: 配置管理
- **Secret**: 敏感信息

---

## 12. 开发工具推荐

- **IDE**: IntelliJ IDEA
- **构建工具**: Maven
- **版本控制**: Git
- **API 文档**: Swagger/OpenAPI 3
- **代码生成**: MyBatis-Plus Generator

---

## 13. 下一步行动

1. ✅ 创建项目结构（Maven 多模块）
2. ✅ 配置父 POM 依赖管理
3. ✅ 创建各模块基础结构
4. ✅ 配置 application.yml
5. ✅ 创建核心实体类（User, Organization, Role）
6. ✅ 实现基础 CRUD（用户管理）
7. ✅ 集成 Activiti 工作流
8. ✅ 实现第一个工作流（订单审批）

---

## 14. 参考资料

- [Spring Boot 官方文档](https://spring.io/projects/spring-boot)
- [MyBatis-Plus 文档](https://baomidou.com/)
- [Activiti 官方文档](https://www.activiti.org/)
- [BPMN 2.0 规范](https://www.omg.org/spec/BPMN/2.0/)

