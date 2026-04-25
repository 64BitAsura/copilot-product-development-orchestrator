-- =============================================================================
-- BASE SCHEMA — [YOUR PRODUCT NAME]
-- =============================================================================
-- PostgreSQL 15+
-- Reflects domain model: docs/knowledge/blueprint/domain-model.md
-- ERD: docs/knowledge/schema/erd.md
-- Conventions: docs/knowledge/schema/schema-conventions.md
--
-- INSTRUCTIONS: Replace this starter schema with your product's actual tables.
-- Keep it in sync with domain-model.md and erd.md as your schema evolves.
-- For changes after the initial schema, use migration files (see migrations/).
--
-- To apply: psql -d <database> -f base-schema.sql
-- =============================================================================

-- ---------------------------------------------------------------------------
-- EXTENSIONS
-- ---------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";   -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pg_trgm";    -- trigram indexes for text search

-- ---------------------------------------------------------------------------
-- SCHEMA MIGRATIONS TRACKING
-- Record which migrations have been applied.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS schema_migrations (
    version     TEXT        NOT NULL PRIMARY KEY,  -- e.g. "20250101_001"
    applied_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- ENUM TYPES
-- Replace / extend these with your product's status values and categories.
-- ---------------------------------------------------------------------------

CREATE TYPE user_status AS ENUM (
    'active',
    'suspended',
    'pending_verification',
    'deleted'
);

CREATE TYPE membership_role AS ENUM (
    'owner',
    'admin',
    'member',
    'viewer'
);

-- ---------------------------------------------------------------------------
-- TABLE: users
-- Core identity table. One row per person who has registered.
-- ---------------------------------------------------------------------------
CREATE TABLE users (
    id                  UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    email               TEXT        NOT NULL,
    email_verified_at   TIMESTAMPTZ,
    display_name        TEXT        NOT NULL,
    avatar_url          TEXT,
    status              user_status NOT NULL DEFAULT 'pending_verification',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ,
    deleted_at          TIMESTAMPTZ  -- soft delete

    CONSTRAINT chk_users_email_format CHECK (email ~* '^[^@]+@[^@]+\.[^@]+$')
);

CREATE UNIQUE INDEX uq_users_email ON users (email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_status     ON users (status);
CREATE INDEX idx_users_deleted_at ON users (deleted_at);

-- ---------------------------------------------------------------------------
-- TABLE: organizations
-- A team or account that groups users and resources.
-- ---------------------------------------------------------------------------
CREATE TABLE organizations (
    id          UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    slug        TEXT        NOT NULL,          -- URL-safe identifier
    name        TEXT        NOT NULL,
    created_by  UUID        NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ
);

CREATE UNIQUE INDEX uq_organizations_slug ON organizations (slug) WHERE deleted_at IS NULL;
CREATE INDEX idx_organizations_created_by ON organizations (created_by);

-- ---------------------------------------------------------------------------
-- TABLE: organization_members
-- Junction table: which users belong to which organizations, and in what role.
-- ---------------------------------------------------------------------------
CREATE TABLE organization_members (
    id              UUID            NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    organization_id UUID            NOT NULL REFERENCES organizations (id) ON DELETE CASCADE,
    user_id         UUID            NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    role            membership_role NOT NULL DEFAULT 'member',
    invited_by      UUID            REFERENCES users (id) ON DELETE SET NULL,
    joined_at       TIMESTAMPTZ     NOT NULL DEFAULT now(),

    CONSTRAINT uq_organization_members UNIQUE (organization_id, user_id)
);

CREATE INDEX idx_organization_members_org_id  ON organization_members (organization_id);
CREATE INDEX idx_organization_members_user_id ON organization_members (user_id);

-- ---------------------------------------------------------------------------
-- ADD YOUR PRODUCT'S TABLES BELOW
-- ---------------------------------------------------------------------------
-- Follow the patterns established above:
--   - UUID primary keys using gen_random_uuid()
--   - created_at NOT NULL DEFAULT now() on every table
--   - updated_at TIMESTAMPTZ (nullable) on mutable tables
--   - deleted_at TIMESTAMPTZ (nullable) for soft-deleted entities
--   - Explicit ON DELETE action on every foreign key
--   - Index on every foreign key column
--   - See docs/knowledge/schema/schema-conventions.md for full rules
-- ---------------------------------------------------------------------------

-- Example: replace this with your core domain table
-- CREATE TABLE [your_entity] (
--     id              UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
--     organization_id UUID        NOT NULL REFERENCES organizations (id) ON DELETE CASCADE,
--     created_by      UUID        NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
--     name            TEXT        NOT NULL,
--     description     TEXT,
--     created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
--     updated_at      TIMESTAMPTZ
-- );
-- CREATE INDEX idx_[your_entity]_organization_id ON [your_entity] (organization_id);
-- CREATE INDEX idx_[your_entity]_created_by      ON [your_entity] (created_by);
