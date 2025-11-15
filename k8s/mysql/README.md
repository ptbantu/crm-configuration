# MySQL Kubernetes 部署

MySQL 数据库服务的 Kubernetes 部署配置。

## 📁 文件说明

- `mysql-secret.yaml` - MySQL 认证信息（root 密码、数据库名、用户密码）
- `mysql-configmap.yaml` - 数据库连接配置（非敏感信息，供其他服务使用）
- `mysql-pv.yaml` - PersistentVolume，指向本地路径
- `mysql-pvc.yaml` - PersistentVolumeClaim，绑定 PV
- `mysql-deployment.yaml` - MySQL Deployment 配置（包含 init-scripts 挂载）
- `mysql-service.yaml` - MySQL Service（ClusterIP）
- `deploy-mysql.sh` - 自动部署脚本

## 📋 配置说明

### Secret (mysql-secret)
存储敏感信息（密码）：
- `MYSQL_ROOT_PASSWORD` - Root 用户密码
- `MYSQL_DATABASE` - 数据库名
- `MYSQL_USER` - 应用用户名
- `MYSQL_PASSWORD` - 应用用户密码

### ConfigMap (mysql-config)
存储非敏感连接信息，供其他服务引用：
- `DB_HOST` - 数据库主机
- `DB_PORT` - 数据库端口
- `DB_NAME` - 数据库名
- `DB_USER` - 应用用户名
- `DB_CHARSET` - 字符集
- `DB_COLLATION` - 排序规则
- `DB_JDBC_URL` - JDBC 连接字符串（不含密码）
- `ACTIVITI_*` - Activiti 工作流引擎相关配置

**其他服务可以通过以下方式引用：**
```yaml
env:
  - name: DB_HOST
    valueFrom:
      configMapKeyRef:
        name: mysql-config
        key: DB_HOST
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: mysql-secret
        key: MYSQL_PASSWORD
```

## 🔄 自动初始化

MySQL 容器会在首次启动时（数据库为空时）自动执行初始化脚本：

- **脚本位置**: `/home/bantu/crm-backend-python/init-scripts/`
- **挂载路径**: `/docker-entrypoint-initdb.d/`（容器内）
- **执行顺序**: 按文件名排序
  1. `01_schema_unified.sql` - 创建数据库表结构
  2. `02_seed_data.sql` - 创建预设角色和 BANTU 根组织
  3. `03_vendors_seed_data.sql` - 创建供应商组织

**注意**: 脚本只在数据库为空时执行。如果需要重新初始化，需要删除 PVC 和 PV。

## 🚀 部署步骤

### 方式一：使用自动部署脚本（推荐）

```bash
cd mysql
./deploy-mysql.sh
```

脚本会自动：
- 检测节点名并生成 PV 配置
- 创建数据目录
- 按顺序部署所有资源
- 等待 Pod 就绪并显示状态

### 方式二：手动部署

```bash
cd mysql

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

## 🔗 连接信息

- **Service 名称**: `mysql.default.svc.cluster.local` (集群内)
- **端口**: 3306
- **数据库名**: `bantu_crm`
- **Root 用户**: `root` / `bantu_root_password_2024`
- **应用用户**: `bantu_user` / `bantu_user_password_2024`

## ⚠️ 注意事项

1. **节点亲和性**: PV 使用 local volume，需要指定节点。如果节点名未填，需要手动编辑 `mysql-pv.yaml`。
2. **权限**: 确保 `/home/bantu/bantu-data/mysql` 目录对容器有读写权限。
3. **首次启动**: MySQL 首次启动可能需要 30-60 秒初始化。
4. **备份**: 数据存储在 `/home/bantu/bantu-data/mysql`，建议定期备份该目录。

## 🔧 修改密码

编辑 `mysql-secret.yaml` 后重新应用：

```bash
kubectl apply -f mysql-secret.yaml
kubectl delete pod -l app=mysql  # 重启 Pod 使新配置生效
```

## 📝 初始化说明

### 自动初始化（推荐）

MySQL 容器会在首次启动时自动执行 `/home/bantu/crm-backend-python/init-scripts/` 目录下的 SQL 文件，无需手动执行。

### 手动初始化（如果需要）

如果自动初始化失败或需要重新初始化：

```bash
cd ../scripts
./import-schema-mysql.sh  # 导入 Schema
./import-seed-data.sh      # 导入种子数据
```

### 重新初始化

如果需要重新初始化数据库（会删除所有数据）：

```bash
# 删除 MySQL Pod 和 PVC
kubectl delete deployment mysql
kubectl delete pvc mysql-pvc
kubectl delete pv mysql-pv

# 删除数据目录（可选，如果使用 local volume）
rm -rf /home/bantu/bantu-data/mysql/*

# 重新部署
cd mysql
./deploy-mysql.sh
```

