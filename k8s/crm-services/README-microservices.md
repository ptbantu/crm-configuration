# CRM 微服务 Kubernetes 部署说明

## 服务列表

| 服务 | 端口 | 说明 | 副本数 |
|------|------|------|--------|
| crm-gateway | 8080 | API 网关 | 2 |
| crm-foundation-service | 8081 | 基础服务 | 2 |
| crm-business-service | 8082 | 业务服务 | 2 |
| crm-workflow-service | 8083 | 工作流服务 | 1 |
| crm-finance-service | 8084 | 财务服务 | 1 |

## 部署文件

### Gateway
- `crm-gateway-deployment.yaml` - Gateway Deployment
- `crm-gateway-service.yaml` - Gateway Service

### Foundation Service
- `crm-foundation-service-deployment.yaml` - Foundation Deployment
- `crm-foundation-service-service.yaml` - Foundation Service

### Business Service
- `crm-business-service-deployment.yaml` - Business Deployment
- `crm-business-service-service.yaml` - Business Service

### Workflow Service
- `crm-workflow-service-deployment.yaml` - Workflow Deployment
- `crm-workflow-service-service.yaml` - Workflow Service

### Finance Service
- `crm-finance-service-deployment.yaml` - Finance Deployment
- `crm-finance-service-service.yaml` - Finance Service

## 部署步骤

### 1. 构建 Docker 镜像

在 `crm-backend` 目录下：

```bash
# 构建所有服务镜像
./build-docker.sh

# 或指定版本
export VERSION=v1.0.0
export DOCKER_REGISTRY=your-registry.com
./build-docker.sh
```

### 2. 推送镜像到仓库（如果需要）

```bash
# 推送所有镜像
docker push your-registry/bantu-crm-crm-gateway:latest
docker push your-registry/bantu-crm-crm-foundation-service:latest
docker push your-registry/bantu-crm-crm-business-service:latest
docker push your-registry/bantu-crm-crm-workflow-service:latest
docker push your-registry/bantu-crm-crm-finance-service:latest
```

### 3. 部署到 Kubernetes

```bash
# 一键部署所有服务
cd k8s
./deploy-all-services.sh
```

### 4. 手动部署（可选）

```bash
# 按顺序部署
kubectl apply -f crm-foundation-service-deployment.yaml
kubectl apply -f crm-foundation-service-service.yaml

kubectl apply -f crm-workflow-service-deployment.yaml
kubectl apply -f crm-workflow-service-service.yaml

kubectl apply -f crm-business-service-deployment.yaml
kubectl apply -f crm-business-service-service.yaml

kubectl apply -f crm-finance-service-deployment.yaml
kubectl apply -f crm-finance-service-service.yaml

kubectl apply -f crm-gateway-deployment.yaml
kubectl apply -f crm-gateway-service.yaml
```

## 验证部署

### 检查 Pod 状态

```bash
kubectl get pods -l 'app in (crm-gateway,crm-foundation-service,crm-business-service,crm-workflow-service,crm-finance-service)'
```

### 检查 Service

```bash
kubectl get svc -l 'app in (crm-gateway,crm-foundation-service,crm-business-service,crm-workflow-service,crm-finance-service)'
```

### 查看日志

```bash
# Gateway
kubectl logs -f -l app=crm-gateway

# Foundation Service
kubectl logs -f -l app=crm-foundation-service

# Business Service
kubectl logs -f -l app=crm-business-service

# Workflow Service
kubectl logs -f -l app=crm-workflow-service

# Finance Service
kubectl logs -f -l app=crm-finance-service
```

### 健康检查

```bash
# Gateway
kubectl exec -it <gateway-pod> -- curl http://localhost:8080/actuator/health

# Foundation Service
kubectl exec -it <foundation-pod> -- curl http://localhost:8081/actuator/health

# Business Service
kubectl exec -it <business-pod> -- curl http://localhost:8082/actuator/health

# Workflow Service
kubectl exec -it <workflow-pod> -- curl http://localhost:8083/actuator/health

# Finance Service
kubectl exec -it <finance-pod> -- curl http://localhost:8084/actuator/health
```

## 访问服务

### 集群内访问

- Gateway: `http://crm-gateway:8080`
- Foundation: `http://crm-foundation-service:8081`
- Business: `http://crm-business-service:8082`
- Workflow: `http://crm-workflow-service:8083`
- Finance: `http://crm-finance-service:8084`

### 本地访问（端口转发）

```bash
# Gateway
kubectl port-forward svc/crm-gateway 8080:8080

# 然后访问
curl http://localhost:8080/api/foundation/users
```

## 更新部署

### 更新镜像版本

```bash
# 方式 1: 更新 Deployment 中的镜像
kubectl set image deployment/crm-foundation-service \
  foundation=your-registry/bantu-crm-crm-foundation-service:v1.0.1

# 方式 2: 重新应用配置文件
kubectl apply -f crm-foundation-service-deployment.yaml
```

### 滚动更新

Kubernetes 会自动进行滚动更新，无需手动操作。

## 扩缩容

```bash
# 扩容
kubectl scale deployment/crm-foundation-service --replicas=3

# 缩容
kubectl scale deployment/crm-foundation-service --replicas=1
```

## 故障排查

### Pod 无法启动

```bash
# 查看 Pod 详情
kubectl describe pod <pod-name>

# 查看日志
kubectl logs <pod-name>
```

### 服务无法访问

```bash
# 检查 Service
kubectl get svc crm-foundation-service

# 检查 Endpoints
kubectl get endpoints crm-foundation-service

# 测试服务连接
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl http://crm-foundation-service:8081/actuator/health
```

### 数据库连接失败

1. 检查 MySQL Service 是否正常
2. 检查 Secret 是否存在
3. 检查数据库连接配置

## 注意事项

1. **镜像构建**: 确保所有服务的 JAR 文件都已构建成功
2. **数据库**: 确保 MySQL 已部署并运行
3. **服务依赖**: 注意服务启动顺序（foundation -> workflow -> business -> finance -> gateway）
4. **资源限制**: 根据实际负载调整资源限制
5. **健康检查**: 确保健康检查路径正确

