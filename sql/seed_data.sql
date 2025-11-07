-- ============================================================
-- BANTU CRM 种子数据 (Seed Data)
-- ============================================================
-- 用于初始化系统的基础数据
-- 
-- 执行顺序：
-- 1. 先执行 schema_unified.sql 创建表结构
-- 2. 再执行本文件创建 BANTU 根组织
-- 3. 可选：执行 vendors_seed_data.sql 创建供应商组织
-- 
-- Usage: mysql -u user -p database < sql/seed_data.sql
-- ============================================================

-- ============================================================
-- 1. 创建 BANTU 根组织
-- ============================================================
-- 这是系统的根组织，所有用户创建都需要依赖此组织
-- 注意：使用 INSERT IGNORE 避免重复插入

INSERT IGNORE INTO organizations (
    id,
    name,
    code,
    organization_type,
    parent_id,
    
    -- 基本信息
    email,
    phone,
    website,
    logo_url,
    description,
    
    -- 地址信息
    street,
    city,
    state_province,
    postal_code,
    country_region,
    country,
    country_code,
    
    -- 公司属性
    company_size,
    company_nature,
    company_type,
    industry,
    industry_code,
    sub_industry,
    business_scope,
    
    -- 工商信息
    registration_number,
    tax_id,
    legal_representative,
    established_date,
    registered_capital,
    registered_capital_currency,
    company_status,
    
    -- 财务信息
    annual_revenue,
    annual_revenue_currency,
    employee_count,
    revenue_year,
    
    -- 认证信息
    certifications,
    business_license_url,
    tax_certificate_url,
    is_verified,
    verified_at,
    verified_by,
    
    -- 状态字段
    is_active,
    is_locked,
    
    -- 时间字段（使用默认值）
    created_at,
    updated_at
) VALUES (
    -- 使用固定 UUID，确保可重复执行
    '00000000-0000-0000-0000-000000000001',
    
    -- 基本信息
    'BANTU Enterprise Services',
    'BANTU',
    'internal',  -- 内部组织
    NULL,        -- 根组织，无父组织
    
    -- 联系方式
    'info@bantu.sbs',
    '+86-400-000-0000',
    'https://www.bantu.sbs',
    'https://www.bantu.sbs/logo.png',
    'BANTU Enterprise Services - 企业级 CRM 系统提供商',
    
    -- 地址信息（示例）
    '示例街道地址',
    '北京',
    '北京市',
    '100000',
    '中国',
    '中国',
    'CN',
    
    -- 公司属性
    'medium',           -- 公司规模：medium
    'private',          -- 公司性质：private（私营）
    'limited',          -- 公司类型：limited（有限责任公司）
    '信息技术',         -- 行业领域
    'I65',              -- 行业代码（GB/T 4754-2017: 软件和信息技术服务业）
    '软件开发',         -- 细分行业
    '企业级 CRM 系统开发、销售和服务',
    
    -- 工商信息（示例，实际使用时需要替换为真实信息）
    '91110000MA00000001',  -- 统一社会信用代码（示例）
    '91110000MA00000001',  -- 税号（示例）
    '法定代表人',          -- 法定代表人（示例）
    '2020-01-01',          -- 成立日期（示例）
    1000000.00,            -- 注册资本：100万元
    'CNY',                 -- 注册资本币种
    'normal',              -- 公司状态：正常
    
    -- 财务信息（示例）
    5000000.00,            -- 年营业额：500万元
    'CNY',                 -- 营业额币种
    50,                    -- 员工数量
    2024,                  -- 营业额年份
    
    -- 认证信息
    CAST('["ISO9001"]' AS JSON), -- 认证信息（示例，JSON 数组格式）
    NULL,                  -- 营业执照URL（待上传）
    NULL,                  -- 税务登记证URL（待上传）
    FALSE,                 -- 是否已认证（待认证）
    NULL,                  -- 认证时间
    NULL,                  -- 认证人
    
    -- 状态字段
    TRUE,                  -- 激活状态
    FALSE,                 -- 锁定状态
    
    -- 时间字段（使用当前时间）
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- ============================================================
-- 2. 验证数据插入
-- ============================================================

-- 检查组织是否创建成功
SELECT 
    id,
    name,
    code,
    organization_type,
    is_active,
    is_locked,
    created_at
FROM organizations 
WHERE code = 'BANTU';

-- ============================================================
-- 说明
-- ============================================================
-- 1. 此组织作为系统的根组织，所有用户创建时都需要指定此组织
-- 2. 组织 ID 使用固定 UUID，确保可重复执行而不会创建重复数据
-- 3. 部分字段（如工商信息、财务信息）为示例数据，实际使用时需要替换为真实数据
-- 4. 认证信息（is_verified）默认为 FALSE，需要管理员手动认证
-- 5. 如需修改组织信息，请使用 UPDATE 语句，不要删除此记录

