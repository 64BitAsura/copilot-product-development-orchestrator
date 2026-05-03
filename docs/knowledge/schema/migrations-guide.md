# Schema Changes Guide

> How to document, plan, and track changes to the data model. This guide is **database-agnostic** — the process applies regardless of whether your project uses a relational database, document store, graph database, or another storage technology.
>
> The technology-specific mechanics (SQL `ALTER TABLE`, MongoDB `db.runCommand`, DynamoDB table updates, etc.) are the responsibility of the coding agent and live in the codebase, not in this guide.

---

## Guiding Principles

1. **Document first.** Update `schema.md` and `erd.md` before (or alongside) writing the implementation code.
2. **Every change is tracked.** All schema changes — additive or breaking — must have a corresponding change record in the `migrations/` folder.
3. **Changes are ordered and append-only.** Migration records are immutable once merged to the default branch. Mistakes are fixed with a new record, not by editing old ones.
4. **Changes are reversible.** Every migration record must describe how to undo the change.
5. **Breaking changes are called out explicitly.** Any change that removes or renames fields, changes types incompatibly, or alters cardinality is a breaking change and must be flagged.

---

## Change Record Location

```
docs/knowledge/schema/migrations/
```

---

## Naming Convention

```
YYYYMMDD_NNN_description.md
```

- `YYYYMMDD` — date of the change
- `NNN` — 3-digit sequential number within that day (001, 002, ...)
- `description` — short snake_case description of what the change does

**Examples:**
```
20250101_001_initial_schema.md
20250115_001_add_retry_count_to_pipeline_runs.md
20250120_001_add_git_sha_to_agent_profiles.md
20250120_002_add_full_text_search_on_inputs.md
```

---

## Change Record Structure

Every change record must contain:

```markdown
# Migration: YYYYMMDD_NNN_description

**Author**: <agent name or GitHub username>
**Date**: YYYY-MM-DD
**Breaking change**: yes | no
**Affected entities**: <comma-separated list>

## Description

<One paragraph explaining what this changes and why.>

## Forward Change

<Describe the data model change in plain language or pseudocode.
For relational DBs, this may include SQL DDL snippets.
For document stores, describe the new document shape.
For graph DBs, describe new nodes/edges/properties.>

### Entities added
- [EntityName]: [brief description]

### Fields added
- [EntityName].[field_name] ([type], required/optional): [description]

### Fields removed
- [EntityName].[old_field_name]: [reason for removal]

### Relationships changed
- [EntityA] → [EntityB]: [describe cardinality or deletion behaviour change]

## Rollback

<Describe how to reverse this change.
What data would be lost or need to be migrated back?>

## Checklist

- [ ] `schema.md` updated
- [ ] `erd.md` updated
- [ ] Implementation code written and tested
- [ ] `domain-model.md` updated (if entities added/removed/renamed)
- [ ] `past-decisions.md` updated (if breaking change)
- [ ] API documentation updated (if change affects public API shape)
```

---

## Types of Schema Change

### Add a new entity

- Add the entity block to `schema.md`.
- Add the entity to `erd.md` with its fields and relationships.
- Create a migration record documenting the new entity.
- Implement in the codebase (create table / collection / node type).

### Add a field to an existing entity

- Add the field to the entity block in `schema.md`.
- Update `erd.md` if the field affects relationships.
- Create a migration record.
- If the field is **required** and the entity already has records, provide a default value or a backfill step.

### Remove a field (two-phase, zero-downtime)

**Phase 1 — Deprecate:** Mark the field as deprecated in `schema.md`. Stop writing to it in new code. Read from both old and new fields.

**Phase 2 — Remove:** Once all reads/writes to the old field are gone, create a migration record to formally remove it and drop it from the storage layer.

### Rename a field

Renames are always breaking. Use the two-phase remove approach:
1. Add the new field, dual-write to both fields.
2. Migrate reads to the new field.
3. Remove the old field via Phase 2 above.

### Change a field's type

Changing types is almost always breaking. Use a new field and backfill, then remove the old field.

### Change relationship cardinality

- Update `schema.md` and `erd.md`.
- Assess whether existing data needs migration.
- Create a migration record describing the data migration strategy.

---

## Tracking Applied Changes

Use the `migrations/` folder as the single source of truth for what has been applied. Each file in the folder represents one applied (or planned) change.

For codebases that use a migration runner (e.g., Flyway, Liquibase, Atlas, Alembic, Prisma Migrate, Mongoose-migrate), the migration record files in this folder serve as the documentation layer. The actual runnable migration files live in the codebase alongside the application code.

---

## Migration Checklist

Before merging a schema change:

- [ ] Change record file follows `YYYYMMDD_NNN_description.md` naming
- [ ] Record includes author, date, description, affected entities, and breaking-change flag
- [ ] Forward change is fully described
- [ ] Rollback / reversal strategy is described
- [ ] `schema.md` is updated
- [ ] `erd.md` is updated
- [ ] `domain-model.md` is updated (if entities added, removed, or renamed)
- [ ] `past-decisions.md` updated (if breaking or architecturally significant)
- [ ] If breaking: `documentation-agent` is notified to update API docs and changelog
