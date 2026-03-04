-- Migration 003: Multi-tenancy foundation
-- Creates the organizations table and adds organization_id to all entity tables.
-- Run this migration BEFORE deploying multi-tenant backend code.

-- 1. Organizations master table
CREATE TABLE IF NOT EXISTS organizations (
  id            VARCHAR(36)  NOT NULL DEFAULT (UUID()),
  name          VARCHAR(255) NOT NULL,
  subdomain     VARCHAR(50)  UNIQUE,
  subscription_tier   ENUM('free', 'professional', 'enterprise') DEFAULT 'free',
  subscription_status ENUM('active', 'trial', 'suspended') DEFAULT 'trial',
  max_users           INT          DEFAULT 10,
  max_facilitators    INT          DEFAULT 5,
  api_key             VARCHAR(64)  UNIQUE,
  stripe_customer_id  VARCHAR(255),
  trial_ends_at       TIMESTAMP    NULL,
  subscription_ends_at TIMESTAMP   NULL,
  created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  INDEX idx_org_subdomain (subdomain),
  INDEX idx_org_api_key   (api_key)
);

-- 2. Add organization_id to users (nullable initially for backward compat)
ALTER TABLE users
  ADD COLUMN organization_id VARCHAR(36) NULL AFTER id,
  ADD INDEX idx_users_org (organization_id),
  ADD CONSTRAINT fk_users_org
    FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- 3. Add organization_id to facilitators
ALTER TABLE facilitators
  ADD COLUMN organization_id VARCHAR(36) NULL AFTER id,
  ADD INDEX idx_facilitators_org (organization_id),
  ADD CONSTRAINT fk_facilitators_org
    FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- 4. Add organization_id to queries
ALTER TABLE queries
  ADD COLUMN organization_id VARCHAR(36) NULL AFTER id,
  ADD INDEX idx_queries_org (organization_id),
  ADD CONSTRAINT fk_queries_org
    FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- Rollback (reverse order):
-- ALTER TABLE queries    DROP FOREIGN KEY fk_queries_org,    DROP COLUMN organization_id;
-- ALTER TABLE facilitators DROP FOREIGN KEY fk_facilitators_org, DROP COLUMN organization_id;
-- ALTER TABLE users      DROP FOREIGN KEY fk_users_org,      DROP COLUMN organization_id;
-- DROP TABLE IF EXISTS organizations;
