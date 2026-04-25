# Schema

> This folder contains the base database schema for the product, naming conventions, migration guidelines, and entity relationship documentation. All agents that touch data (planning, coding) read from this folder.

---

## Folder Contents

| File | Purpose |
|------|---------|
| `README.md` | This file — index and usage guide |
| `base-schema.sql` | Complete base schema in SQL (PostgreSQL-compatible) |
| `schema-conventions.md` | Naming conventions, patterns, and rules for schema design |
| `erd.md` | Entity Relationship Diagram in Mermaid format |
| `migrations-guide.md` | How to write, run, and track schema migrations |

---

## Schema Design Principles

1. **Domain model is the source of truth.** `base-schema.sql` must reflect `docs/knowledge/blueprint/domain-model.md`. Any change to one must update the other.
2. **UUIDs for all primary keys.** No sequential integer IDs in public-facing tables (enumeration risk).
3. **Timestamps on every table.** `created_at` is always `NOT NULL`; `updated_at` is nullable (only on mutable tables).
4. **Soft deletes where history matters.** Use `deleted_at` timestamp instead of `DELETE` for audit-trail entities.
5. **Enum types are defined in the DB.** Use `CREATE TYPE ... AS ENUM` for type safety.
6. **Indexes declared with tables.** Every foreign key and every commonly-queried field gets an index.
7. **No stored procedures.** Business logic lives in the application layer, not the database.
8. **Row-level security for multi-tenant data.** If data is scoped per user or organization, enforce at the DB level with RLS policies.

---

## Schema Lifecycle

When the planning agent identifies a data model change, it must:
1. Update `base-schema.sql` with the new/modified tables
2. Update `erd.md` to reflect the changes
3. Create a new migration file (`docs/knowledge/schema/migrations/YYYYMMDD_N_description.sql`)
4. Update `docs/knowledge/blueprint/domain-model.md` to match
5. Note the change in `docs/knowledge/requirements/past-decisions.md` if it is a breaking change

---

## Quick Reference: Key Tables

| Table | Purpose |
|-------|---------|
| `inputs` | Raw inputs (issues, prompts) received by the orchestrator |
| `reference_inputs` | Supplementary references attached to an input |
| `sessions` | Long-lived product development contexts |
| `pipeline_runs` | Single end-to-end pipeline execution |
| `stages` | Individual agent execution within a pipeline run |
| `stage_outputs` | Versioned output documents per stage |
| `agent_profiles` | Registered custom agent definitions |
| `knowledge_documents` | Inventory of knowledge harness documents |
| `user_approvals` | Audit log of user approval decisions |
