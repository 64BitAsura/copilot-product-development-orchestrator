# Schema Conventions

> Rules every agent and developer must follow when modifying the database schema. Consistency here prevents bugs, security issues, and performance problems.

---

## 1. Naming

### Tables
- **Plural, snake_case**: `pipeline_runs`, `stage_outputs`, `user_approvals`
- Avoid abbreviations: `user_approvals` not `usr_apprv`
- Junction tables: `<table_a>_<table_b>` alphabetically — e.g., `agents_tools` not `tools_agents`

### Columns
- **Singular, snake_case**: `pipeline_run_id`, `created_at`, `raw_content`
- Primary key: always `id` (not `<table>_id`)
- Foreign keys: `<referenced_table_singular>_id` — e.g., `stage_id`, `session_id`
- Boolean columns: prefix with `is_` or `has_` — e.g., `is_active`, `has_been_notified`
- Timestamp columns: suffix `_at` — e.g., `created_at`, `approved_at`, `deleted_at`
- Enum columns: no suffix, named for what they represent — e.g., `status`, `type`, `decision`

### Enum Types
- **Singular, snake_case**: `stage_type`, `session_status`, `approval_decision`
- Values: **lowercase, snake_case** strings — e.g., `'in_progress'`, `'github_issue'`

### Indexes
- Format: `idx_<table>_<column(s)>` — e.g., `idx_stages_pipeline_run_id`
- Unique indexes: `uq_<table>_<columns>` — e.g., `uq_stage_outputs_iteration`

### Constraints
- Check constraints: `chk_<table>_<description>` — e.g., `chk_pipeline_runs_loop_count_non_negative`
- Foreign key constraints: auto-named by PostgreSQL (do not override)

---

## 2. Primary Keys

- All primary keys must be `UUID NOT NULL DEFAULT gen_random_uuid()`
- Never use `SERIAL` or `BIGSERIAL` for public-facing entities (enumeration risk)
- `gen_random_uuid()` requires the `pgcrypto` extension (declared in `base-schema.sql`)

```sql
-- ✅ correct
id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY

-- ❌ wrong
id SERIAL PRIMARY KEY
id BIGINT PRIMARY KEY
```

---

## 3. Timestamps

- Every table must have `created_at TIMESTAMPTZ NOT NULL DEFAULT now()`
- Mutable tables (rows can be updated) must also have `updated_at TIMESTAMPTZ`
- `updated_at` is set via application code or trigger — not `DEFAULT now()`
- Soft-delete tables must have `deleted_at TIMESTAMPTZ` (nullable; `NULL` = not deleted)

```sql
-- Standard timestamp block for mutable entities
created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
updated_at  TIMESTAMPTZ
```

---

## 4. Nullable vs NOT NULL

- Default to `NOT NULL` — make a column nullable only when `NULL` has distinct semantic meaning.
- `NULL` means "unknown or not yet set", not "empty string" or "zero".
- Never use empty string `''` as a sentinel for "no value" — use `NULL`.
- Arrays: use empty array `'{}'` as default, not `NULL`, for list columns.

---

## 5. Text vs VARCHAR

- Use `TEXT` for all variable-length strings — no `VARCHAR(n)` unless enforcing a specific max.
- Length validation belongs in the application layer (or a `CHECK` constraint), not in column type.
- Use `CHECK (char_length(column) <= N)` when a strict max is required.

---

## 6. Indexes

**Always index:**
- Every foreign key column
- Every column used in `WHERE` clauses in frequent queries
- Every column used in `ORDER BY` for paginated queries

**Consider indexing:**
- Columns used in `JOIN` conditions (beyond FK)
- Columns in `GROUP BY` for aggregate queries
- Text columns searched with `LIKE 'prefix%'` (not `'%suffix'` — those won't use btree)
- Text columns searched with trigram similarity (use GIN + `pg_trgm`)

**Never index blindly:**
- Low-cardinality columns (boolean, small enums) rarely benefit from btree indexes
- Columns only written, never read in queries

---

## 7. Enum Types vs Text with Check Constraint

Use **enum types** (`CREATE TYPE ... AS ENUM`) when:
- The set of values is small and well-defined
- Values are not expected to change frequently
- Type safety at the DB level is valuable

Use **text with check constraint** when:
- Values may be added without a schema migration
- The set is dynamic or user-extensible

```sql
-- ✅ Use enum for well-defined finite sets
CREATE TYPE stage_type AS ENUM ('requirements', 'design', 'planning', ...);

-- ✅ Use text + CHECK for extensible sets
content_format TEXT NOT NULL CHECK (content_format IN ('markdown', 'json', 'html'))
```

---

## 8. Foreign Keys

- Always declare `ON DELETE` behavior explicitly:
  - `ON DELETE CASCADE` — when child rows have no meaning without the parent
  - `ON DELETE SET NULL` — when child rows are still valid without the parent
  - `ON DELETE RESTRICT` (default) — when deleting the parent should be blocked
- Always add an index on the FK column.

```sql
-- ✅ explicit cascade
stage_id UUID NOT NULL REFERENCES stages (id) ON DELETE CASCADE

-- ❌ missing ON DELETE — defaults to RESTRICT but intent is unclear
stage_id UUID REFERENCES stages (id)
```

---

## 9. Multi-Tenant / Scoped Data

If a table's rows are scoped to a specific user or repository, the scoping column must:
- Be `NOT NULL`
- Have an index
- Be included in Row-Level Security policies if multi-tenant isolation is required

```sql
-- Scope column example
repository TEXT NOT NULL  -- "owner/repo" scoping identifier
```

---

## 10. Schema Change Rules

1. **Never rename a column** without a two-phase migration (add new → migrate data → remove old).
2. **Never change a column's type** destructively — use a new column and backfill.
3. **Never drop a table** without confirming no live queries reference it.
4. **Adding a NOT NULL column to a live table** requires a default value or a backfill migration.
5. **All changes must have a corresponding migration file** in `docs/knowledge/schema/migrations/`.
6. **Update `erd.md`** whenever a table or relationship changes.
7. **Update `domain-model.md`** whenever entities are added, removed, or significantly changed.
