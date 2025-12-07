# Redis 部署配置

本目录包含 Redis 在 Kubernetes 集群中的部署配置文件。

## 📁 文件说明

- `redis-secret.yaml` - Redis 密码 Secret
- `redis-configmap.yaml` - Redis 配置文件
- `redis-pvc.yaml` - 持久化存储声明
- `redis-deployment.yaml` - Redis 部署配置
- `redis-service.yaml` - Redis 服务配置
- `deploy-redis.sh` - 一键部署脚本

## 🚀 快速部署

### 方法一：使用部署脚本（推荐）

```bash
cd /home/bantu/crm-configuration/k8s/redis
chmod +x deploy-redis.sh
./deploy-redis.sh
```

### 方法二：手动部署

```bash
cd /home/bantu/crm-configuration/k8s/redis

# 按顺序部署
kubectl apply -f redis-secret.yaml
kubectl apply -f redis-configmap.yaml
kubectl apply -f redis-pvc.yaml
kubectl apply -f redis-deployment.yaml
kubectl apply -f redis-service.yaml
```

## 📋 配置信息

### 连接信息

- **服务地址**: `redis.default.svc.cluster.local:6379`
- **集群内短地址**: `redis:6379`
- **密码**: `bantu_redis_password_2024`
- **数据库**: `0` (默认)

### 持久化

- **存储路径**: `/data` (容器内)
- **存储大小**: `10Gi`
- **存储类**: `local-storage`
- **持久化方式**: RDB + AOF

### 资源配置

- **内存限制**: 2Gi
- **CPU 限制**: 1000m
- **内存请求**: 256Mi
- **CPU 请求**: 100m

## 🔍 常用命令

### 查看状态

```bash
# 查看 Pod 状态
kubectl get pods -l app=redis

# 查看 Service
kubectl get svc redis

# 查看 PVC
kubectl get pvc redis-pvc

# 查看所有 Redis 资源
kubectl get all -l app=redis
```

### 查看日志

```bash
# 查看 Redis 日志
kubectl logs -l app=redis

# 实时查看日志
kubectl logs -f -l app=redis
```

### 测试连接

```bash
# 使用临时 Pod 测试连接
kubectl run -it --rm redis-client \
  --image=redis:7.2-alpine \
  --restart=Never \
  -- redis-cli -h redis -a bantu_redis_password_2024 ping

# 进入 Redis CLI
kubectl run -it --rm redis-client \
  --image=redis:7.2-alpine \
  --restart=Never \
  -- redis-cli -h redis -a bantu_redis_password_2024
```

### 端口转发（本地访问）

```bash
# 转发到本地 6379 端口
kubectl port-forward svc/redis 6379:6379

# 然后可以使用本地 Redis 客户端连接
redis-cli -h localhost -p 6379 -a bantu_redis_password_2024
```

## 🔧 配置说明

### Redis 配置特性

- ✅ 密码认证（requirepass）
- ✅ RDB 持久化（快照）
- ✅ AOF 持久化（追加式）
- ✅ 内存限制和淘汰策略（LRU）
- ✅ 慢查询日志
- ✅ 数据持久化到 PVC

### 修改配置

1. 修改 `redis-configmap.yaml` 中的 `redis.conf`
2. 应用更改：`kubectl apply -f redis-configmap.yaml`
3. 重启 Pod：`kubectl rollout restart deployment/redis`

### 修改密码

1. 修改 `redis-secret.yaml` 中的密码
2. 应用更改：`kubectl apply -f redis-secret.yaml`
3. 重启 Pod：`kubectl rollout restart deployment/redis`
4. 更新应用配置中的密码

## 🗑️ 删除部署

```bash
# 删除所有资源（⚠️ 注意：会删除数据）
kubectl delete -f .

# 或者使用脚本删除
kubectl delete secret redis-secret
kubectl delete configmap redis-config
kubectl delete deployment redis
kubectl delete service redis
kubectl delete pvc redis-pvc
```

## ⚠️ 注意事项

1. **数据持久化**: Redis 数据存储在 PVC 中，删除 PVC 会丢失数据
2. **密码安全**: 生产环境请使用更安全的 Secret 管理方式（如 Sealed Secrets、Vault）
3. **资源限制**: 根据实际使用情况调整内存和 CPU 限制
4. **高可用**: 当前为单节点部署，如需高可用请考虑 Redis Sentinel 或 Redis Cluster
5. **备份**: 定期备份 PVC 数据或使用 Redis 的持久化文件

## 📚 相关文档

- [Redis 官方文档](https://redis.io/documentation)
- [Redis 配置参考](https://redis.io/docs/management/config/)
- [Kubernetes Redis 部署最佳实践](https://kubernetes.io/docs/tutorials/stateful-application/run-replicated-stateful-application/)

## 🐛 故障排查

### Pod 无法启动

```bash
# 查看 Pod 状态
kubectl describe pod -l app=redis

# 查看日志
kubectl logs -l app=redis
```

### 无法连接 Redis

```bash
# 检查 Service
kubectl get svc redis

# 检查 Pod 是否运行
kubectl get pods -l app=redis

# 测试连接
kubectl run -it --rm redis-client --image=redis:7.2-alpine --restart=Never -- redis-cli -h redis -a bantu_redis_password_2024 ping
```

### PVC 无法挂载

```bash
# 检查 PVC 状态
kubectl get pvc redis-pvc

# 检查 PV
kubectl get pv

# 查看 PVC 详情
kubectl describe pvc redis-pvc
```

