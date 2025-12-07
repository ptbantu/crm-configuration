# SSL/TLS 证书配置说明

## 概述

本目录包含为 `www.bantuqifu.xin` 域名配置 Let's Encrypt SSL/TLS 证书的配置文件。

## 文件说明

- `cluster-issuer.yaml` - Let's Encrypt ClusterIssuer 配置
- `certificate.yaml` - SSL 证书资源定义
- `deploy-cert-manager.sh` - 一键部署脚本

## 部署步骤

### 1. 部署 cert-manager

```bash
cd /home/bantuqifu/crm-configuration/k8s/cert-manager
./deploy-cert-manager.sh
```

### 2. 创建证书

```bash
kubectl apply -f certificate.yaml
```

### 3. 检查证书状态

```bash
# 检查证书状态
kubectl get certificate

# 查看证书详情
kubectl describe certificate bantuqifu-xin-tls-cert

# 检查证书 Secret（证书申请成功后会自动创建）
kubectl get secret bantuqifu-xin-tls-cert
```

## 证书申请流程

1. **Certificate 资源创建** → cert-manager 检测到新的证书请求
2. **CertificateRequest 创建** → cert-manager 创建证书请求
3. **Order 创建** → Let's Encrypt 创建订单
4. **Challenge 创建** → HTTP-01 验证挑战
5. **域名验证** → Let's Encrypt 验证域名所有权
6. **证书颁发** → 验证成功后颁发证书
7. **Secret 创建** → 证书存储到 Kubernetes Secret

## 验证域名解析

在申请证书前，确保域名已正确解析到服务器：

```bash
# 检查域名解析
nslookup www.bantuqifu.xin
dig www.bantuqifu.xin

# 检查 HTTP 访问（应该返回 200）
curl -I http://www.bantuqifu.xin
```

## 故障排查

### 证书申请失败

1. **检查 ClusterIssuer 状态**
   ```bash
   kubectl get clusterissuer letsencrypt-prod
   kubectl describe clusterissuer letsencrypt-prod
   ```

2. **检查证书请求状态**
   ```bash
   kubectl get certificaterequest
   kubectl describe certificaterequest <name>
   ```

3. **检查挑战状态**
   ```bash
   kubectl get challenge
   kubectl describe challenge <name>
   ```

4. **检查 cert-manager 日志**
   ```bash
   kubectl logs -n cert-manager -l app.kubernetes.io/instance=cert-manager
   ```

### 常见问题

1. **域名未解析** - 确保 DNS 记录正确指向服务器 IP
2. **HTTP 访问不通** - 确保 Ingress 配置正确，80 端口可访问
3. **速率限制** - Let's Encrypt 有速率限制，如果失败请等待后重试
4. **邮箱配置** - 确保 `cluster-issuer.yaml` 中的邮箱地址正确

## 证书自动续期

cert-manager 会自动监控证书有效期，在到期前 30 天自动续期。无需手动操作。

## 测试环境

如果需要使用 Let's Encrypt 测试环境（避免速率限制），可以：

1. 修改 `certificate.yaml` 中的 `issuerRef.name` 为 `letsencrypt-staging`
2. 申请测试证书验证流程
3. 确认无误后切换回 `letsencrypt-prod`

## 注意事项

- Let's Encrypt 证书有效期为 90 天
- cert-manager 会在到期前 30 天自动续期
- 生产环境请使用 `letsencrypt-prod`
- 确保邮箱地址正确，用于证书到期通知

