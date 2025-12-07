# Activiti Spring Boot 部署说明

## 概述

本目录包含 Activiti Spring Boot 工作流引擎的 Kubernetes 部署配置，复用现有的 MySQL 数据库。

## 文件说明

- `activiti-deployment.yaml`: Activiti Deployment 配置
- `activiti-service.yaml`: Activiti Service 配置
- `activiti-configmap.yaml`: Activiti 应用配置（数据库连接等）
- `activiti-ingress.yaml`: Ingress 配置（可选）
- `deploy-activiti.sh`: 一键部署脚本

## 数据库配置

Activiti 使用现有的 MySQL 数据库 `bantu_crm`：

- **数据库**: bantu_crm
- **连接**: 通过 Service `mysql:3306`
- **认证**: 使用 `mysql-secret` 中的用户名和密码
- **Schema 更新**: 自动创建 Activiti 表（`ACT_*` 前缀）

## 部署步骤

### 1. 快速部署

```bash
cd k8s
./deploy-activiti.sh
```

### 2. 手动部署

```bash
# 1. 创建 ConfigMap
kubectl apply -f activiti-configmap.yaml

# 2. 创建 Deployment
kubectl apply -f activiti-deployment.yaml

# 3. 创建 Service
kubectl apply -f activiti-service.yaml

# 4. 可选：创建 Ingress
kubectl apply -f activiti-ingress.yaml
```

## 验证部署

### 检查 Pod 状态

```bash
kubectl get pods -l app=activiti
kubectl logs -f -l app=activiti
```

### 检查 Service

```bash
kubectl get svc activiti
```

### 检查数据库表

Activiti 会自动创建以下表（前缀 `ACT_`）：

```bash
kubectl exec -it mysql-<pod-name> -- mysql -u bantu_user -p bantu_crm -e "SHOW TABLES LIKE 'ACT_%';"
```

## 访问方式

### 1. 集群内访问

```bash
# 端口转发
kubectl port-forward svc/activiti 8080:8080

# 访问
curl http://localhost:8080/activiti/actuator/health
```

### 2. Ingress 访问（如果配置了）

```bash
# 添加到 /etc/hosts
echo "127.0.0.1 activiti.local" >> /etc/hosts

# 访问
curl http://activiti.local/activiti/actuator/health
```

## 配置说明

### 数据库连接

配置在 `activiti-configmap.yaml` 中：

- **URL**: `jdbc:mysql://mysql:3306/bantu_crm`
- **驱动**: `com.mysql.cj.jdbc.Driver`
- **Schema 更新**: `update`（自动创建/更新表）

### Activiti 配置

- **数据库 Schema 更新**: `true`（自动创建表）
- **历史级别**: `full`（完整历史记录）
- **异步执行器**: 启用
- **Context Path**: `/activiti`

## 自定义镜像

如果需要使用自定义的 Activiti Spring Boot 镜像：

1. 修改 `activiti-deployment.yaml` 中的 `image` 字段
2. 确保镜像包含 MySQL JDBC 驱动

### 构建自定义镜像示例

```dockerfile
FROM openjdk:11-jre-slim

# 安装 MySQL JDBC 驱动
RUN apt-get update && apt-get install -y \
    wget && \
    wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.33/mysql-connector-java-8.0.33.jar \
    -O /app/mysql-connector.jar && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 复制应用
COPY activiti-app.jar /app/app.jar

WORKDIR /app
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
```

## 资源限制

默认资源配置：

- **请求**: 512Mi 内存, 250m CPU
- **限制**: 1Gi 内存, 500m CPU

可根据实际需求调整 `activiti-deployment.yaml` 中的 `resources` 部分。

## 健康检查

- **Liveness Probe**: `/actuator/health`（90秒后开始，每10秒检查）
- **Readiness Probe**: `/actuator/health`（60秒后开始，每5秒检查）

## 故障排查

### Pod 无法启动

```bash
# 查看 Pod 状态
kubectl describe pod -l app=activiti

# 查看日志
kubectl logs -l app=activiti --tail=100
```

### 数据库连接失败

1. 检查 MySQL Service 是否正常：
   ```bash
   kubectl get svc mysql
   ```

2. 检查 Secret 是否存在：
   ```bash
   kubectl get secret mysql-secret
   ```

3. 测试数据库连接：
   ```bash
   kubectl exec -it activiti-<pod-name> -- \
     mysql -h mysql -u bantu_user -p bantu_crm
   ```

### 表未创建

检查日志中的数据库初始化信息：

```bash
kubectl logs -l app=activiti | grep -i "schema\|table\|activiti"
```

## 升级和回滚

### 升级

```bash
# 更新镜像版本
kubectl set image deployment/activiti activiti=activiti/activiti-cloud-full-example:v7.0.0

# 或重新应用配置
kubectl apply -f activiti-deployment.yaml
```

### 回滚

```bash
kubectl rollout undo deployment/activiti
```

## 注意事项

1. **数据库 Schema**: Activiti 会在 `bantu_crm` 数据库中创建 `ACT_*` 前缀的表
2. **数据隔离**: 如果需要多租户，考虑使用不同的数据库或 Schema
3. **备份**: 定期备份数据库，包括 Activiti 表
4. **性能**: 根据工作流负载调整资源限制和数据库连接池大小

## 相关文档

- [Activiti 官方文档](https://www.activiti.org/)
- [Spring Boot 文档](https://spring.io/projects/spring-boot)
- [Kubernetes 文档](https://kubernetes.io/docs/)

