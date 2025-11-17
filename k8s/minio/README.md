# MinIO 对象存储部署配置

本目录包含 MinIO 对象存储服务在 Kubernetes 集群中的部署配置文件。

## 📁 文件说明

- `minio-secret.yaml` - MinIO 访问密钥 Secret
- `minio-configmap.yaml` - MinIO 配置文件
- `minio-pv.yaml` - 持久化存储卷
- `minio-pvc.yaml` - 持久化存储声明
- `minio-deployment.yaml` - MinIO 部署配置
- `minio-service.yaml` - MinIO API 服务配置
- `minio-console-service.yaml` - MinIO Console 服务配置
- `deploy-minio.sh` - 一键部署脚本

## 🚀 快速部署

### 方法一：使用部署脚本（推荐）

```bash
cd /home/bantu/crm-configuration/k8s/minio
./deploy-minio.sh
```

### 方法二：手动部署

```bash
cd /home/bantu/crm-configuration/k8s/minio

# 按顺序部署
kubectl apply -f minio-secret.yaml
kubectl apply -f minio-configmap.yaml
kubectl apply -f minio-pv.yaml
kubectl apply -f minio-pvc.yaml
kubectl apply -f minio-deployment.yaml
kubectl apply -f minio-service.yaml
kubectl apply -f minio-console-service.yaml
```

## 📋 配置信息

### 连接信息

- **API 地址**: `minio.default.svc.cluster.local:9000`
- **Console 地址**: `minio-console.default.svc.cluster.local:9001`
- **访问密钥 (Access Key)**: `bantu_minio_admin`
- **秘密密钥 (Secret Key)**: `bantu_minio_password_2024`
- **区域**: `us-east-1`

### 持久化

- **存储路径**: `/data` (容器内)
- **存储大小**: `50Gi`
- **存储类**: `local-storage`
- **本地路径**: `/home/bantu/bantu-data/minio`

### 资源配置

- **内存限制**: 2Gi
- **CPU 限制**: 1000m
- **内存请求**: 512Mi
- **CPU 请求**: 250m

## 🔍 常用命令

### 查看状态

```bash
# 查看 Pod 状态
kubectl get pods -l app=minio

# 查看 Service
kubectl get svc minio minio-console

# 查看 PVC
kubectl get pvc minio-pvc

# 查看所有 MinIO 资源
kubectl get all -l app=minio
```

### 查看日志

```bash
# 查看 MinIO 日志
kubectl logs -l app=minio

# 实时查看日志
kubectl logs -f -l app=minio
```

### 访问 Web Console

```bash
# 端口转发到本地
kubectl port-forward svc/minio-console 9001:9001

# 然后访问 http://localhost:9001
# 使用访问密钥和秘密密钥登录
```

### 使用 MinIO Client (mc)

```bash
# 使用临时 Pod 连接 MinIO
kubectl run -it --rm minio-client \
  --image=minio/mc:latest \
  --restart=Never \
  -- sh

# 在容器内配置 MinIO
mc alias set myminio http://minio:9000 bantu_minio_admin bantu_minio_password_2024

# 列出存储桶
mc ls myminio

# 创建存储桶
mc mb myminio/bantu-crm

# 上传文件
mc cp /path/to/file myminio/bantu-crm/
```

## 🔧 配置说明

### MinIO 配置特性

- ✅ 对象存储 API（S3 兼容）
- ✅ Web Console 管理界面
- ✅ 数据持久化到 PVC
- ✅ 健康检查（liveness 和 readiness）
- ✅ 资源限制和请求

### 修改配置

1. 修改 `minio-configmap.yaml` 中的配置
2. 应用更改：`kubectl apply -f minio-configmap.yaml`
3. 重启 Pod：`kubectl rollout restart deployment/minio`

### 修改访问密钥

1. 修改 `minio-secret.yaml` 中的密钥
2. 应用更改：`kubectl apply -f minio-secret.yaml`
3. 重启 Pod：`kubectl rollout restart deployment/minio`
4. 更新应用配置中的密钥

## 🗑️ 删除部署

```bash
# 删除所有资源（⚠️ 注意：会删除数据）
kubectl delete -f .

# 或者使用脚本删除
kubectl delete secret minio-secret
kubectl delete configmap minio-config
kubectl delete deployment minio
kubectl delete service minio minio-console
kubectl delete pvc minio-pvc
kubectl delete pv minio-pv
```

## ⚠️ 注意事项

1. **数据持久化**: MinIO 数据存储在 PVC 中，删除 PVC 会丢失数据
2. **密钥安全**: 生产环境请使用更安全的 Secret 管理方式（如 Sealed Secrets、Vault）
3. **资源限制**: 根据实际使用情况调整内存和 CPU 限制
4. **存储大小**: 根据需求调整 PVC 大小（当前为 50Gi）
5. **备份**: 定期备份 PVC 数据
6. **HTTPS**: 生产环境建议配置 HTTPS 和 TLS 证书

## 📚 相关文档

- [MinIO 官方文档](https://min.io/docs/)
- [MinIO Kubernetes 部署](https://min.io/docs/minio/kubernetes/kubernetes-deployment-quickstart-guide.html)
- [MinIO Client (mc) 使用指南](https://min.io/docs/minio/linux/reference/minio-mc.html)

## 🐛 故障排查

### Pod 无法启动

```bash
# 查看 Pod 状态
kubectl describe pod -l app=minio

# 查看日志
kubectl logs -l app=minio
```

### 无法访问 MinIO

```bash
# 检查 Service
kubectl get svc minio minio-console

# 检查 Pod 是否运行
kubectl get pods -l app=minio

# 测试连接
kubectl run -it --rm test --image=curlimages/curl --restart=Never -- curl http://minio:9000/minio/health/live
```

### PVC 无法挂载

```bash
# 检查 PVC 状态
kubectl get pvc minio-pvc

# 检查 PV
kubectl get pv minio-pv

# 查看 PVC 详情
kubectl describe pvc minio-pvc
```

