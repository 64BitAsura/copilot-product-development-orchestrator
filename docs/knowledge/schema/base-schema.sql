-- =============================================================================
-- BASE SCHEMA — copilot-product-development-orchestrator
-- =============================================================================
-- PostgreSQL 15+
-- Reflects domain model: docs/knowledge/blueprint/domain-model.md
-- ERD: docs/knowledge/schema/erd.md
-- Conventions: docs/knowledge/schema/schema-conventions.md
--
-- To apply: psql -d <database> -f base-schema.sql
-- To migrate: see docs/knowledge/schema/migrations-guide.md
-- =============================================================================

-- ---------------------------------------------------------------------------
-- EXTENSIONS
-- ---------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";   -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pg_trgm";    -- trigram indexes for text search

-- ---------------------------------------------------------------------------
-- ENUM TYPES
-- ---------------------------------------------------------------------------

CREATE TYPE input_type AS ENUM (
    'github_issue',
    'prompt'
);

CREATE TYPE reference_input_type AS ENUM (
    'url',
    'document',
    'image',
    'repository',
    'audio',
    'video'
);

CREATE TYPE session_status AS ENUM (
    'active',
    'completed',
    'failed',
    'abandoned'
);

CREATE TYPE pipeline_run_status AS ENUM (
    'in_progress',
    'waiting_for_approval',
    'completed',
    'failed',
    'paused'
);

CREATE TYPE stage_type AS ENUM (
    'requirements',
    'design',
    'planning',
    'security',
    'coding',
    'testing',
    'documentation'
);

CREATE TYPE stage_status AS ENUM (
    'pending',
    'in_progress',
    'waiting_for_approval',
    'approved',
    'completed',
    'failed',
    'skipped'
);

CREATE TYPE knowledge_document_category AS ENUM (
    'product_vision',
    'requirements',
    'blueprint',
    'schema',
    'design',
    'security',
    'testing',
    'tech_stack'
);

CREATE TYPE approval_decision AS ENUM (
    'approved',
    'revisions_requested',
    'rejected'
);

-- ---------------------------------------------------------------------------
-- TABLE: inputs
-- The raw material that starts a pipeline run.
-- ---------------------------------------------------------------------------
CREATE TABLE inputs (
    id              UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    type            input_type  NOT NULL,
    title           TEXT        NOT NULL,
    raw_content     TEXT        NOT NULL,
    source_url      TEXT,
    issue_number    INTEGER,
    repository      TEXT,                          -- "owner/repo"
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_inputs_repository ON inputs (repository);
CREATE INDEX idx_inputs_type       ON inputs (type);

-- ---------------------------------------------------------------------------
-- TABLE: reference_inputs
-- Supplementary references attached to a main input.
-- ---------------------------------------------------------------------------
CREATE TABLE reference_inputs (
    id          UUID                    NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    input_id    UUID                    NOT NULL REFERENCES inputs (id) ON DELETE CASCADE,
    type        reference_input_type    NOT NULL,
    source      TEXT                    NOT NULL,  -- URL, file path, or "owner/repo"
    summary     TEXT,                              -- agent-generated summary
    fetched_at  TIMESTAMPTZ,
    created_at  TIMESTAMPTZ             NOT NULL DEFAULT now()
);

CREATE INDEX idx_reference_inputs_input_id ON reference_inputs (input_id);

-- ---------------------------------------------------------------------------
-- TABLE: sessions
-- Long-lived context grouping pipeline runs for the same repository.
-- ---------------------------------------------------------------------------
CREATE TABLE sessions (
    id              UUID            NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    repository      TEXT            NOT NULL,      -- "owner/repo"
    created_by      TEXT            NOT NULL,      -- GitHub username
    status          session_status  NOT NULL DEFAULT 'active',
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ
);

CREATE INDEX idx_sessions_repository  ON sessions (repository);
CREATE INDEX idx_sessions_created_by  ON sessions (created_by);
CREATE INDEX idx_sessions_status      ON sessions (status);

-- ---------------------------------------------------------------------------
-- TABLE: pipeline_runs
-- A single end-to-end execution of the agent pipeline for one input.
-- ---------------------------------------------------------------------------
CREATE TABLE pipeline_runs (
    id                              UUID                NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    session_id                      UUID                NOT NULL REFERENCES sessions (id) ON DELETE CASCADE,
    input_id                        UUID                NOT NULL REFERENCES inputs (id),
    current_stage                   stage_type,
    status                          pipeline_run_status NOT NULL DEFAULT 'in_progress',
    selected_requirements_option    TEXT,              -- e.g. "Option A"
    selected_design_option          TEXT,
    selected_planning_option        TEXT,
    security_loop_count             INTEGER             NOT NULL DEFAULT 0,
    state_file_path                 TEXT,              -- ".copilot/pipeline/state.md"
    started_at                      TIMESTAMPTZ         NOT NULL DEFAULT now(),
    completed_at                    TIMESTAMPTZ
);

CREATE INDEX idx_pipeline_runs_session_id ON pipeline_runs (session_id);
CREATE INDEX idx_pipeline_runs_input_id   ON pipeline_runs (input_id);
CREATE INDEX idx_pipeline_runs_status     ON pipeline_runs (status);

-- ---------------------------------------------------------------------------
-- TABLE: stages
-- One agent's execution within a pipeline run.
-- ---------------------------------------------------------------------------
CREATE TABLE stages (
    id                  UUID            NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    pipeline_run_id     UUID            NOT NULL REFERENCES pipeline_runs (id) ON DELETE CASCADE,
    type                stage_type      NOT NULL,
    agent_name          TEXT            NOT NULL,  -- matches .agent.md filename
    status              stage_status    NOT NULL DEFAULT 'pending',
    output_file_path    TEXT,                      -- ".copilot/pipeline/<stage>.md"
    iteration_count     INTEGER         NOT NULL DEFAULT 1,
    started_at          TIMESTAMPTZ,
    completed_at        TIMESTAMPTZ,
    approved_at         TIMESTAMPTZ,
    approved_by         TEXT                       -- GitHub username
);

CREATE INDEX idx_stages_pipeline_run_id ON stages (pipeline_run_id);
CREATE INDEX idx_stages_type            ON stages (type);
CREATE INDEX idx_stages_status          ON stages (status);

-- Constraint: only one active (non-skipped, non-failed) stage of each type per pipeline run
CREATE UNIQUE INDEX idx_stages_unique_active_type
    ON stages (pipeline_run_id, type)
    WHERE status NOT IN ('skipped', 'failed');

-- ---------------------------------------------------------------------------
-- TABLE: stage_outputs
-- Versioned output document produced by a stage (one per iteration).
-- ---------------------------------------------------------------------------
CREATE TABLE stage_outputs (
    id          UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    stage_id    UUID        NOT NULL REFERENCES stages (id) ON DELETE CASCADE,
    iteration   INTEGER     NOT NULL DEFAULT 1,
    content     TEXT        NOT NULL,
    file_path   TEXT        NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_stage_outputs_iteration UNIQUE (stage_id, iteration)
);

CREATE INDEX idx_stage_outputs_stage_id ON stage_outputs (stage_id);

-- ---------------------------------------------------------------------------
-- TABLE: agent_profiles
-- Registry of custom agent definitions (.agent.md files).
-- ---------------------------------------------------------------------------
CREATE TABLE agent_profiles (
    id          UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    name        TEXT        NOT NULL UNIQUE,
    file_path   TEXT        NOT NULL,              -- ".github/agents/<name>.agent.md"
    description TEXT        NOT NULL,
    tools       TEXT[]      NOT NULL DEFAULT '{}',
    git_sha     TEXT,                              -- SHA of the agent file version used
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ
);

CREATE INDEX idx_agent_profiles_name ON agent_profiles (name);

-- ---------------------------------------------------------------------------
-- TABLE: knowledge_documents
-- Inventory of documents in the knowledge harness.
-- ---------------------------------------------------------------------------
CREATE TABLE knowledge_documents (
    id                  UUID                            NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    category            knowledge_document_category     NOT NULL,
    name                TEXT                            NOT NULL,
    file_path           TEXT                            NOT NULL UNIQUE,
    description         TEXT,
    last_updated_at     TIMESTAMPTZ,
    last_updated_by     TEXT                                       -- agent name or GitHub username
);

CREATE INDEX idx_knowledge_documents_category  ON knowledge_documents (category);

-- ---------------------------------------------------------------------------
-- TABLE: user_approvals
-- Audit log of every user approval decision during the pipeline.
-- ---------------------------------------------------------------------------
CREATE TABLE user_approvals (
    id              UUID                NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    pipeline_run_id UUID                NOT NULL REFERENCES pipeline_runs (id) ON DELETE CASCADE,
    stage_id        UUID                NOT NULL REFERENCES stages (id),
    decided_by      TEXT                NOT NULL,  -- GitHub username
    decision        approval_decision   NOT NULL,
    revision_notes  TEXT,                          -- user's feedback if revisions requested
    decided_at      TIMESTAMPTZ         NOT NULL DEFAULT now()
);

CREATE INDEX idx_user_approvals_pipeline_run_id ON user_approvals (pipeline_run_id);
CREATE INDEX idx_user_approvals_stage_id        ON user_approvals (stage_id);
CREATE INDEX idx_user_approvals_decided_by      ON user_approvals (decided_by);

-- ---------------------------------------------------------------------------
-- SEED: agent_profiles
-- Pre-populate with the built-in agents defined in .github/agents/
-- ---------------------------------------------------------------------------
INSERT INTO agent_profiles (name, file_path, description, tools) VALUES
(
    'orchestrator',
    '.github/agents/orchestrator.agent.md',
    'Main pipeline coordinator. Routes inputs through all specialist agents in sequence and manages user approval checkpoints.',
    ARRAY['agent', 'read', 'edit', 'search', 'execute', 'github/*']
),
(
    'requirements-agent',
    '.github/agents/requirements-agent.agent.md',
    'Analyzes inputs against the knowledge harness, identifies gaps, and produces approved requirements with acceptance criteria.',
    ARRAY['read', 'edit', 'search', 'web', 'github/*']
),
(
    'design-agent',
    '.github/agents/design-agent.agent.md',
    'Creates UX/UI specifications, wireframes, and design budgets based on approved requirements.',
    ARRAY['read', 'edit', 'search', 'github/*']
),
(
    'planning-agent',
    '.github/agents/planning-agent.agent.md',
    'Defines technical implementation options, data model changes, API specs, and implementation sequencing.',
    ARRAY['read', 'edit', 'search', 'web', 'github/*']
),
(
    'security-agent',
    '.github/agents/security-agent.agent.md',
    'Analyses implementation plans for OWASP Top 10 vulnerabilities, CVEs, and trust boundary violations.',
    ARRAY['read', 'edit', 'search', 'web', 'github/*']
),
(
    'coding-agent',
    '.github/agents/coding-agent.agent.md',
    'Coordinates language-specific subagents to implement the full stack solution per the approved plan.',
    ARRAY['read', 'edit', 'execute', 'search', 'agent', 'github/*']
),
(
    'tester-agent',
    '.github/agents/tester-agent.agent.md',
    'Generates test scenarios from acceptance criteria, writes unit and integration tests, and enforces coverage thresholds.',
    ARRAY['read', 'edit', 'execute', 'search', 'agent', 'github/*']
),
(
    'documentation-agent',
    '.github/agents/documentation-agent.agent.md',
    'Updates OpenAPI specs, implementation notes, changelogs, and READMEs after implementation is verified.',
    ARRAY['read', 'edit', 'search', 'github/*']
);

-- ---------------------------------------------------------------------------
-- SEED: knowledge_documents
-- Pre-populate with the initial knowledge harness files.
-- ---------------------------------------------------------------------------
INSERT INTO knowledge_documents (category, name, file_path, description) VALUES
('product_vision',  'Product Vision',              'docs/knowledge/product-vision.md',                       'Overall product purpose, users, values, and success metrics'),
('requirements',    'Requirements README',         'docs/knowledge/requirements/README.md',                  'Index of the requirements knowledge folder'),
('requirements',    'Requirement Template',        'docs/knowledge/requirements/requirement-template.md',    'Standard template for all requirements documents'),
('requirements',    'Gap Analysis Checklist',      'docs/knowledge/requirements/gap-analysis-checklist.md',  'Checklist used to identify missing information in inputs'),
('requirements',    'Acceptance Criteria Guide',   'docs/knowledge/requirements/acceptance-criteria-guide.md','How to write Given/When/Then acceptance criteria'),
('requirements',    'User Personas',               'docs/knowledge/requirements/personas.md',                'Defined user personas for the product'),
('requirements',    'Approved Patterns',           'docs/knowledge/requirements/approved-patterns.md',       'Pre-approved requirement patterns for common feature types'),
('requirements',    'Past Decisions',              'docs/knowledge/requirements/past-decisions.md',          'Append-only log of significant product decisions'),
('blueprint',       'Blueprint README',            'docs/knowledge/blueprint/README.md',                     'Index of the blueprint knowledge folder'),
('blueprint',       'Feature Map',                 'docs/knowledge/blueprint/feature-map.md',                'Complete inventory of all features and their relationships'),
('blueprint',       'Domain Model',                'docs/knowledge/blueprint/domain-model.md',               'Core domain concepts, entities, and ubiquitous language'),
('blueprint',       'Integration Points',          'docs/knowledge/blueprint/integration-points.md',         'All agent, service, and external integration connections'),
('blueprint',       'Capability Matrix',           'docs/knowledge/blueprint/capability-matrix.md',          'Maps every capability to the owning and contributing agents'),
('schema',          'Schema README',               'docs/knowledge/schema/README.md',                        'Index of the schema folder'),
('schema',          'Base Schema',                 'docs/knowledge/schema/base-schema.sql',                  'Complete base PostgreSQL schema for the product'),
('schema',          'Schema Conventions',          'docs/knowledge/schema/schema-conventions.md',            'Naming conventions, patterns, and rules for schema design'),
('schema',          'ERD',                         'docs/knowledge/schema/erd.md',                           'Entity relationship diagram in Mermaid format'),
('schema',          'Migrations Guide',            'docs/knowledge/schema/migrations-guide.md',              'How to write, run, and track schema migrations');
