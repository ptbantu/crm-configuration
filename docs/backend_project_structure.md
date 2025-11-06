# BANTU CRM 后端项目结构详细规划

## 1. Maven 多模块项目结构

```
crm-backend/
│
├── pom.xml                                    # 父 POM，管理所有模块
│
├── crm-common/                                # 公共模块
│   ├── pom.xml
│   └── src/main/java/com/bantu/common/
│       ├── constant/                          # 常量定义
│       │   ├── ResponseCode.java              # 响应码
│       │   ├── UserStatus.java                # 用户状态
│       │   └── OrderStatus.java               # 订单状态
│       ├── exception/                          # 异常类
│       │   ├── BusinessException.java         # 业务异常
│       │   ├── SystemException.java           # 系统异常
│       │   └── GlobalExceptionHandler.java     # 全局异常处理
│       ├── result/                            # 统一返回结果
│       │   ├── Result.java                    # 统一响应封装
│       │   └── PageResult.java                # 分页结果
│       ├── util/                              # 工具类
│       │   ├── DateUtil.java
│       │   ├── StringUtil.java
│       │   └── JsonUtil.java
│       └── config/                            # 公共配置
│           └── JacksonConfig.java            # JSON 配置
│
├── crm-database/                              # 数据库模块
│   ├── pom.xml
│   └── src/main/java/com/bantu/database/
│       ├── entity/                            # 实体类（对应数据库表）
│       │   ├── Organization.java              # 组织实体
│       │   ├── User.java                      # 用户实体
│       │   ├── Role.java                      # 角色实体
│       │   ├── UserRole.java                  # 用户角色关联
│       │   ├── OrganizationEmployee.java      # 组织员工
│       │   ├── Product.java                   # 产品
│       │   ├── Customer.java                  # 客户
│       │   ├── Order.java                     # 订单
│       │   ├── OrderAssignment.java           # 订单分配
│       │   ├── Payment.java                   # 收款
│       │   └── ...                            # 其他实体
│       ├── mapper/                            # MyBatis Mapper 接口
│       │   ├── OrganizationMapper.java
│       │   ├── UserMapper.java
│       │   ├── RoleMapper.java
│       │   └── ...
│       └── service/                           # 基础 Service（可选）
│           └── BaseService.java              # 基础服务接口
│
├── crm-workflow/                              # 工作流模块（Activiti）
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/bantu/workflow/
│       │   ├── config/
│       │   │   └── ActivitiConfig.java       # Activiti 配置
│       │   ├── service/
│       │   │   ├── WorkflowService.java       # 工作流服务
│       │   │   ├── ProcessService.java       # 流程定义服务
│       │   │   ├── TaskService.java          # 任务服务（包装 Activiti）
│       │   │   └── HistoryService.java        # 历史查询服务
│       │   ├── controller/
│       │   │   ├── WorkflowController.java   # 工作流 API
│       │   │   └── TaskController.java       # 任务 API
│       │   └── dto/
│       │       ├── ProcessDefinitionDTO.java
│       │       ├── ProcessInstanceDTO.java
│       │       └── TaskDTO.java
│       └── resources/
│           └── processes/                     # BPMN 流程定义文件
│               ├── order-approval.bpmn20.xml  # 订单审批流程
│               ├── delivery-review.bpmn20.xml # 交付物审核流程
│               └── payment-approval.bpmn20.xml # 付款审批流程
│
├── crm-module-foundation/                     # 基础管理模块
│   ├── pom.xml
│   └── src/main/java/com/bantu/foundation/
│       ├── controller/
│       │   ├── OrganizationController.java   # 组织管理 API
│       │   ├── UserController.java           # 用户管理 API
│       │   ├── RoleController.java           # 角色管理 API
│       │   └── AuthController.java           # 认证 API
│       ├── service/
│       │   ├── OrganizationService.java
│       │   ├── UserService.java
│       │   ├── RoleService.java
│       │   └── AuthService.java
│       ├── mapper/
│       │   └── ...                            # 继承 database 模块的 Mapper
│       └── dto/
│           ├── request/
│           │   ├── UserCreateRequest.java
│           │   ├── UserUpdateRequest.java
│           │   └── LoginRequest.java
│           ├── response/
│           │   ├── UserResponse.java
│           │   └── LoginResponse.java
│           └── query/
│               └── UserQuery.java
│
├── crm-module-product/                        # 产品管理模块
│   ├── pom.xml
│   └── src/main/java/com/bantu/product/
│       ├── controller/
│       │   ├── ProductController.java
│       │   └── ProductCategoryController.java
│       ├── service/
│       │   ├── ProductService.java
│       │   └── ProductCategoryService.java
│       └── dto/
│
├── crm-module-customer/                       # 客户管理模块
│   ├── pom.xml
│   └── src/main/java/com/bantu/customer/
│       ├── controller/
│       │   ├── CustomerController.java
│       │   ├── ContactController.java
│       │   └── CustomerSourceController.java
│       ├── service/
│       │   ├── CustomerService.java
│       │   └── ContactService.java
│       └── dto/
│
├── crm-module-order/                          # 订单管理模块
│   ├── pom.xml
│   └── src/main/java/com/bantu/order/
│       ├── controller/
│       │   ├── OrderController.java
│       │   ├── OrderAssignmentController.java
│       │   └── OrderStageController.java
│       ├── service/
│       │   ├── OrderService.java
│       │   ├── OrderAssignmentService.java
│       │   └── OrderStageService.java
│       ├── workflow/                          # 订单工作流集成
│       │   ├── OrderWorkflowService.java      # 订单工作流服务
│       │   └── OrderWorkflowListener.java    # 工作流监听器
│       └── dto/
│
├── crm-module-delivery/                       # 交付管理模块
│   └── ...
│
├── crm-module-finance/                        # 财务管理模块
│   └── ...
│
├── crm-module-vendor/                         # 供应商管理模块
│   └── ...
│
├── crm-module-agent/                          # 渠道代理模块
│   └── ...
│
└── crm-api/                                   # API 主应用
    ├── pom.xml
    └── src/main/
        ├── java/com/bantu/api/
        │   ├── CrmApplication.java            # Spring Boot 启动类
        │   ├── config/                        # 全局配置
        │   │   ├── WebConfig.java             # Web 配置（跨域、拦截器）
        │   │   ├── SecurityConfig.java        # 安全配置（JWT、权限）
        │   │   ├── MyBatisConfig.java         # MyBatis-Plus 配置
        │   │   ├── ActivitiConfig.java        # Activiti 配置（可选，已在 workflow 模块）
        │   │   └── SwaggerConfig.java         # API 文档配置
        │   ├── interceptor/                   # 拦截器
        │   │   ├── AuthInterceptor.java       # 认证拦截器
        │   │   └── LogInterceptor.java        # 日志拦截器
        │   └── filter/                        # 过滤器
        │       └── RequestLogFilter.java      # 请求日志过滤器
        └── resources/
            ├── application.yml                # 主配置文件
            ├── application-dev.yml            # 开发环境
            ├── application-prod.yml          # 生产环境
            └── mapper/                        # MyBatis XML（如果需要）
```

---

## 2. 模块依赖关系

```
crm-api (主应用)
  ├── crm-module-foundation
  │     ├── crm-database
  │     │     └── crm-common
  │     └── crm-common
  ├── crm-module-product
  │     ├── crm-database
  │     └── crm-common
  ├── crm-module-customer
  │     ├── crm-database
  │     └── crm-common
  ├── crm-module-order
  │     ├── crm-database
  │     ├── crm-workflow
  │     │     └── crm-database
  │     └── crm-common
  ├── crm-workflow
  │     ├── crm-database
  │     └── crm-common
  └── crm-common
```

**依赖说明**:
- 所有业务模块依赖 `crm-database` 和 `crm-common`
- `crm-module-order` 依赖 `crm-workflow`（订单工作流）
- `crm-workflow` 依赖 `crm-database`（需要实体类）
- `crm-api` 聚合所有模块

---

## 3. 核心实体类设计示例

### 3.1 User 实体类

```java
package com.bantu.database.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("users")
public class User {
    @TableId(type = IdType.ASSIGN_ID)
    private String id;
    
    @TableField("username")
    private String username;
    
    @TableField("email")
    private String email;
    
    @TableField("phone")
    private String phone;
    
    @TableField("display_name")
    private String displayName;
    
    @TableField("password_hash")
    private String passwordHash;
    
    @TableField("organization_id")
    private String organizationId;
    
    @TableField("is_active")
    private Boolean isActive;
    
    @TableField("last_login_at")
    private LocalDateTime lastLoginAt;
    
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
```

### 3.2 Organization 实体类

```java
package com.bantu.database.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("organizations")
public class Organization {
    @TableId(type = IdType.ASSIGN_ID)
    private String id;
    
    @TableField("name")
    private String name;
    
    @TableField("code")
    private String code;
    
    @TableField("organization_type")
    private String organizationType;  // 'internal', 'vendor', 'agent'
    
    @TableField("parent_id")
    private String parentId;
    
    @TableField("email")
    private String email;
    
    @TableField("phone")
    private String phone;
    
    @TableField("is_active")
    private Boolean isActive;
    
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
```

---

## 4. Mapper 接口设计示例

### 4.1 UserMapper

```java
package com.bantu.database.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bantu.database.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface UserMapper extends BaseMapper<User> {
    
    /**
     * 根据组织ID和用户名查询（组织内唯一）
     */
    User selectByOrganizationAndUsername(
        @Param("organizationId") String organizationId,
        @Param("username") String username
    );
    
    /**
     * 根据组织ID查询用户列表
     */
    List<User> selectByOrganizationId(@Param("organizationId") String organizationId);
    
    /**
     * 根据角色查询用户列表
     */
    List<User> selectByRoleCode(@Param("roleCode") String roleCode);
}
```

---

## 5. Service 层设计示例

### 5.1 UserService

```java
package com.bantu.foundation.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bantu.foundation.dto.request.UserCreateRequest;
import com.bantu.foundation.dto.request.UserUpdateRequest;
import com.bantu.foundation.dto.request.UserQuery;
import com.bantu.foundation.dto.response.UserResponse;

public interface UserService {
    
    /**
     * 创建用户
     */
    UserResponse createUser(UserCreateRequest request);
    
    /**
     * 更新用户
     */
    UserResponse updateUser(String userId, UserUpdateRequest request);
    
    /**
     * 查询用户详情
     */
    UserResponse getUserById(String userId);
    
    /**
     * 分页查询用户
     */
    Page<UserResponse> queryUsers(UserQuery query, Page<UserResponse> page);
    
    /**
     * 删除用户（软删除）
     */
    void deleteUser(String userId);
    
    /**
     * 启用/禁用用户
     */
    void toggleUserStatus(String userId, Boolean isActive);
}
```

---

## 6. Controller 层设计示例

### 6.1 UserController

```java
package com.bantu.foundation.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bantu.common.result.Result;
import com.bantu.common.result.PageResult;
import com.bantu.foundation.dto.request.UserCreateRequest;
import com.bantu.foundation.dto.request.UserUpdateRequest;
import com.bantu.foundation.dto.request.UserQuery;
import com.bantu.foundation.dto.response.UserResponse;
import com.bantu.foundation.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    @PostMapping
    public Result<UserResponse> createUser(@RequestBody UserCreateRequest request) {
        UserResponse user = userService.createUser(request);
        return Result.success(user);
    }
    
    @PutMapping("/{id}")
    public Result<UserResponse> updateUser(
            @PathVariable String id,
            @RequestBody UserUpdateRequest request) {
        UserResponse user = userService.updateUser(id, request);
        return Result.success(user);
    }
    
    @GetMapping("/{id}")
    public Result<UserResponse> getUser(@PathVariable String id) {
        UserResponse user = userService.getUserById(id);
        return Result.success(user);
    }
    
    @GetMapping
    public Result<PageResult<UserResponse>> queryUsers(
            UserQuery query,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size) {
        Page<UserResponse> pageParam = new Page<>(page, size);
        Page<UserResponse> result = userService.queryUsers(query, pageParam);
        return Result.success(PageResult.of(result));
    }
    
    @DeleteMapping("/{id}")
    public Result<Void> deleteUser(@PathVariable String id) {
        userService.deleteUser(id);
        return Result.success();
    }
}
```

---

## 7. Activiti 工作流集成示例

### 7.1 订单工作流服务

```java
package com.bantu.order.workflow;

import org.activiti.engine.RuntimeService;
import org.activiti.engine.TaskService;
import org.activiti.engine.runtime.ProcessInstance;
import org.activiti.engine.task.Task;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.Map;

@Service
public class OrderWorkflowService {
    
    @Autowired
    private RuntimeService runtimeService;
    
    @Autowired
    private TaskService taskService;
    
    /**
     * 启动订单审批流程
     */
    public ProcessInstance startOrderApprovalProcess(String orderId, String customerId) {
        Map<String, Object> variables = new HashMap<>();
        variables.put("orderId", orderId);
        variables.put("customerId", customerId);
        
        ProcessInstance processInstance = runtimeService
            .startProcessInstanceByKey("orderApproval", variables);
        
        return processInstance;
    }
    
    /**
     * 查询用户待办任务
     */
    public List<Task> getPendingTasks(String userId) {
        return taskService.createTaskQuery()
            .taskAssignee(userId)
            .active()
            .orderByTaskCreateTime()
            .desc()
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

---

## 8. 配置文件示例

### 8.1 application.yml（主配置）

```yaml
spring:
  application:
    name: bantu-crm-api
  
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://mysql:3306/bantu_crm?useSSL=false&serverTimezone=UTC&characterEncoding=utf8&useUnicode=true&allowPublicKeyRetrieval=true
    username: ${DB_USER:bantu_user}
    password: ${DB_PASSWORD:bantu_user_password_2024}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
  
  mybatis-plus:
    mapper-locations: classpath*:mapper/**/*.xml
    type-aliases-package: com.bantu.database.entity
    configuration:
      map-underscore-to-camel-case: true
    global-config:
      db-config:
        id-type: assign_id
  
  activiti:
    database-schema-update: true
    async-executor-activate: true
    history-level: full
    process-definition-location-prefix: classpath:/processes/
    process-definition-location-suffixes: .bpmn20.xml,.bpmn

server:
  port: 8080
  servlet:
    context-path: /api
```

---

## 9. 开发顺序建议

### 第一阶段：基础搭建（1周）

1. 创建 Maven 多模块项目结构
2. 配置父 POM 和依赖管理
3. 创建 `crm-common` 模块
4. 创建 `crm-database` 模块
5. 创建核心实体类（User, Organization, Role）
6. 创建 `crm-api` 主应用
7. 配置 application.yml
8. 验证数据库连接

### 第二阶段：基础管理模块（1-2周）

9. 创建 `crm-module-foundation` 模块
10. 实现 UserService 和 UserController
11. 实现 OrganizationService 和 OrganizationController
12. 实现 RoleService 和 RoleController
13. 实现登录认证（AuthService）
14. 集成 JWT Token

### 第三阶段：工作流集成（1周）

15. 创建 `crm-workflow` 模块
16. 配置 Activiti
17. 创建第一个 BPMN 流程定义
18. 实现工作流服务
19. 验证 Activiti 表创建

### 第四阶段：业务模块（持续）

20. 按优先级开发各业务模块
21. 集成工作流到业务模块

---

## 10. 技术选型确认

| 技术 | 版本 | 状态 |
|------|------|------|
| Spring Boot | 3.1.0 (Java 17) 或 2.7.x (Java 11) | ✅ 已选 |
| MyBatis-Plus | 3.5.3.1 | ✅ 已选 |
| Activiti | 7.1.0 | ✅ 已选 |
| MySQL | 8.0+ | ✅ 已部署 |
| Java | 17 (推荐) 或 11 | ⚠️ 待确认 |
| Lombok | 1.18.28 | ✅ 推荐 |
| Hutool | 5.8.20 | ✅ 推荐（工具类） |

---

## 11. 下一步行动清单

- [ ] 确认 Java 版本（11 或 17）
- [ ] 创建 Maven 多模块项目结构
- [ ] 配置父 POM 依赖管理
- [ ] 创建各模块基础结构
- [ ] 配置 application.yml
- [ ] 创建核心实体类
- [ ] 实现第一个 CRUD（用户管理）
- [ ] 集成 Activiti 工作流
- [ ] 创建第一个工作流定义

