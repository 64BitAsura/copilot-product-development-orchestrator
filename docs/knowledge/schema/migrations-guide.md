# Migrations Guide

> How to write, name, apply, and track database migrations. All schema changes go through migrations — no direct schema edits in production.

---

## Guiding Principles

1. **Every schema change is a migration.** No DDL runs directly in production outside of a migration file.
2. **Migrations are ordered.** Each migration builds on the previous. Never reorder.
3. **Migrations are append-only.** Once merged to the default branch, a migration is immutable. Fix mistakes with a new migration.
4. **Migrations are idempotent where possible.** Use `IF NOT EXISTS`, `IF EXISTS`, `DO $$ ... END $$` guards.
5. **Rollback migrations are written alongside forward migrations.** Every change must be reversible.

---

## Migration File Format

### Location
```
docs/knowledge/schema/migrations/
```

### Naming Convention
```
YYYYMMDD_NNN_description.sql
```

- `YYYYMMDD` — date of the migration
- `NNN` — 3-digit sequential number within that day (001, 002, ...)
- `description` — short snake_case description of what the migration does

**Examples:**
```
20250101_001_initial_schema.sql
20250115_001_add_security_loop_count_to_pipeline_runs.sql
20250120_001_add_git_sha_to_agent_profiles.sql
20250120_002_add_full_text_search_index_on_inputs.sql
```

---

## Migration File Structure

Every migration file must contain:

```sql
-- =============================================================================
-- Migration: YYYYMMDD_NNN_description
-- Author: <agent name or GitHub username>
-- Date: YYYY-MM-DD
-- Description: <one paragraph explaining what this changes and why>
-- Affected tables: <comma-separated list>
-- Breaking change: yes | no
-- =============================================================================

-- =====================
-- FORWARD MIGRATION
-- =====================

BEGIN;

-- [DDL statements]

COMMIT;


-- =====================
-- ROLLBACK MIGRATION
-- =====================
-- To roll back, run everything below this line.

BEGIN;

-- [Inverse DDL statements]

COMMIT;
```

---

## Migration Types and Templates

### Add a column (non-nullable with default)

```sql
-- FORWARD
BEGIN;
ALTER TABLE pipeline_runs
    ADD COLUMN IF NOT EXISTS security_loop_count INTEGER NOT NULL DEFAULT 0;
COMMIT;

-- ROLLBACK
BEGIN;
ALTER TABLE pipeline_runs DROP COLUMN IF EXISTS security_loop_count;
COMMIT;
```

### Add a nullable column

```sql
-- FORWARD
BEGIN;
ALTER TABLE stages
    ADD COLUMN IF NOT EXISTS reviewer_notes TEXT;
COMMIT;

-- ROLLBACK
BEGIN;
ALTER TABLE stages DROP COLUMN IF EXISTS reviewer_notes;
COMMIT;
```

### Add a NOT NULL column to a live table (two-phase)

**Phase 1 — Add as nullable, backfill, then constrain:**

```sql
-- FORWARD
BEGIN;
-- Step 1: add as nullable
ALTER TABLE inputs ADD COLUMN IF NOT EXISTS checksum TEXT;
-- Step 2: backfill
UPDATE inputs SET checksum = md5(raw_content) WHERE checksum IS NULL;
-- Step 3: add NOT NULL constraint
ALTER TABLE inputs ALTER COLUMN checksum SET NOT NULL;
COMMIT;

-- ROLLBACK
BEGIN;
ALTER TABLE inputs DROP COLUMN IF EXISTS checksum;
COMMIT;
```

### Add a new table

```sql
-- FORWARD
BEGIN;
CREATE TABLE IF NOT EXISTS pipeline_run_tags (
    id              UUID        NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    pipeline_run_id UUID        NOT NULL REFERENCES pipeline_runs (id) ON DELETE CASCADE,
    tag             TEXT        NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_pipeline_run_tags_pipeline_run_id ON pipeline_run_tags (pipeline_run_id);
COMMIT;

-- ROLLBACK
BEGIN;
DROP TABLE IF EXISTS pipeline_run_tags;
COMMIT;
```

### Add an index

> `CONCURRENTLY` avoids table locks on large tables but **cannot run inside a transaction block**. Omit `BEGIN`/`COMMIT` for these migrations.

```sql
-- FORWARD (no transaction — CONCURRENTLY is incompatible with explicit transactions)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_your_table_column
    ON your_table (column_name DESC);

-- ROLLBACK
DROP INDEX CONCURRENTLY IF EXISTS idx_your_table_column;
```

For small tables or when downtime is acceptable, a regular (non-concurrent) index inside a transaction is simpler:

```sql
-- FORWARD
BEGIN;
CREATE INDEX IF NOT EXISTS idx_your_table_column ON your_table (column_name);
COMMIT;

-- ROLLBACK
BEGIN;
DROP INDEX IF EXISTS idx_your_table_column;
COMMIT;
```

### Extend an enum

```sql
-- FORWARD
BEGIN;
ALTER TYPE stage_type ADD VALUE IF NOT EXISTS 'review';
COMMIT;

-- ROLLBACK
-- Note: PostgreSQL does not support removing enum values directly.
-- To roll back: create a new type without the value, migrate columns, drop old type.
-- Document this complexity in the migration header.
```

### Rename a column (two-phase, zero-downtime)

**Phase 1 — Add new column, dual-write:**
```sql
BEGIN;
ALTER TABLE stages ADD COLUMN IF NOT EXISTS agent_identifier TEXT;
UPDATE stages SET agent_identifier = agent_name WHERE agent_identifier IS NULL;
COMMIT;
```

**Phase 2 — Drop old column (after all code uses new column):**
```sql
BEGIN;
ALTER TABLE stages ALTER COLUMN agent_identifier SET NOT NULL;
ALTER TABLE stages DROP COLUMN IF EXISTS agent_name;
COMMIT;
```

---

## Tracking Applied Migrations

Use a `schema_migrations` table to track which migrations have been applied:

```sql
CREATE TABLE IF NOT EXISTS schema_migrations (
    version     TEXT        NOT NULL PRIMARY KEY,   -- e.g. "20250101_001"
    applied_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

After running a migration, insert its version:
```sql
INSERT INTO schema_migrations (version) VALUES ('20250101_001')
ON CONFLICT (version) DO NOTHING;
```

---

## Running Migrations

### Development
```bash
psql -d $DATABASE_URL -f docs/knowledge/schema/migrations/<filename>.sql
```

### CI (automated)
```bash
# Run all unapplied migrations in order (only YYYYMMDD_NNN_* files)
for f in $(ls docs/knowledge/schema/migrations/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_*.sql 2>/dev/null | sort); do
    version=$(basename "$f" .sql | grep -oE '^[0-9]{8}_[0-9]+')
    applied=$(psql -d $DATABASE_URL -tAc "SELECT 1 FROM schema_migrations WHERE version='$version'")
    if [ -z "$applied" ]; then
        echo "Applying $f..."
        psql -d $DATABASE_URL -f "$f"
    fi
done
```

---

## Migration Checklist

Before merging a migration:

- [ ] File name follows `YYYYMMDD_NNN_description.sql` convention
- [ ] Header includes author, date, description, affected tables, breaking change flag
- [ ] Forward migration is wrapped in `BEGIN` / `COMMIT`
- [ ] Rollback migration is included
- [ ] `IF NOT EXISTS` / `IF EXISTS` guards are used where applicable
- [ ] New FK columns have corresponding indexes
- [ ] `erd.md` is updated
- [ ] `domain-model.md` is updated if entities changed
- [ ] `past-decisions.md` is updated if this is a breaking or significant change
- [ ] If breaking: `documentation-agent` is notified to update API docs and changelog
