# Activiti 工作流引擎部署

Activiti Spring Boot 工作流引擎的 Kubernetes 部署配置。

## 📁 文件说明

- `activiti-configmap.yaml` - Activiti 配置文件
- `activiti-deployment.yaml` - Activiti Deployment 配置（完整版）
- `activiti-deployment-simple.yaml` - Activiti Deployment 配置（简化版）
- `activiti-service.yaml` - Activiti Service
- `activiti-ingress.yaml` - Ingress 配置（可选）
- `activiti-dockerfile` - Docker 镜像构建文件
- `deploy-activiti.sh` - 自动部署脚本
- `README-activiti.md` - 详细部署说明
- `BUILD-ACTIVITI.md` - 镜像构建说明

## 🚀 快速部署

### 前置条件

1. MySQL 已部署并运行
2. 数据库 Schema 已初始化

### 部署步骤

```bash
cd activiti
./deploy-activiti.sh
```

## 📚 详细文档

- **部署说明**: 查看 `README-activiti.md`
- **镜像构建**: 查看 `BUILD-ACTIVITI.md`

## 🔗 访问信息

- **集群内访问**: `http://activiti:8080/activiti`
- **本地访问**: `kubectl port-forward svc/activiti 8080:8080` 然后访问 `http://localhost:8080/activiti`

