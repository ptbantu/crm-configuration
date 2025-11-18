# BANTU CRM Helm Chart

BANTU CRM 系统的一体化 Helm Chart，支持一键部署所有服务。

## 📦 包含的服务

- **MySQL** - 关系型数据库
- **Redis** - 缓存服务
- **MinIO** - 对象存储服务
- **MongoDB** - 文档数据库
- **Chroma** - 向量数据库
- **Metabase** - 数据分析平台
- **Activiti Cloud** - 工作流引擎
- **CRM 微服务** - Gateway, Foundation, Business, Workflow, Finance

## 🚀 快速开始

### 1. 安装 Chart

```bash
cd /home/bantu/crm-configuration/k8s/helm
helm install bantu-crm ./bantu-crm
```

### 2. 使用自定义配置

```bash
# 创建自定义 values 文件
cp bantu-crm/values.yaml my-values.yaml

# 编辑配置
vim my-values.yaml

# 使用自定义配置安装
helm install bantu-crm ./bantu-crm -f my-values.yaml
```

### 3. 升级部署

```bash
helm upgrade bantu-crm ./bantu-crm
```

### 4. 卸载

```bash
helm uninstall bantu-crm
```

## ⚙️ 配置说明

### 启用/禁用服务

在 `values.yaml` 中设置 `enabled: true/false` 来控制服务的部署：

```yaml
mysql:
  enabled: true  # 启用 MySQL

redis:
  enabled: false  # 禁用 Redis
```

### 自定义资源

```yaml
mysql:
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "4Gi"
      cpu: "2000m"
```

### 自定义存储

```yaml
mysql:
  persistence:
    enabled: true
    size: 100Gi
    storageClass: local-storage
```

## 📋 部署顺序

Helm 会自动处理依赖关系，但建议按以下顺序部署：

1. **MySQL** (必须)
2. **Redis** (可选)
3. **MinIO** (可选)
4. **MongoDB** (可选)
5. **Chroma** (可选)
6. **Metabase** (可选)
7. **Activiti Cloud** (可选)
8. **CRM 微服务** (可选)

## 🔍 查看状态

```bash
# 查看所有资源
helm status bantu-crm

# 查看 Pod 状态
kubectl get pods -l app.kubernetes.io/instance=bantu-crm

# 查看服务
kubectl get svc -l app.kubernetes.io/instance=bantu-crm
```

## 📝 注意事项

1. **存储路径**: 默认数据存储在 `/home/bantu/bantu-data/`，确保该目录存在且有写权限
2. **节点名称**: 如果使用 local-storage，需要设置正确的节点名称
3. **密码安全**: 生产环境请修改所有默认密码
4. **资源限制**: 根据实际需求调整资源请求和限制

## 🔧 故障排查

### Pod 无法启动

```bash
# 查看 Pod 日志
kubectl logs <pod-name>

# 查看 Pod 详情
kubectl describe pod <pod-name>
```

### PVC 未绑定

```bash
# 检查 PV 和 PVC
kubectl get pv,pvc

# 检查存储类
kubectl get storageclass
```

## 📚 更多信息

查看各服务的详细文档：
- MySQL: `../mysql/README.md`
- Redis: `../redis/README.md`
- MinIO: `../minio/README.md`
- MongoDB: `../mongodb/README.md`
- Chroma: `../chroma/README.md`
- Metabase: `../metabase/README.md`
- Activiti Cloud: `../activiti-cloud/README.md`

