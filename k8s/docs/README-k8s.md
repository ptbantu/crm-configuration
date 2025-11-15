# MySQL Kubernetes 部署

## 部署说明

最简单的 MySQL 部署方式，数据持久化到 `/home/bantu/bantu-data/mysql`。

## 文件说明

- `mysql-secret.yaml` - MySQL 认证信息（root 密码、数据库名、用户密码）
- `mysql-pv.yaml` - PersistentVolume，指向本地路径
- `mysql-pvc.yaml` - PersistentVolumeClaim，绑定 PV
- `mysql-deployment.yaml` - MySQL Deployment 配置
- `mysql-service.yaml` - MySQL Service（ClusterIP）

## 部署步骤

### 方式一：使用自动部署脚本（推荐）

```bash
cd /home/bantu/crm-configuration/k8s
./deploy-mysql.sh
```

脚本会自动：
- 检测节点名并生成 PV 配置
- 创建数据目录
- 按顺序部署所有资源
- 等待 Pod 就绪并显示状态

### 方式二：手动部署

```bash
# 1. 确保数据目录存在
mkdir -p /home/bantu/bantu-data/mysql
chmod 777 /home/bantu/bantu-data/mysql

# 2. 获取节点名称
kubectl get nodes

# 3. 编辑 mysql-pv.yaml，取消注释 nodeAffinity 并填入节点名

# 4. 按顺序部署
kubectl apply -f mysql-secret.yaml
kubectl apply -f mysql-pv.yaml
kubectl apply -f mysql-pvc.yaml
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml

# 5. 检查状态
kubectl get pv,pvc,pods,svc -l app=mysql

# 6. 查看日志（如有问题）
kubectl logs -l app=mysql
```

## 连接信息

- **Service 名称**: `mysql.default.svc.cluster.local` (集群内)
- **端口**: 3306
- **数据库名**: `bantu_crm`
- **Root 用户**: `root` / `bantu_root_password_2024`
- **应用用户**: `bantu_user` / `bantu_user_password_2024`

## 注意事项

1. **节点亲和性**: PV 使用 local volume，需要指定节点。如果节点名未填，需要手动编辑 `mysql-pv.yaml`。
2. **权限**: 确保 `/home/bantu/bantu-data/mysql` 目录对容器有读写权限。
3. **首次启动**: MySQL 首次启动可能需要 30-60 秒初始化。
4. **备份**: 数据存储在 `/home/bantu/bantu-data/mysql`，建议定期备份该目录。

## 修改密码

编辑 `mysql-secret.yaml` 后重新应用：
```bash
kubectl apply -f mysql-secret.yaml
kubectl delete pod -l app=mysql  # 重启 Pod 使新配置生效
```

