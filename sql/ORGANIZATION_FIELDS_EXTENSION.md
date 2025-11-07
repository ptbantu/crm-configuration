# Organizations 表字段扩展说明

## 概述

本次更新为 `organizations` 表添加了丰富的公司/组织信息字段，使其能够完整描述一个公司的各个方面。

## 新增字段分类

### 1. 基本信息扩展

| 字段名 | 类型 | 说明 | 示例值 |
|--------|------|------|--------|
| `logo_url` | VARCHAR(500) | 公司logo地址 | `https://example.com/logo.png` |

### 2. 地址信息扩展

| 字段名 | 类型 | 说明 | 示例值 |
|--------|------|------|--------|
| `country` | VARCHAR(100) | 国别（ISO 3166-1 alpha-2 或完整国家名） | `中国` 或 `China` |
| `country_code` | VARCHAR(10) | 国家代码 | `CN`, `US`, `GB` |

**注意**：`country_region` 字段保留，用于向后兼容。

### 3. 公司属性

| 字段名 | 类型 | 说明 | 可选值 |
|--------|------|------|--------|
| `company_size` | VARCHAR(50) | 公司规模 | `micro`, `small`, `medium`, `large`, `enterprise` |
| `company_nature` | VARCHAR(50) | 公司性质 | `state_owned`, `private`, `foreign`, `joint_venture`, `collective`, `individual`, `other` |
| `company_type` | VARCHAR(50) | 公司类型 | `limited`, `unlimited`, `partnership`, `sole_proprietorship`, `other` |
| `industry` | VARCHAR(100) | 行业领域（主行业） | `信息技术`, `金融服务`, `制造业` |
| `industry_code` | VARCHAR(50) | 行业代码 | `GB/T 4754-2017` 标准代码 |
| `sub_industry` | VARCHAR(100) | 细分行业 | `软件开发`, `互联网服务` |
| `business_scope` | TEXT | 经营范围 | 完整的经营范围描述 |

### 4. 工商信息

| 字段名 | 类型 | 说明 | 示例值 |
|--------|------|------|--------|
| `registration_number` | VARCHAR(100) | 注册号/统一社会信用代码 | `91110000MA01234567` |
| `tax_id` | VARCHAR(100) | 税号/纳税人识别号 | `91110000MA01234567` |
| `legal_representative` | VARCHAR(255) | 法定代表人 | `张三` |
| `established_date` | DATE | 成立日期 | `2020-01-01` |
| `registered_capital` | DECIMAL(18,2) | 注册资本（单位：元） | `1000000.00` |
| `registered_capital_currency` | VARCHAR(10) | 注册资本币种 | `CNY`, `USD` |
| `company_status` | VARCHAR(50) | 公司状态 | `normal`, `cancelled`, `revoked`, `liquidated`, `other` |

### 5. 财务信息

| 字段名 | 类型 | 说明 | 示例值 |
|--------|------|------|--------|
| `annual_revenue` | DECIMAL(18,2) | 年营业额（单位：元） | `50000000.00` |
| `annual_revenue_currency` | VARCHAR(10) | 营业额币种 | `CNY`, `USD` |
| `employee_count` | INT | 员工数量 | `150` |
| `revenue_year` | INT | 营业额年份 | `2023` |

### 6. 认证信息

| 字段名 | 类型 | 说明 | 示例值 |
|--------|------|------|--------|
| `certifications` | JSON | 认证信息（JSON数组） | `["ISO9001", "ISO14001", "CMMI5"]` |
| `business_license_url` | VARCHAR(500) | 营业执照URL | `https://example.com/license.pdf` |
| `tax_certificate_url` | VARCHAR(500) | 税务登记证URL | `https://example.com/tax.pdf` |
| `is_verified` | BOOLEAN | 是否已认证/审核 | `true`, `false` |
| `verified_at` | DATETIME | 认证时间 | `2024-01-01 10:00:00` |
| `verified_by` | CHAR(36) | 认证人（用户ID） | UUID |

## 字段枚举值说明

### 公司规模 (company_size)

- `micro`: 微型企业（通常 < 10 人）
- `small`: 小型企业（通常 10-50 人）
- `medium`: 中型企业（通常 50-200 人）
- `large`: 大型企业（通常 200-1000 人）
- `enterprise`: 超大型企业（通常 > 1000 人）

### 公司性质 (company_nature)

- `state_owned`: 国有企业
- `private`: 民营企业
- `foreign`: 外资企业
- `joint_venture`: 合资企业
- `collective`: 集体企业
- `individual`: 个体工商户
- `other`: 其他

### 公司类型 (company_type)

- `limited`: 有限责任公司
- `unlimited`: 无限责任公司
- `partnership`: 合伙企业
- `sole_proprietorship`: 个人独资企业
- `other`: 其他

### 公司状态 (company_status)

- `normal`: 正常经营
- `cancelled`: 已注销
- `revoked`: 已吊销
- `liquidated`: 已清算
- `other`: 其他状态

## 索引

为新增字段创建了以下索引，以支持高效查询：

- `ix_organizations_country` - 国别查询
- `ix_organizations_country_code` - 国家代码查询
- `ix_organizations_size` - 公司规模查询
- `ix_organizations_nature` - 公司性质查询
- `ix_organizations_industry` - 行业查询
- `ix_organizations_registration` - 注册号查询
- `ix_organizations_tax_id` - 税号查询
- `ix_organizations_status` - 公司状态查询
- `ix_organizations_verified` - 认证状态查询
- `ix_organizations_employee_count` - 员工数量查询

## 约束

### CHECK 约束

- `chk_organizations_size`: 确保 `company_size` 为有效值
- `chk_organizations_nature`: 确保 `company_nature` 为有效值
- `chk_organizations_company_type`: 确保 `company_type` 为有效值
- `chk_organizations_status`: 确保 `company_status` 为有效值
- `chk_organizations_capital_nonneg`: 确保注册资本 >= 0
- `chk_organizations_revenue_nonneg`: 确保年营业额 >= 0
- `chk_organizations_employee_nonneg`: 确保员工数量 >= 0

### 外键约束

- `verified_by` 引用 `users(id)`，用于记录认证人

## 数据迁移

对于现有数据：

1. **向后兼容**：所有新字段都是可选的（NULL），不会影响现有数据
2. **默认值**：
   - `registered_capital_currency` 默认 `CNY`
   - `annual_revenue_currency` 默认 `CNY`
   - `is_verified` 默认 `FALSE`
   - `certifications` 默认空数组 `JSON_ARRAY()`

## 使用建议

1. **公司规模**：根据员工数量或年营业额自动判断，或手动设置
2. **行业信息**：建议使用标准的行业分类代码（如 GB/T 4754-2017）
3. **认证信息**：`certifications` 字段使用 JSON 数组存储多个认证
4. **财务信息**：`revenue_year` 用于记录营业额对应的年份，支持历史数据
5. **认证流程**：通过 `is_verified`, `verified_at`, `verified_by` 实现认证审核流程

## 相关文件

- SQL Schema: `schema_unified.sql`
- Entity: `Organization.java`
- DTO: `OrganizationCreateRequest.java`

---

**更新日期**: 2024-11-07

