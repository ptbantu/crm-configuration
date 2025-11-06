-- ============================================================
-- BANTU CRM Database Schema
-- ============================================================
-- Complete database schema for BANTU Enterprise Services CRM
-- Unified schema with all tables, constraints, indexes, and triggers
-- 
-- Usage: psql "$DATABASE_URL" -f sql/schema.sql
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- Helper Functions
-- ============================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 1. Core Tables: Organizations, Users, Roles
-- ============================================================

-- =====================================
-- Organizations (统一组织表)
-- =====================================
-- Supports: 'internal' (内部组织), 'vendor' (供应商), 'agent' (渠道代理)
CREATE TABLE IF NOT EXISTS organizations (
  id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name               TEXT NOT NULL,
  code               TEXT UNIQUE,
  external_id        TEXT UNIQUE,
  organization_type  TEXT NOT NULL,                     -- 'internal' | 'vendor' | 'agent'
  parent_id         UUID REFERENCES organizations(id) ON DELETE SET NULL,
  email              TEXT,
  phone              TEXT,
  website            TEXT,
  street             TEXT,
  city               TEXT,
  state_province     TEXT,
  postal_code        TEXT,
  country_region     TEXT,
  description        TEXT,
  is_active          BOOLEAN NOT NULL DEFAULT TRUE,
  is_locked          BOOLEAN,
  owner_id_external  TEXT,
  owner_name         TEXT,
  created_by_external TEXT,
  created_by_name    TEXT,
  updated_by_external TEXT,
  updated_by_name    TEXT,
  created_at_src     TIMESTAMPTZ,
  updated_at_src     TIMESTAMPTZ,
  last_action_at_src TIMESTAMPTZ,
  linked_module      TEXT,
  linked_id_external TEXT,
  tags               JSONB DEFAULT '[]'::jsonb,
  do_not_email       BOOLEAN,
  unsubscribe_method TEXT,
  unsubscribe_date_src TEXT,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_organizations_code ON organizations(code) WHERE code IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_organizations_type ON organizations(organization_type);
CREATE INDEX IF NOT EXISTS ix_organizations_type_active ON organizations(organization_type, is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS ix_organizations_email ON organizations(email) WHERE email IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_organizations_phone ON organizations(phone) WHERE phone IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_organizations_parent ON organizations(parent_id) WHERE parent_id IS NOT NULL;

ALTER TABLE organizations
  ADD CONSTRAINT IF NOT EXISTS chk_organizations_type
  CHECK (organization_type IN ('internal', 'vendor', 'agent'));

ALTER TABLE organizations
  ADD CONSTRAINT IF NOT EXISTS chk_organizations_parent_internal
  CHECK (parent_id IS NULL OR organization_type = 'internal');

-- =====================================
-- Vendor Extensions (供应商扩展表)
-- =====================================
CREATE TABLE IF NOT EXISTS vendor_extensions (
  organization_id    UUID PRIMARY KEY REFERENCES organizations(id) ON DELETE CASCADE,
  account_group      TEXT,
  category_name      TEXT,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE vendor_extensions
  ADD CONSTRAINT IF NOT EXISTS chk_vendor_extensions_type
  CHECK (
    EXISTS (
      SELECT 1 FROM organizations o 
      WHERE o.id = vendor_extensions.organization_id 
        AND o.organization_type = 'vendor'
    )
  );

-- =====================================
-- Agent Extensions (渠道代理扩展表)
-- =====================================
CREATE TABLE IF NOT EXISTS agent_extensions (
  organization_id    UUID PRIMARY KEY REFERENCES organizations(id) ON DELETE CASCADE,
  account_group      TEXT,
  category_name      TEXT,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE agent_extensions
  ADD CONSTRAINT IF NOT EXISTS chk_agent_extensions_type
  CHECK (
    EXISTS (
      SELECT 1 FROM organizations o 
      WHERE o.id = agent_extensions.organization_id 
        AND o.organization_type = 'agent'
    )
  );

-- =====================================
-- Roles (角色表)
-- =====================================
CREATE TABLE IF NOT EXISTS roles (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code            TEXT NOT NULL UNIQUE,
  name            TEXT NOT NULL,
  description     TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Seed core roles
INSERT INTO roles (code, name, description)
SELECT v.code, v.name, v.description
FROM (
  VALUES
    ('ADMIN','Administrator','System administrator with full access'),
    ('SALES','Sales','Internal sales representative'),
    ('AGENT','Channel Agent','External channel agent sales'),
    ('OPERATION','Operation','Order processing staff'),
    ('FINANCE','Finance','Finance staff for AR/AP and reports')
) AS v(code,name,description)
LEFT JOIN roles r ON r.code = v.code
WHERE r.id IS NULL;

-- =====================================
-- Users (用户表)
-- =====================================
CREATE TABLE IF NOT EXISTS users (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username        TEXT NOT NULL,                     -- NOT UNIQUE: can be duplicated across organizations
  email           TEXT UNIQUE,                       -- Global unique (nullable)
  phone           TEXT,
  display_name    TEXT,
  password_hash   TEXT,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  company_name    TEXT,
  user_type       TEXT,
  id_external     TEXT UNIQUE,
  organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL,
  last_login_at   TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Username uniqueness at organization level
CREATE UNIQUE INDEX IF NOT EXISTS ux_users_organization_username
  ON users(organization_id, username)
  WHERE username IS NOT NULL AND organization_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_users_email ON users(email);
CREATE INDEX IF NOT EXISTS ix_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS ix_users_organization ON users(organization_id) WHERE organization_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_users_organization_username ON users(organization_id, username) WHERE username IS NOT NULL;

-- =====================================
-- User Roles (用户角色关联表)
-- =====================================
CREATE TABLE IF NOT EXISTS user_roles (
  user_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role_id   UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, role_id)
);

-- =====================================
-- Organization Employees (统一组织员工表)
-- =====================================
CREATE TABLE IF NOT EXISTS organization_employees (
  id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id         UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  user_id                 UUID REFERENCES users(id) ON DELETE SET NULL,
  first_name              TEXT,
  last_name               TEXT,
  full_name               TEXT,
  email                   TEXT,
  phone                   TEXT,
  position                TEXT,
  department              TEXT,
  employee_number         TEXT,
  is_primary              BOOLEAN DEFAULT FALSE,
  is_manager              BOOLEAN DEFAULT FALSE,
  is_decision_maker       BOOLEAN DEFAULT FALSE,
  is_active               BOOLEAN NOT NULL DEFAULT TRUE,
  joined_at               DATE,
  left_at                 DATE,
  id_external             TEXT,
  external_user_id        TEXT,
  notes                   TEXT,
  created_by              UUID REFERENCES users(id) ON DELETE SET NULL,
  updated_by              UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_organization_employees_org ON organization_employees(organization_id);
CREATE INDEX IF NOT EXISTS ix_organization_employees_user ON organization_employees(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_organization_employees_active ON organization_employees(organization_id, user_id) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS ix_organization_employees_primary ON organization_employees(user_id) WHERE is_primary = TRUE AND is_active = TRUE AND user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_organization_employees_email ON organization_employees(email) WHERE email IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_organization_employees_phone ON organization_employees(phone) WHERE phone IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_organization_employees_one_primary_per_org
  ON organization_employees(organization_id) 
  WHERE is_primary = TRUE AND is_active = TRUE AND user_id IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_organization_employees_one_primary_per_user
  ON organization_employees(user_id) 
  WHERE is_primary = TRUE AND is_active = TRUE AND user_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_organization_employees_user_org_active
  ON organization_employees(organization_id, user_id) 
  WHERE is_active = TRUE AND user_id IS NOT NULL;

ALTER TABLE organization_employees
  ADD CONSTRAINT IF NOT EXISTS chk_organization_employees_internal_requires_user
  CHECK (
    NOT EXISTS (
      SELECT 1 FROM organizations o 
      WHERE o.id = organization_employees.organization_id 
        AND o.organization_type = 'internal'
    ) OR user_id IS NOT NULL
  );

ALTER TABLE organization_employees
  ADD CONSTRAINT IF NOT EXISTS chk_organization_employees_vendor_agent_name
  CHECK (
    user_id IS NOT NULL OR 
    (first_name IS NOT NULL AND last_name IS NOT NULL) OR
    NOT EXISTS (
      SELECT 1 FROM organizations o 
      WHERE o.id = organization_employees.organization_id 
        AND o.organization_type IN ('vendor', 'agent')
    )
  );

-- ============================================================
-- 2. Product Domain
-- ============================================================

-- =====================================
-- Product Categories (产品分类表)
-- =====================================
CREATE TABLE IF NOT EXISTS product_categories (
  id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code               TEXT NOT NULL UNIQUE,
  name               TEXT,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================
-- Products (产品表)
-- =====================================
CREATE TABLE IF NOT EXISTS products (
  id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  id_external             TEXT UNIQUE,
  owner_id_external       TEXT,
  owner_name              TEXT,
  created_by_external     TEXT,
  created_by_name         TEXT,
  updated_by_external     TEXT,
  updated_by_name         TEXT,
  created_at_src          TIMESTAMPTZ,
  updated_at_src          TIMESTAMPTZ,
  last_action_at_src      TIMESTAMPTZ,
  linked_module           TEXT,
  linked_id_external      TEXT,
  name                    TEXT NOT NULL,
  code                    TEXT,
  vendor_id               UUID REFERENCES organizations(id) ON DELETE SET NULL,
  vendor_id_external      TEXT,
  vendor_name             TEXT,
  is_active               BOOLEAN NOT NULL DEFAULT TRUE,
  category_code           TEXT,
  unit                    TEXT,
  is_taxable              BOOLEAN,
  tax_rate                NUMERIC(5,2),
  tax_code                TEXT,
  price_list              NUMERIC(18,2),
  price_channel           NUMERIC(18,2),
  price_cost              NUMERIC(18,2),
  tags                    JSONB DEFAULT '[]'::jsonb,
  is_locked               BOOLEAN,
  notes                   TEXT,
  required_documents      TEXT,
  processing_time         TEXT,
  category_id             UUID REFERENCES product_categories(id) ON DELETE SET NULL,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_products_code ON products(code) WHERE code IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_products_active ON products(is_active) WHERE is_active = TRUE;

ALTER TABLE products
  ADD CONSTRAINT IF NOT EXISTS chk_products_prices_nonneg
  CHECK (
    COALESCE(price_list,0) >= 0 AND COALESCE(price_channel,0) >= 0 AND COALESCE(price_cost,0) >= 0
  );

-- ============================================================
-- 3. Customer Domain
-- ============================================================

-- =====================================
-- Customer Sources (客户来源表)
-- =====================================
CREATE TABLE IF NOT EXISTS customer_sources (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code          TEXT UNIQUE,
  name          TEXT NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================
-- Customer Channels (客户渠道表)
-- =====================================
CREATE TABLE IF NOT EXISTS customer_channels (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code          TEXT UNIQUE,
  name          TEXT NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================
-- Customers (客户表)
-- =====================================
CREATE TABLE IF NOT EXISTS customers (
  id                        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  id_external               TEXT UNIQUE,
  owner_id_external         TEXT,
  owner_name                TEXT,
  created_by_external       TEXT,
  created_by_name           TEXT,
  updated_by_external       TEXT,
  updated_by_name           TEXT,
  created_at_src            TIMESTAMPTZ,
  updated_at_src            TIMESTAMPTZ,
  last_action_at_src        TIMESTAMPTZ,
  change_log_at_src         TIMESTAMPTZ,
  linked_module             TEXT,
  linked_id_external        TEXT,
  name                      TEXT NOT NULL,
  code                      TEXT,
  level                     TEXT,
  parent_id_external        TEXT,
  parent_customer_id        UUID REFERENCES customers(id) ON DELETE SET NULL,
  parent_name               TEXT,
  industry                  TEXT,
  description               TEXT,
  tags                      JSONB DEFAULT '[]'::jsonb,
  is_locked                 BOOLEAN,
  last_enriched_at_src      TIMESTAMPTZ,
  enrich_status             TEXT,
  channel_name              TEXT,
  source_name               TEXT,
  customer_requirements     TEXT,
  source_id                 UUID REFERENCES customer_sources(id) ON DELETE SET NULL,
  channel_id                UUID REFERENCES customer_channels(id) ON DELETE SET NULL,
  customer_source_type      TEXT DEFAULT 'own',
  customer_type             TEXT DEFAULT 'individual',
  owner_user_id             UUID REFERENCES users(id) ON DELETE SET NULL,
  agent_user_id             UUID REFERENCES users(id) ON DELETE SET NULL,
  agent_id                  UUID REFERENCES organizations(id) ON DELETE SET NULL,
  created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_customers_code ON customers(code) WHERE code IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_customers_source_type ON customers(customer_source_type);
CREATE INDEX IF NOT EXISTS ix_customers_customer_type ON customers(customer_type);
CREATE INDEX IF NOT EXISTS ix_customers_owner ON customers(owner_user_id) WHERE owner_user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_customers_agent ON customers(agent_user_id) WHERE agent_user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_customers_agent_id ON customers(agent_id) WHERE agent_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_customers_parent ON customers(parent_customer_id) WHERE parent_customer_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_customers_source ON customers(customer_source_type);

ALTER TABLE customers
  ADD CONSTRAINT IF NOT EXISTS chk_customer_source_type
  CHECK (customer_source_type IN ('own', 'agent'));

ALTER TABLE customers
  ADD CONSTRAINT IF NOT EXISTS chk_customer_type
  CHECK (customer_type IN ('individual', 'organization'));

ALTER TABLE customers
  ADD CONSTRAINT IF NOT EXISTS chk_customer_ownership
  CHECK (
    (customer_source_type = 'own' AND owner_user_id IS NOT NULL AND agent_user_id IS NULL) OR
    (customer_source_type = 'agent' AND agent_user_id IS NOT NULL AND owner_user_id IS NULL) OR
    (owner_user_id IS NULL AND agent_user_id IS NULL)
  );

ALTER TABLE customers
  ADD CONSTRAINT IF NOT EXISTS chk_customers_agent_id_not_null
  CHECK (
    customer_source_type != 'agent' OR agent_id IS NOT NULL
  );

ALTER TABLE customers
  ADD CONSTRAINT IF NOT EXISTS chk_customers_owner_user_id_not_null
  CHECK (
    customer_source_type != 'own' OR owner_user_id IS NOT NULL
  );

ALTER TABLE customers
  ADD CONSTRAINT IF NOT EXISTS chk_customer_hierarchy
  CHECK (
    (customer_type = 'individual' AND parent_customer_id IS NULL) OR
    (customer_type = 'individual' AND parent_customer_id IS NOT NULL AND 
     EXISTS (SELECT 1 FROM customers c WHERE c.id = parent_customer_id AND c.customer_type = 'organization')) OR
    (customer_type = 'organization')
  );

-- =====================================
-- Contacts (联系人表)
-- =====================================
CREATE TABLE IF NOT EXISTS contacts (
  id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id             UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  first_name              TEXT NOT NULL,
  last_name               TEXT NOT NULL,
  full_name               TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
  email                   TEXT,
  phone                   TEXT,
  mobile                  TEXT,
  position                TEXT,
  department              TEXT,
  is_primary              BOOLEAN DEFAULT FALSE,
  is_decision_maker       BOOLEAN DEFAULT FALSE,
  contact_role            TEXT,
  address                 TEXT,
  city                    TEXT,
  province                TEXT,
  country                 TEXT,
  postal_code             TEXT,
  preferred_contact_method TEXT,
  wechat_id               TEXT,
  notes                   TEXT,
  is_active               BOOLEAN DEFAULT TRUE,
  created_by              UUID REFERENCES users(id) ON DELETE SET NULL,
  updated_by              UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_contacts_customer ON contacts(customer_id);
CREATE INDEX IF NOT EXISTS ix_contacts_email ON contacts(email);
CREATE INDEX IF NOT EXISTS ix_contacts_phone ON contacts(phone);
CREATE INDEX IF NOT EXISTS ix_contacts_primary ON contacts(customer_id, is_primary) WHERE is_primary = TRUE;

CREATE UNIQUE INDEX IF NOT EXISTS ux_contacts_one_primary_per_customer 
  ON contacts(customer_id) 
  WHERE is_primary = TRUE;

-- =====================================
-- Visa Records (签证记录表)
-- =====================================
CREATE TABLE IF NOT EXISTS visa_records (
  id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  id_external             TEXT UNIQUE,
  owner_id_external       TEXT,
  owner_name              TEXT,
  created_by_external     TEXT,
  created_by_name         TEXT,
  updated_by_external     TEXT,
  updated_by_name         TEXT,
  created_at_src          TIMESTAMPTZ,
  updated_at_src          TIMESTAMPTZ,
  last_action_at_src      TIMESTAMPTZ,
  linked_module           TEXT,
  linked_id_external      TEXT,
  customer_name           TEXT NOT NULL,
  customer_id             UUID REFERENCES customers(id) ON DELETE SET NULL,
  passport_id             TEXT,
  entry_city              TEXT,
  currency_code           TEXT,
  fx_rate                 NUMERIC(18,9),
  payment_amount          NUMERIC(18,2),
  cancel_method           TEXT,
  cancel_date_src         TEXT,
  is_locked               BOOLEAN,
  tags                    JSONB,
  processor_name          TEXT,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE visa_records
  ADD CONSTRAINT IF NOT EXISTS chk_visa_fx_rate_nonneg CHECK (COALESCE(fx_rate,0) >= 0),
  ADD CONSTRAINT IF NOT EXISTS chk_visa_payment_nonneg CHECK (COALESCE(payment_amount,0) >= 0);

-- ============================================================
-- 4. Order Domain
-- ============================================================

-- =====================================
-- Order Statuses (订单状态表)
-- =====================================
CREATE TABLE IF NOT EXISTS order_statuses (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code          TEXT NOT NULL UNIQUE,
  name          TEXT NOT NULL,
  description   TEXT,
  display_order INTEGER,
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Seed order statuses
INSERT INTO order_statuses (code, name, description, display_order)
SELECT v.code, v.name, v.description, v.display_order
FROM (
  VALUES
    ('draft','草稿','订单草稿，未提交', 1),
    ('submitted','已提交','订单已提交，待接单', 2),
    ('assigned','已分配','已分配给做单人员', 3),
    ('in_progress','进行中','做单进行中', 4),
    ('pending_review','待审核','待审核交付物', 5),
    ('completed','已完成','订单已完成', 6),
    ('cancelled','已取消','订单已取消', 7),
    ('on_hold','暂停','订单暂停', 8)
) AS v(code, name, description, display_order)
LEFT JOIN order_statuses os ON os.code = v.code
WHERE os.id IS NULL;

-- =====================================
-- Orders (订单表)
-- =====================================
CREATE TABLE IF NOT EXISTS orders (
  id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number            TEXT NOT NULL,
  title                   TEXT NOT NULL,
  customer_id             UUID NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
  product_id              UUID REFERENCES products(id) ON DELETE SET NULL,
  product_name            TEXT,
  sales_user_id           UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  sales_username          TEXT,
  quantity                INTEGER DEFAULT 1,
  unit_price              NUMERIC(18,2),
  total_amount            NUMERIC(18,2),
  currency_code           TEXT DEFAULT 'CNY',
  discount_amount         NUMERIC(18,2) DEFAULT 0,
  final_amount            NUMERIC(18,2),
  status_id               UUID REFERENCES order_statuses(id) ON DELETE SET NULL,
  status_code             TEXT,
  expected_start_date     DATE,
  expected_completion_date DATE,
  actual_start_date       DATE,
  actual_completion_date   DATE,
  customer_notes          TEXT,
  internal_notes          TEXT,
  requirements            TEXT,
  created_by              UUID REFERENCES users(id) ON DELETE SET NULL,
  updated_by              UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_orders_number 
  ON orders(order_number) WHERE order_number IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_orders_customer ON orders(customer_id);
CREATE INDEX IF NOT EXISTS ix_orders_product ON orders(product_id) WHERE product_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_orders_sales ON orders(sales_user_id);
CREATE INDEX IF NOT EXISTS ix_orders_status ON orders(status_code) WHERE status_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_orders_status_id ON orders(status_id) WHERE status_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_orders_created ON orders(created_at DESC);

ALTER TABLE orders
  ADD CONSTRAINT IF NOT EXISTS chk_orders_amounts_nonneg
  CHECK (
    COALESCE(quantity, 0) >= 0 
    AND COALESCE(unit_price, 0) >= 0 
    AND COALESCE(total_amount, 0) >= 0 
    AND COALESCE(discount_amount, 0) >= 0 
    AND COALESCE(final_amount, 0) >= 0
  );

-- =====================================
-- Order Assignments (订单分配表)
-- =====================================
CREATE TABLE IF NOT EXISTS order_assignments (
  id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id                UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  assigned_to_user_id     UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  assigned_by_user_id     UUID REFERENCES users(id) ON DELETE SET NULL,
  assignment_type         TEXT DEFAULT 'operation',
  is_primary              BOOLEAN DEFAULT TRUE,
  vendor_id               UUID REFERENCES organizations(id) ON DELETE SET NULL,
  organization_employee_id UUID REFERENCES organization_employees(id) ON DELETE SET NULL,
  vendor_employee_id      UUID REFERENCES organization_employees(id) ON DELETE SET NULL,
  assigned_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  unassigned_at           TIMESTAMPTZ,
  notes                   TEXT,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_order_assignments_order ON order_assignments(order_id);
CREATE INDEX IF NOT EXISTS ix_order_assignments_user ON order_assignments(assigned_to_user_id);
CREATE INDEX IF NOT EXISTS ix_order_assignments_active 
  ON order_assignments(order_id, assigned_to_user_id) 
  WHERE unassigned_at IS NULL;
CREATE INDEX IF NOT EXISTS ix_order_assignments_org_employee 
  ON order_assignments(organization_employee_id) 
  WHERE organization_employee_id IS NOT NULL;

ALTER TABLE order_assignments
  ADD CONSTRAINT IF NOT EXISTS chk_order_assignments_vendor
  CHECK (
    assignment_type != 'vendor' OR 
    (vendor_id IS NOT NULL OR organization_employee_id IS NOT NULL)
  );

ALTER TABLE order_assignments
  ADD CONSTRAINT IF NOT EXISTS chk_order_assignments_operation
  CHECK (
    assignment_type != 'operation' OR 
    assigned_to_user_id IS NOT NULL
  );

ALTER TABLE order_assignments
  ADD CONSTRAINT IF NOT EXISTS chk_order_assignments_org_employee_type
  CHECK (
    organization_employee_id IS NULL OR
    EXISTS (
      SELECT 1 FROM organization_employees oe
      JOIN organizations o ON o.id = oe.organization_id
      WHERE oe.id = order_assignments.organization_employee_id
        AND o.organization_type IN ('vendor', 'agent')
    )
  );

-- =====================================
-- Order Stages (订单阶段表)
-- =====================================
CREATE TABLE IF NOT EXISTS order_stages (
  id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id                UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  stage_name              TEXT NOT NULL,
  stage_code              TEXT,
  stage_order             INTEGER NOT NULL,
  status                  TEXT DEFAULT 'pending',
  started_at              TIMESTAMPTZ,
  completed_at            TIMESTAMPTZ,
  progress_percent        INTEGER DEFAULT 0,
  notes                   TEXT,
  assigned_to_user_id     UUID REFERENCES users(id) ON DELETE SET NULL,
  created_by              UUID REFERENCES users(id) ON DELETE SET NULL,
  updated_by              UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_order_stages_order ON order_stages(order_id);
CREATE INDEX IF NOT EXISTS ix_order_stages_assigned ON order_stages(assigned_to_user_id);
CREATE INDEX IF NOT EXISTS ix_order_stages_status ON order_stages(status);

ALTER TABLE order_stages
  ADD CONSTRAINT IF NOT EXISTS chk_order_stages_progress_range
  CHECK (progress_percent >= 0 AND progress_percent <= 100);

-- =====================================
-- Deliverables (交付物表)
-- =====================================
CREATE TABLE IF NOT EXISTS deliverables (
  id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id                UUID REFERENCES orders(id) ON DELETE CASCADE,
  order_stage_id          UUID REFERENCES order_stages(id) ON DELETE SET NULL,
  deliverable_type        TEXT NOT NULL,
  name                    TEXT NOT NULL,
  description             TEXT,
  file_path               TEXT,
  file_url                TEXT,
  file_size               BIGINT,
  mime_type               TEXT,
  is_verified             BOOLEAN DEFAULT FALSE,
  verified_by             UUID REFERENCES users(id) ON DELETE SET NULL,
  verified_at             TIMESTAMPTZ,
  uploaded_by             UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_deliverables_order ON deliverables(order_id);
CREATE INDEX IF NOT EXISTS ix_deliverables_stage ON deliverables(order_stage_id);
CREATE INDEX IF NOT EXISTS ix_deliverables_uploaded ON deliverables(uploaded_by);

ALTER TABLE deliverables
  ADD CONSTRAINT IF NOT EXISTS chk_deliverables_file_size_nonneg
  CHECK (COALESCE(file_size, 0) >= 0);

-- =====================================
-- Payments (收款记录表)
-- =====================================
CREATE TABLE IF NOT EXISTS payments (
  id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id                UUID NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
  payment_type            TEXT NOT NULL,
  amount                  NUMERIC(18,2) NOT NULL,
  currency_code           TEXT DEFAULT 'CNY',
  payment_method          TEXT,
  payment_date            DATE,
  received_at            TIMESTAMPTZ,
  transaction_id          TEXT,
  bank_account            TEXT,
  payer_name              TEXT,
  payer_account           TEXT,
  status                  TEXT DEFAULT 'pending',
  confirmed_by            UUID REFERENCES users(id) ON DELETE SET NULL,
  confirmed_at            TIMESTAMPTZ,
  notes                   TEXT,
  created_by              UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_payments_order ON payments(order_id);
CREATE INDEX IF NOT EXISTS ix_payments_status ON payments(status) WHERE status IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_payments_date ON payments(payment_date DESC);

-- ============================================================
-- Triggers
-- ============================================================

DO $$
BEGIN
  -- Organizations
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'organizations_updated_at') THEN
    CREATE TRIGGER organizations_updated_at
    BEFORE UPDATE ON organizations
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
  
  -- Vendor extensions
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'vendor_extensions_updated_at') THEN
    CREATE TRIGGER vendor_extensions_updated_at
    BEFORE UPDATE ON vendor_extensions
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
  
  -- Agent extensions
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'agent_extensions_updated_at') THEN
    CREATE TRIGGER agent_extensions_updated_at
    BEFORE UPDATE ON agent_extensions
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
  
  -- Users
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'users_updated_at') THEN
    CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
  
  -- Roles
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'roles_updated_at') THEN
    CREATE TRIGGER roles_updated_at
    BEFORE UPDATE ON roles
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
  
  -- Organization employees
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'organization_employees_updated_at') THEN
    CREATE TRIGGER organization_employees_updated_at
    BEFORE UPDATE ON organization_employees
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
  
  -- Products
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'products_updated_at') THEN
    CREATE TRIGGER products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
  
  -- Product categories
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'product_categories_updated_at') THEN
    CREATE TRIGGER product_categories_updated_at
    BEFORE UPDATE ON product_categories
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
  
  -- Customers
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'customers_updated_at') THEN
    CREATE TRIGGER customers_updated_at
    BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
  
  -- Customer sources
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'customer_sources_updated_at') THEN
    CREATE TRIGGER customer_sources_updated_at
    BEFORE UPDATE ON customer_sources
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
  
  -- Customer channels
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'customer_channels_updated_at') THEN
    CREATE TRIGGER customer_channels_updated_at
    BEFORE UPDATE ON customer_channels
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
  
  -- Contacts
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'contacts_updated_at') THEN
    CREATE TRIGGER contacts_updated_at
    BEFORE UPDATE ON contacts
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
  
  -- Visa records
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'visa_records_updated_at') THEN
    CREATE TRIGGER visa_records_updated_at
    BEFORE UPDATE ON visa_records
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
  
  -- Orders
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'orders_updated_at') THEN
    CREATE TRIGGER orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
  
  -- Order statuses
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'order_statuses_updated_at') THEN
    CREATE TRIGGER order_statuses_updated_at
    BEFORE UPDATE ON order_statuses
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
  
  -- Order stages
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'order_stages_updated_at') THEN
    CREATE TRIGGER order_stages_updated_at
    BEFORE UPDATE ON order_stages
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
  
  -- Deliverables
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'deliverables_updated_at') THEN
    CREATE TRIGGER deliverables_updated_at
    BEFORE UPDATE ON deliverables
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
  
  -- Payments
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'payments_updated_at') THEN
    CREATE TRIGGER payments_updated_at
    BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
END $$;

-- ============================================================
-- Views
-- ============================================================

-- Customer with owner/agent info
CREATE OR REPLACE VIEW customer_ownership_view AS
SELECT 
  c.id,
  c.name,
  c.code,
  c.customer_source_type,
  c.customer_type,
  c.owner_user_id,
  owner.display_name as owner_name,
  owner.username as owner_username,
  c.agent_user_id,
  agent.display_name as agent_name,
  agent.username as agent_username,
  c.agent_id,
  agent_org.name as agent_organization_name,
  agent_org.code as agent_organization_code,
  c.parent_customer_id,
  parent.name as parent_customer_name,
  c.created_at
FROM customers c
LEFT JOIN users owner ON owner.id = c.owner_user_id
LEFT JOIN users agent ON agent.id = c.agent_user_id
LEFT JOIN organizations agent_org ON agent_org.id = c.agent_id
LEFT JOIN customers parent ON parent.id = c.parent_customer_id;

-- Organization with contacts count
CREATE OR REPLACE VIEW organization_contacts_view AS
SELECT 
  c.id as customer_id,
  c.name as organization_name,
  c.customer_source_type,
  c.owner_user_id,
  c.agent_user_id,
  c.agent_id,
  COUNT(ct.id) as contacts_count,
  COUNT(ct.id) FILTER (WHERE ct.is_primary = TRUE) as primary_contacts_count
FROM customers c
LEFT JOIN contacts ct ON ct.customer_id = c.id AND ct.is_active = TRUE
WHERE c.customer_type = 'organization'
GROUP BY c.id, c.name, c.customer_source_type, c.owner_user_id, c.agent_user_id, c.agent_id;

-- ============================================================
-- Schema Complete
-- ============================================================

