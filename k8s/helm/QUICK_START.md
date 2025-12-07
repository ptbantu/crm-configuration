# Helm Chart 快速开始指南

## 📦 当前状态

已创建 Helm Chart 基础结构，包含：
- ✅ Chart.yaml - Chart 元数据
- ✅ values.yaml - 配置值
- ✅ _helpers.tpl - 模板辅助函数
- ✅ MySQL 完整模板（Secret, ConfigMap, PV, PVC, Deployment, Service）
- ✅ 部署脚本和文档

## 🚀 快速部署 MySQL（示例）

```bash
cd /home/bantu/crm-configuration/k8s/helm

# 安装 Chart（仅 MySQL）
helm install bantu-crm ./bantu-crm --set mysql.enabled=true --set redis.enabled=false

# 查看状态
helm status bantu-crm

# 查看 Pod
kubectl get pods -l app=mysql
```

## 📝 添加其他服务模板

### 方法 1: 手动创建（推荐）

参考 `templates/mysql-*.yaml` 的格式，为其他服务创建模板：

1. **Secret 模板** (`templates/redis-secret.yaml`):
```yaml
{{- if .Values.redis.enabled }}
apiVersion: v1
kind: Secret
metadata:
  name: redis-secret
  namespace: {{ .Values.global.namespace }}
  labels:
    app: redis
    chart: {{ include "bantu-crm.chart" . }}
    release: {{ .Release.Name }}
type: Opaque
stringData:
  REDIS_PASSWORD: {{ .Values.redis.password | quote }}
{{- end }}
```

2. **Deployment 模板** (`templates/redis-deployment.yaml`):
```yaml
{{- if .Values.redis.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: {{ .Values.global.namespace }}
  labels:
    app: redis
    chart: {{ include "bantu-crm.chart" . }}
    release: {{ .Release.Name }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: {{ .Values.redis.image.repository }}:{{ .Values.redis.image.tag }}
        # ... 其他配置
        resources:
          {{- toYaml .Values.redis.resources | nindent 10 }}
{{- end }}
```

### 方法 2: 使用转换脚本（辅助）

```bash
# 转换 Redis Secret
./convert-to-helm.sh redis ../redis/redis-secret.yaml

# 转换后需要手动调整模板变量
```

## 🔧 完整部署所有服务

由于其他服务的模板尚未完全创建，当前可以：

### 选项 1: 逐步添加模板

1. 为每个服务创建模板文件
2. 在 values.yaml 中添加配置
3. 测试部署

### 选项 2: 混合部署（推荐用于快速测试）

```bash
# 使用 Helm 部署 MySQL
helm install bantu-crm ./bantu-crm --set mysql.enabled=true

# 等待 MySQL 就绪
kubectl wait --for=condition=ready pod -l app=mysql --timeout=300s

# 使用原有脚本部署其他服务
cd ../redis && ./deploy-redis.sh
cd ../minio && ./deploy-minio.sh
# ... 其他服务
```

## 📋 待完成的工作

- [ ] Redis 模板（Secret, ConfigMap, PV, PVC, Deployment, Service）
- [ ] MinIO 模板
- [ ] MongoDB 模板
- [ ] Chroma 模板
- [ ] Metabase 模板
- [ ] Activiti Cloud 模板
- [ ] CRM 微服务模板

## 💡 建议

1. **优先完成核心服务**: MySQL, Redis（已部分完成）
2. **逐步添加**: 每次添加一个服务的完整模板
3. **测试验证**: 每添加一个服务就测试一次
4. **文档更新**: 更新 README.md 记录新增服务

## 🔍 验证 Chart

```bash
# 检查 Chart 语法
helm lint ./bantu-crm

# 模板渲染测试
helm template bantu-crm ./bantu-crm

# 干运行（不实际部署）
helm install bantu-crm ./bantu-crm --dry-run --debug
```

