# 配置文件说明

## database.yml

数据库连接配置文件，包含 MySQL 的连接信息。

⚠️ **安全提示**: 
- 此文件包含敏感信息（密码），不应提交到版本控制系统
- 已在 `.gitignore` 中忽略 `database.yml`
- 示例文件 `database.example.yml` 已提交，不包含真实密码

## 使用方式

### 1. 复制示例文件

```bash
cp config/database.example.yml config/database.yml
```

### 2. 编辑配置文件

根据实际部署情况修改连接信息：

```yaml
mysql:
  host: mysql.default.svc.cluster.local  # 或外部 IP
  port: 3306
  database: bantu_crm
  root:
    username: root
    password: your_root_password
  app:
    username: bantu_user
    password: your_app_password
```

### 3. 应用中使用

#### Python (使用 PyYAML)

```python
import yaml

with open('config/database.yml') as f:
    config = yaml.safe_load(f)

db_config = config['mysql']
connection_string = config['connection_strings']['app_mysql']
```

#### Node.js

```javascript
const yaml = require('js-yaml');
const fs = require('fs');

const config = yaml.load(fs.readFileSync('config/database.yml', 'utf8'));
const dbConfig = config.mysql;
```

#### Java/Spring Boot

```yaml
# application.yml
spring:
  datasource:
    url: jdbc:mysql://mysql.default.svc.cluster.local:3306/bantu_crm
    username: ${DB_USER:bantu_user}
    password: ${DB_PASSWORD:bantu_user_password_2024}
```

## 环境变量

也可以使用环境变量方式配置：

```bash
export DB_HOST=mysql.default.svc.cluster.local
export DB_PORT=3306
export DB_NAME=bantu_crm
export DB_USER=bantu_user
export DB_PASSWORD=bantu_user_password_2024
```

## 连接字符串格式

配置文件提供了多种连接字符串格式：

- `root_mysql`: MySQL 协议格式（root 用户）
- `root_jdbc`: JDBC 格式（root 用户）
- `app_mysql`: MySQL 协议格式（应用用户）
- `app_jdbc`: JDBC 格式（应用用户）

## 更新密码

如果修改了 MySQL 密码：

1. 更新 `config/database.yml` 中的密码
2. 如果使用 K8s Secret，更新 Secret：
   ```bash
   kubectl edit secret mysql-secret
   ```
3. 重启 MySQL Pod 使新密码生效（如果 Secret 已更新）

