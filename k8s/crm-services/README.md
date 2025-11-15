# CRM 微服务部署

BANTU CRM 微服务系统的 Kubernetes 部署配置。

## 📁 文件说明

- `crm-deployments.yaml` - 所有微服务的 Deployment 配置
  - Gateway Service (端口 8080)
  - Foundation Service (端口 8081)
  - Business Service (端口 8082)
  - Workflow Service (端口 8083)
  - Finance Service (端口 8084)
- `crm-services.yaml` - 所有微服务的 Service 配置
- `deploy-all-services.sh` - 自动部署脚本
- `README-microservices.md` - 详细微服务说明

## 🚀 快速部署

### 前置条件

1. MySQL 已部署并运行
2. 数据库 Schema 和种子数据已导入

### 部署步骤

```bash
cd crm-services
./deploy-all-services.sh
```

## 🔗 服务访问

### 集群内访问

- **Gateway**: `http://crm-gateway:8080`
- **Foundation Service**: `http://crm-foundation-service:8081`
- **Business Service**: `http://crm-business-service:8082`
- **Workflow Service**: `http://crm-workflow-service:8083`
- **Finance Service**: `http://crm-finance-service:8084`

### 本地访问（端口转发）

```bash
# Gateway
kubectl port-forward svc/crm-gateway 8080:8080
# 然后访问: http://localhost:8080
```

## 📚 详细文档

查看 `README-microservices.md` 了解各微服务的详细说明。

