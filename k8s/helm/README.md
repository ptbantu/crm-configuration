# BANTU CRM Helm Chart

BANTU CRM 系统的一体化 Helm Chart，支持一键部署所有服务。

## 📁 目录结构

```
helm/
├── bantu-crm/              # Helm Chart 主目录
│   ├── Chart.yaml          # Chart 元数据
│   ├── values.yaml         # 默认配置值
│   ├── README.md           # Chart 说明文档
│   └── templates/          # Kubernetes 模板文件
│       ├── _helpers.tpl    # 模板辅助函数
│       ├── mysql-secret.yaml
│       ├── mysql-configmap.yaml
│       ├── mysql-pv.yaml
│       ├── mysql-pvc.yaml
│       ├── mysql-deployment.yaml
│       └── mysql-service.yaml
├── deploy.sh               # 一键部署脚本
├── convert-to-helm.sh      # YAML 转 Helm 模板辅助脚本
├── README.md              # 本文档
└── QUICK_START.md         # 快速开始指南
```

## ✅ 当前完成状态

- ✅ Chart 基础结构（Chart.yaml, values.yaml）
- ✅ 模板辅助函数（_helpers.tpl）
- ✅ MySQL 完整模板（Secret, ConfigMap, PV, PVC, Deployment, Service）
- ✅ 部署脚本和文档
- ⏳ 其他服务模板（待添加）

## 🚀 快速开始

### 1. 安装 MySQL（示例）

```bash
cd /home/bantu/crm-configuration/k8s/helm

# 安装 Chart（仅启用 MySQL）
helm install bantu-crm ./bantu-crm \
  --set mysql.enabled=true \
  --set redis.enabled=false \
  --set minio.enabled=false \
  --set mongodb.enabled=false \
  --set chroma.enabled=false \
  --set metabase.enabled=false \
  --set activitiCloud.enabled=false \
  --set crmServices.enabled=false
```

### 2. 使用部署脚本

```bash
cd /home/bantu/crm-configuration/k8s/helm
./deploy.sh
```

### 3. 查看状态

```bash
# Helm 状态
helm status bantu-crm

# Pod 状态
kubectl get pods -l app.kubernetes.io/instance=bantu-crm

# 服务状态
kubectl get svc -l app.kubernetes.io/instance=bantu-crm
```

## ⚙️ 配置说明

### 启用/禁用服务

编辑 `bantu-crm/values.yaml` 或使用 `--set` 参数：

```yaml
mysql:
  enabled: true   # 启用 MySQL

redis:
  enabled: false  # 禁用 Redis
```

### 自定义配置

```bash
# 使用自定义 values 文件
helm install bantu-crm ./bantu-crm -f my-values.yaml

# 或使用命令行参数
helm install bantu-crm ./bantu-crm \
  --set mysql.persistence.size=100Gi \
  --set mysql.resources.limits.memory=4Gi
```

## 📋 服务列表

| 服务 | 状态 | 说明 |
|------|------|------|
| MySQL | ✅ 完成 | 关系型数据库 |
| Redis | ⏳ 待添加 | 缓存服务 |
| MinIO | ⏳ 待添加 | 对象存储 |
| MongoDB | ⏳ 待添加 | 文档数据库 |
| Chroma | ⏳ 待添加 | 向量数据库 |
| Metabase | ⏳ 待添加 | 数据分析平台 |
| Activiti Cloud | ⏳ 待添加 | 工作流引擎 |
| CRM 微服务 | ⏳ 待添加 | Gateway, Foundation, Business, Workflow, Finance |

## 🔧 添加新服务模板

### 方法 1: 手动创建（推荐）

参考 `templates/mysql-*.yaml` 的格式创建新服务的模板。

### 方法 2: 使用转换脚本

```bash
# 转换现有 YAML 文件
./convert-to-helm.sh redis ../redis/redis-secret.yaml

# 转换后需要手动调整模板变量
```

详细说明请查看 `QUICK_START.md`。

## 📝 常用命令

```bash
# 安装
helm install bantu-crm ./bantu-crm

# 升级
helm upgrade bantu-crm ./bantu-crm

# 卸载
helm uninstall bantu-crm

# 查看配置
helm get values bantu-crm

# 模板渲染测试
helm template bantu-crm ./bantu-crm

# 语法检查
helm lint ./bantu-crm
```

## 🔍 故障排查

### Chart 语法错误

```bash
helm lint ./bantu-crm
```

### 模板渲染问题

```bash
# 干运行查看渲染结果
helm install bantu-crm ./bantu-crm --dry-run --debug
```

### Pod 无法启动

```bash
# 查看日志
kubectl logs <pod-name>

# 查看详情
kubectl describe pod <pod-name>
```

## 📚 相关文档

- [快速开始指南](QUICK_START.md)
- [MySQL 部署文档](../mysql/README.md)
- [Redis 部署文档](../redis/README.md)
- [MinIO 部署文档](../minio/README.md)
- [MongoDB 部署文档](../mongodb/README.md)

## 🎯 下一步计划

1. 完成 Redis 服务模板
2. 完成 MinIO 服务模板
3. 完成 MongoDB 服务模板
4. 完成 Chroma 服务模板
5. 完成 Metabase 服务模板
6. 完成 Activiti Cloud 服务模板
7. 完成 CRM 微服务模板
8. 添加依赖管理（使用 Helm dependencies）
9. 添加健康检查钩子
10. 添加数据库初始化 Job

## 💡 注意事项

1. **存储路径**: 默认数据存储在 `/home/bantu/bantu-data/`，确保目录存在
2. **节点名称**: 使用 local-storage 时需要设置正确的节点名称
3. **密码安全**: 生产环境请修改所有默认密码
4. **资源限制**: 根据实际需求调整资源请求和限制
5. **依赖关系**: MySQL 必须先部署，其他服务依赖 MySQL

