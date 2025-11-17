# Kubernetes 部署配置

本目录包含 BANTU CRM 系统在 Kubernetes 集群中的部署配置文件。

## 📁 目录结构

```
k8s/
├── mysql/              # MySQL 数据库服务
│   ├── mysql-secret.yaml
│   ├── mysql-pv.yaml
│   ├── mysql-pvc.yaml
│   ├── mysql-deployment.yaml
│   ├── mysql-service.yaml
│   └── deploy-mysql.sh
│
├── redis/              # Redis 缓存服务
│   ├── redis-secret.yaml
│   ├── redis-configmap.yaml
│   ├── redis-pvc.yaml
│   ├── redis-deployment.yaml
│   ├── redis-service.yaml
│   ├── deploy-redis.sh
│   └── README.md
│
├── activiti/           # Activiti 工作流引擎
│   ├── activiti-configmap.yaml
│   ├── activiti-deployment.yaml
│   ├── activiti-deployment-simple.yaml
│   ├── activiti-service.yaml
│   ├── activiti-ingress.yaml
│   ├── activiti-dockerfile
│   ├── deploy-activiti.sh
│   ├── README-activiti.md
│   └── BUILD-ACTIVITI.md
│
├── crm-services/       # CRM 微服务（Gateway, Foundation, Business, Workflow, Finance）
│   ├── crm-deployments.yaml
│   ├── crm-services.yaml
│   ├── deploy-all-services.sh
│   └── README-microservices.md
│
├── scripts/            # 数据库初始化脚本
│   ├── import-schema-mysql.sh
│   └── import-seed-data.sh
│
└── docs/               # 文档
    └── README-k8s.md   # 原始 K8s 部署说明
```

## 🚀 快速开始

### 1. 部署 MySQL 数据库

```bash
cd mysql
./deploy-mysql.sh
```

### 2. 部署 Redis 缓存（可选）

```bash
cd redis
./deploy-redis.sh
```

### 3. 初始化数据库 Schema

```bash
cd ../scripts
./import-schema-mysql.sh
```

### 4. 导入种子数据

```bash
./import-seed-data.sh
```

### 5. 部署 Activiti 工作流引擎（可选）

```bash
cd ../activiti
./deploy-activiti.sh
```

### 6. 部署 CRM 微服务

```bash
cd ../crm-services
./deploy-all-services.sh
```

## 📋 部署顺序

1. **MySQL** - 数据库服务（必须先部署）
2. **Redis** - 缓存服务（可选，建议部署）
3. **数据库初始化** - 导入 Schema 和种子数据
4. **Activiti** - 工作流引擎（可选）
5. **CRM 微服务** - Gateway、Foundation、Business、Workflow、Finance

## 🔍 服务访问

### 集群内访问

- **MySQL**: `mysql.default.svc.cluster.local:3306`
- **Redis**: `redis.default.svc.cluster.local:6379`
- **Gateway**: `crm-gateway:8080`
- **Foundation Service**: `crm-foundation-service:8081`
- **Business Service**: `crm-business-service:8082`
- **Workflow Service**: `crm-workflow-service:8083`
- **Finance Service**: `crm-finance-service:8084`
- **Activiti**: `activiti:8080`

### 本地访问（端口转发）

```bash
# Gateway
kubectl port-forward svc/crm-gateway 8080:8080

# MySQL
kubectl port-forward svc/mysql 3306:3306

# Redis
kubectl port-forward svc/redis 6379:6379

# Activiti
kubectl port-forward svc/activiti 8080:8080
```

## 📚 详细文档

- **MySQL 部署**: 查看 `mysql/` 目录中的文件或运行 `./deploy-mysql.sh` 查看帮助
- **Redis 部署**: 查看 `redis/README.md` 或运行 `./deploy-redis.sh` 查看帮助
- **Activiti 部署**: 查看 `activiti/README-activiti.md`
- **CRM 微服务**: 查看 `crm-services/README-microservices.md`
- **数据库脚本**: 查看 `scripts/` 目录中的脚本注释

## 🔧 常用命令

### 查看服务状态

```bash
# 查看所有 Pod
kubectl get pods

# 查看所有 Service
kubectl get svc

# 查看 MySQL 相关资源
kubectl get pv,pvc,pods,svc -l app=mysql

# 查看 Redis 相关资源
kubectl get pv,pvc,pods,svc -l app=redis

# 查看 CRM 服务
kubectl get deployments,svc -l 'service in (gateway,foundation,business,workflow,finance)'
```

### 查看日志

```bash
# MySQL 日志
kubectl logs -l app=mysql

# Redis 日志
kubectl logs -l app=redis

# Gateway 日志
kubectl logs -l service=gateway

# Activiti 日志
kubectl logs -l app=activiti
```

### 删除服务

```bash
# 删除 CRM 服务
kubectl delete -f crm-services/

# 删除 Activiti
kubectl delete -f activiti/

# 删除 Redis（⚠️ 注意：会删除数据）
kubectl delete -f redis/

# 删除 MySQL（⚠️ 注意：会删除数据）
kubectl delete -f mysql/
```

## ⚠️ 注意事项

1. **部署顺序**: MySQL 必须先部署，其他服务依赖它；Redis 建议在应用服务之前部署
2. **数据持久化**: 
   - MySQL 数据存储在 PVC 中，请定期备份
   - Redis 数据存储在 PVC 中，请定期备份
3. **资源限制**: 根据集群资源调整各服务的 CPU/内存限制
4. **网络策略**: 确保集群内服务可以互相访问
5. **Secret 管理**: 生产环境请使用更安全的 Secret 管理方式
6. **Redis 密码**: 默认密码为 `bantu_redis_password_2024`，生产环境请修改

## 🐛 故障排查

### MySQL 无法启动

```bash
# 检查 Pod 状态
kubectl describe pod -l app=mysql

# 查看日志
kubectl logs -l app=mysql

# 检查 PV/PVC
kubectl get pv,pvc
```

### 服务无法连接 MySQL

```bash
# 检查 MySQL Service
kubectl get svc mysql

# 测试连接
kubectl run -it --rm mysql-client --image=mysql:8.0 --restart=Never -- mysql -h mysql -u root -p
```

### 服务启动失败

```bash
# 查看 Pod 事件
kubectl describe pod <pod-name>

# 查看日志
kubectl logs <pod-name>

# 检查 ConfigMap 和 Secret
kubectl get configmap,secret
```

## 📝 更新日志

- **2024-11-15**: 添加 Redis 缓存服务部署配置
- **2024-11-15**: 重构目录结构，按服务分类组织文件
- **2024-11-06**: 添加 CRM 微服务部署配置
- **2024-11-05**: 添加 Activiti 工作流引擎部署
- **2024-11-04**: 初始 MySQL 部署配置

