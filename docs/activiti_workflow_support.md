# Activiti 工作流支持情况

## 当前状态

### 数据库状态

**检查时间**: 2025-11-06

#### Activiti 表结构

Activiti 工作流引擎使用以下表结构（`ACT_` 前缀）：

| 类别 | 表前缀 | 说明 | 表数量 |
|------|--------|------|--------|
| **Repository** | `ACT_RE_` | 流程定义、部署资源 | 3 |
| **Runtime** | `ACT_RU_` | 运行时流程实例、任务 | 8 |
| **History** | `ACT_HI_` | 历史记录 | 10 |
| **General** | `ACT_GE_` | 通用数据（字节数组、属性） | 2 |
| **Identity** | `ACT_ID_` | 身份信息（用户、组） | 7 |

**总计**: 约 30 个表

#### 核心表说明

**Repository (流程定义)**:
- `ACT_RE_DEPLOYMENT`: 部署信息
- `ACT_RE_PROCDEF`: 流程定义
- `ACT_RE_MODEL`: 流程模型

**Runtime (运行时)**:
- `ACT_RU_EXECUTION`: 流程执行实例
- `ACT_RU_TASK`: 任务
- `ACT_RU_VARIABLE`: 流程变量
- `ACT_RU_IDENTITYLINK`: 身份链接（任务分配）

**History (历史)**:
- `ACT_HI_PROCINST`: 流程实例历史
- `ACT_HI_ACTINST`: 活动实例历史
- `ACT_HI_TASKINST`: 任务实例历史
- `ACT_HI_VARINST`: 变量历史

**Identity (身份)**:
- `ACT_ID_USER`: 用户
- `ACT_ID_GROUP`: 组
- `ACT_ID_MEMBERSHIP`: 用户组关系

## Activiti 版本支持

### Activiti 7.x 特性

Activiti 7 是当前主要版本，支持以下功能：

#### 1. BPMN 2.0 支持

- ✅ **用户任务 (User Task)**: 人工任务
- ✅ **服务任务 (Service Task)**: 自动任务
- ✅ **脚本任务 (Script Task)**: 脚本执行
- ✅ **网关 (Gateways)**: 
  - 排他网关 (Exclusive Gateway)
  - 并行网关 (Parallel Gateway)
  - 包容网关 (Inclusive Gateway)
- ✅ **事件 (Events)**:
  - 开始事件 (Start Event)
  - 结束事件 (End Event)
  - 中间事件 (Intermediate Event)
  - 定时器事件 (Timer Event)
  - 消息事件 (Message Event)
- ✅ **子流程 (Subprocess)**: 嵌入子流程、调用子流程

#### 2. 流程定义管理

- ✅ 流程定义部署
- ✅ 流程定义版本管理
- ✅ 流程定义激活/挂起
- ✅ BPMN 2.0 XML 格式支持

#### 3. 流程实例管理

- ✅ 启动流程实例
- ✅ 查询流程实例
- ✅ 挂起/激活流程实例
- ✅ 删除流程实例
- ✅ 流程变量管理

#### 4. 任务管理

- ✅ 任务查询
- ✅ 任务分配（用户、组）
- ✅ 任务完成
- ✅ 任务委派
- ✅ 任务候选人和候选组

#### 5. 历史记录

- ✅ 完整历史记录（`history-level: full`）
- ✅ 流程实例历史
- ✅ 任务历史
- ✅ 变量历史
- ✅ 活动历史

#### 6. 集成能力

- ✅ Spring Boot 集成
- ✅ REST API
- ✅ 数据库支持（MySQL, PostgreSQL, Oracle 等）
- ✅ 异步执行器
- ✅ 定时器支持

## 工作流类型支持

### 1. 顺序流程 (Sequential Flow)

简单的线性流程，按顺序执行。

### 2. 分支流程 (Branching)

使用网关实现条件分支：
- 排他网关：只执行一个分支
- 并行网关：同时执行多个分支
- 包容网关：执行满足条件的所有分支

### 3. 循环流程 (Loop)

支持循环执行：
- 标准循环
- 多实例循环（会签、或签）

### 4. 子流程 (Subprocess)

- 嵌入子流程
- 调用子流程
- 事件子流程

### 5. 事件驱动流程 (Event-Driven)

- 定时器事件
- 消息事件
- 信号事件
- 错误事件

## 与 CRM 系统集成

### 适用场景

1. **订单审批流程**
   - 订单提交 → 审核 → 分配 → 处理 → 完成

2. **客户跟进流程**
   - 客户创建 → 分配销售 → 跟进 → 成交

3. **交付物审核流程**
   - 交付物上传 → 审核 → 通过/退回

4. **付款审批流程**
   - 付款申请 → 财务审核 → 批准 → 支付

5. **供应商任务分配流程**
   - 任务创建 → 分配给供应商 → 执行 → 验收

### 集成方式

1. **通过 API 调用**
   ```java
   @Autowired
   private RuntimeService runtimeService;
   
   @Autowired
   private TaskService taskService;
   
   // 启动流程
   ProcessInstance processInstance = runtimeService
       .startProcessInstanceByKey("orderApproval", variables);
   
   // 查询任务
   List<Task> tasks = taskService.createTaskQuery()
       .taskAssignee(userId)
       .list();
   ```

2. **通过 REST API**
   - `/activiti/runtime/process-instances`: 流程实例管理
   - `/activiti/task/tasks`: 任务管理
   - `/activiti/repository/deployments`: 部署管理

## 当前部署状态

### 服务状态

- **Activiti 服务**: 需要构建自定义镜像
- **数据库**: MySQL (bantu_crm) 已配置
- **配置**: ConfigMap 已创建

### 下一步

1. 构建 Activiti Spring Boot 应用镜像
2. 部署到 Kubernetes
3. 验证 Activiti 表自动创建
4. 部署示例工作流定义

## 查询命令

### 检查 Activiti 表

```bash
kubectl exec mysql-<pod> -- mysql -u bantu_user -p bantu_crm \
  -e "SHOW TABLES LIKE 'ACT_%';"
```

### 查询流程定义

```bash
kubectl exec mysql-<pod> -- mysql -u bantu_user -p bantu_crm \
  -e "SELECT * FROM ACT_RE_PROCDEF;"
```

### 查询运行中的流程实例

```bash
kubectl exec mysql-<pod> -- mysql -u bantu_user -p bantu_crm \
  -e "SELECT * FROM ACT_RU_EXECUTION;"
```

### 查询任务

```bash
kubectl exec mysql-<pod> -- mysql -u bantu_user -p bantu_crm \
  -e "SELECT * FROM ACT_RU_TASK;"
```

## 参考资料

- [Activiti 官方文档](https://www.activiti.org/)
- [Activiti 7 用户指南](https://www.activiti.org/userguide/)
- [BPMN 2.0 规范](https://www.omg.org/spec/BPMN/2.0/)

