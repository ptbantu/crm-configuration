# MongoDB 部署配置

本目录包含 MongoDB 数据库在 Kubernetes 集群中的部署配置文件。

## 📁 文件说明

- `mongodb-secret.yaml` - MongoDB 密码 Secret
- `mongodb-configmap.yaml` - MongoDB 配置文件
- `mongodb-pv.yaml` - 持久化存储卷
- `mongodb-pvc.yaml` - 持久化存储声明
- `mongodb-deployment.yaml` - MongoDB 部署配置
- `mongodb-service.yaml` - MongoDB 服务配置
- `mongodb-init-script.js` - 初始化脚本（创建应用用户）
- `deploy-mongodb.sh` - 一键部署脚本

## 🚀 快速部署

### 方法一：使用部署脚本（推荐）

```bash
cd /home/bantu/crm-configuration/k8s/mongodb
./deploy-mongodb.sh
```

### 方法二：手动部署

```bash
cd /home/bantu/crm-configuration/k8s/mongodb

# 按顺序部署
kubectl apply -f mongodb-secret.yaml
kubectl apply -f mongodb-configmap.yaml
kubectl apply -f mongodb-pv.yaml
kubectl apply -f mongodb-pvc.yaml
kubectl apply -f mongodb-deployment.yaml
kubectl apply -f mongodb-service.yaml
```

## 📋 配置信息

### 连接信息

- **服务地址**: `mongodb.default.svc.cluster.local:27017`
- **集群内短地址**: `mongodb:27017`
- **数据库**: `bantu_crm`
- **Root 用户**: `bantu_mongo_admin` / `bantu_mongo_password_2024`
- **应用用户**: `bantu_mongo_user` / `bantu_mongo_user_password_2024`
- **认证数据库**: `admin`

### 持久化

- **存储路径**: `/data/db` (容器内)
- **存储大小**: `30Gi`
- **存储类**: `local-storage`
- **本地路径**: `/home/bantu/bantu-data/mongodb`

### 资源配置

- **内存限制**: 2Gi
- **CPU 限制**: 1000m
- **内存请求**: 512Mi
- **CPU 请求**: 250m

## 🔍 常用命令

### 查看状态

```bash
# 查看 Pod 状态
kubectl get pods -l app=mongodb

# 查看 Service
kubectl get svc mongodb

# 查看 PVC
kubectl get pvc mongodb-pvc

# 查看所有 MongoDB 资源
kubectl get all -l app=mongodb
```

### 查看日志

```bash
# 查看 MongoDB 日志
kubectl logs -l app=mongodb

# 实时查看日志
kubectl logs -f -l app=mongodb
```

### 测试连接

```bash
# 使用临时 Pod 测试连接（Root 用户）
kubectl run -it --rm mongodb-client \
  --image=mongo:7.0 \
  --restart=Never \
  -- mongosh -h mongodb -u bantu_mongo_admin -p bantu_mongo_password_2024 --authenticationDatabase admin

# 使用应用用户连接
kubectl run -it --rm mongodb-client \
  --image=mongo:7.0 \
  --restart=Never \
  -- mongosh -h mongodb -u bantu_mongo_user -p bantu_mongo_user_password_2024 --authenticationDatabase admin bantu_crm
```

### 创建应用用户

部署后需要手动创建应用用户：

```bash
# 连接到 MongoDB
kubectl run -it --rm mongodb-init \
  --image=mongo:7.0 \
  --restart=Never \
  -- mongosh -h mongodb -u bantu_mongo_admin -p bantu_mongo_password_2024 --authenticationDatabase admin

# 在 mongosh 中执行：
use bantu_crm
db.createUser({
  user: 'bantu_mongo_user',
  pwd: 'bantu_mongo_user_password_2024',
  roles: [{ role: 'readWrite', db: 'bantu_crm' }]
})
```

或者使用初始化脚本：

```bash
# 复制初始化脚本到 Pod
kubectl cp mongodb-init-script.js $(kubectl get pod -l app=mongodb -o jsonpath='{.items[0].metadata.name}'):/tmp/init.js

# 执行初始化脚本
kubectl exec -it $(kubectl get pod -l app=mongodb -o jsonpath='{.items[0].metadata.name}') -- \
  mongosh -u bantu_mongo_admin -p bantu_mongo_password_2024 --authenticationDatabase admin /tmp/init.js
```

### 端口转发（本地访问）

```bash
# 转发到本地 27017 端口
kubectl port-forward svc/mongodb 27017:27017

# 然后可以使用本地 MongoDB 客户端连接
mongosh mongodb://bantu_mongo_admin:bantu_mongo_password_2024@localhost:27017/admin
```

## 🔧 配置说明

### MongoDB 配置特性

- ✅ 认证启用（--auth）
- ✅ 绑定所有 IP（--bind_ip_all）
- ✅ WiredTiger 存储引擎
- ✅ 数据持久化到 PVC
- ✅ 健康检查（liveness 和 readiness）

### 修改配置

1. 修改 `mongodb-configmap.yaml` 中的配置
2. 应用更改：`kubectl apply -f mongodb-configmap.yaml`
3. 重启 Pod：`kubectl rollout restart deployment/mongodb`

### 修改密码

1. 修改 `mongodb-secret.yaml` 中的密码
2. 应用更改：`kubectl apply -f mongodb-secret.yaml`
3. 重启 Pod：`kubectl rollout restart deployment/mongodb`
4. 更新应用配置中的密码

## 🗑️ 删除部署

```bash
# 删除所有资源（⚠️ 注意：会删除数据）
kubectl delete -f .

# 或者使用脚本删除
kubectl delete secret mongodb-secret
kubectl delete configmap mongodb-config
kubectl delete deployment mongodb
kubectl delete service mongodb
kubectl delete pvc mongodb-pvc
kubectl delete pv mongodb-pv
```

## ⚠️ 注意事项

1. **数据持久化**: MongoDB 数据存储在 PVC 中，删除 PVC 会丢失数据
2. **密码安全**: 生产环境请使用更安全的 Secret 管理方式（如 Sealed Secrets、Vault）
3. **资源限制**: 根据实际使用情况调整内存和 CPU 限制
4. **存储大小**: 根据需求调整 PVC 大小（当前为 30Gi）
5. **备份**: 定期备份 PVC 数据或使用 MongoDB 的备份工具
6. **应用用户**: 部署后需要手动创建应用用户（bantu_mongo_user）
7. **副本集**: 生产环境建议配置副本集以提高可用性

## 📚 相关文档

- [MongoDB 官方文档](https://docs.mongodb.com/)
- [MongoDB Kubernetes 部署](https://www.mongodb.com/docs/manual/administration/kubernetes/)
- [MongoDB 连接字符串格式](https://www.mongodb.com/docs/manual/reference/connection-string/)

## 🐛 故障排查

### Pod 无法启动

```bash
# 查看 Pod 状态
kubectl describe pod -l app=mongodb

# 查看日志
kubectl logs -l app=mongodb
```

### 无法连接 MongoDB

```bash
# 检查 Service
kubectl get svc mongodb

# 检查 Pod 是否运行
kubectl get pods -l app=mongodb

# 测试连接
kubectl run -it --rm test --image=mongo:7.0 --restart=Never -- \
  mongosh -h mongodb -u bantu_mongo_admin -p bantu_mongo_password_2024 --authenticationDatabase admin
```

### PVC 无法挂载

```bash
# 检查 PVC 状态
kubectl get pvc mongodb-pvc

# 检查 PV
kubectl get pv mongodb-pv

# 查看 PVC 详情
kubectl describe pvc mongodb-pvc
```

