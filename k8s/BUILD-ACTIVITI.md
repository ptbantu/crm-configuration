# 构建 Activiti Spring Boot 镜像指南

## 问题

`activiti/activiti-cloud-full-example:latest` 镜像不存在，需要构建自定义镜像。

## 解决方案

### 方案 1: 在 crm-backend 中构建 Activiti 应用（推荐）

#### 1. 添加 Activiti 依赖

在 `crm-backend` 项目的 `pom.xml` 或 `build.gradle` 中添加：

**Maven (pom.xml)**:
```xml
<dependencies>
    <!-- Activiti Spring Boot Starter -->
    <dependency>
        <groupId>org.activiti</groupId>
        <artifactId>activiti-spring-boot-starter</artifactId>
        <version>7.1.0</version>
    </dependency>
    
    <!-- MySQL Driver -->
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <version>8.0.33</version>
    </dependency>
</dependencies>
```

**Gradle (build.gradle)**:
```gradle
dependencies {
    implementation 'org.activiti:activiti-spring-boot-starter:7.1.0'
    implementation 'mysql:mysql-connector-java:8.0.33'
}
```

#### 2. 创建 Spring Boot 应用

创建主应用类：

```java
package com.bantu.activiti;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ActivitiApplication {
    public static void main(String[] args) {
        SpringApplication.run(ActivitiApplication.class, args);
    }
}
```

#### 3. 配置 application.yml

```yaml
spring:
  datasource:
    url: jdbc:mysql://mysql:3306/bantu_crm?useSSL=false&serverTimezone=UTC
    username: ${DB_USER:bantu_user}
    password: ${DB_PASSWORD:bantu_user_password_2024}
    driver-class-name: com.mysql.cj.jdbc.Driver
  activiti:
    database-schema-update: true
    async-executor-activate: true
    history-level: full

server:
  port: 8080
  servlet:
    context-path: /activiti
```

#### 4. 创建 Dockerfile

在 `crm-backend` 项目根目录创建 `Dockerfile`:

```dockerfile
FROM openjdk:11-jre-slim

WORKDIR /app

# 复制构建好的 JAR 文件
COPY target/activiti-app.jar app.jar

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=60s \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
```

#### 5. 构建镜像

```bash
cd /home/bantu/crm-backend

# 构建应用
mvn clean package
# 或
./gradlew build

# 构建 Docker 镜像
docker build -t activiti-spring-boot:latest .

# 或者推送到镜像仓库
docker tag activiti-spring-boot:latest your-registry/activiti-spring-boot:latest
docker push your-registry/activiti-spring-boot:latest
```

#### 6. 更新 Kubernetes 部署

修改 `activiti-deployment.yaml`:

```yaml
image: activiti-spring-boot:latest
# 或
image: your-registry/activiti-spring-boot:latest
```

### 方案 2: 使用 Activiti 7 Runtime Bundle

如果只需要工作流引擎，可以使用 Activiti Cloud Runtime Bundle:

```yaml
image: activiti/activiti-cloud-runtime-bundle:7.1.0
```

### 方案 3: 使用 Activiti 官方示例（如果可用）

检查 Docker Hub 上的可用镜像：
- https://hub.docker.com/u/activiti
- https://hub.docker.com/u/alfresco

## 快速测试

如果暂时无法构建镜像，可以使用临时占位镜像测试配置：

```bash
kubectl apply -f activiti-deployment.yaml
kubectl apply -f activiti-service.yaml
```

然后检查配置是否正确，再替换为实际的应用镜像。

## 下一步

1. 在 `crm-backend` 项目中创建 Activiti 模块
2. 添加 Activiti 依赖
3. 配置数据库连接
4. 构建 Docker 镜像
5. 更新 `activiti-deployment.yaml` 使用新镜像
6. 重新部署

