# Schema

> This folder contains the data model description, naming conventions, schema change guidelines, and entity relationship documentation. All agents that touch data (planning, coding) read from this folder.
>
> The schema documentation is **database-agnostic** — it describes entities, fields, and relationships in logical terms. The choice of database technology (relational, document, graph, columnar, time-series, or a mix) is made per project and recorded in `docs/knowledge/tech-stack.md`.

---

## Folder Contents

| File | Purpose |
|------|---------|
| `README.md` | This file — index and usage guide |
| `schema.md` | Data entities, fields, relationships, and access patterns |
| `schema-conventions.md` | Naming conventions, patterns, and rules for data model design |
| `erd.md` | Entity Relationship Diagram in Mermaid format |
| `migrations-guide.md` | How to document, track, and manage schema changes |

---

## Schema Design Principles

1. **Domain model is the source of truth.** `schema.md` must reflect `docs/knowledge/blueprint/domain-model.md`. Any change to one must update the other.
2. **Technology-agnostic descriptions.** Field types in `schema.md` and `erd.md` use logical types (`uuid`, `string`, `timestamp`, `enum`, `reference`) — not database-specific types.
3. **UUIDs for identity on public-facing entities.** Sequential IDs are acceptable for internal entities not exposed in APIs or URLs.
4. **Timestamps on every entity.** `created_at` is always required; `updated_at` is nullable (only on mutable entities).
5. **Soft deletes where history matters.** Use a `deleted_at` timestamp marker instead of hard deletes for audit-trail entities.
6. **Explicit relationship cardinality and deletion behaviour.** Every reference between entities must document what happens when the referenced entity is deleted (cascade, restrict, or nullify).
7. **Business logic in the application layer.** Computed values, complex rules, and workflows belong in application code, not in database procedures or triggers.
8. **Scope enforcement for multi-tenant data.** If data is scoped per user or organisation, enforce access at the application or database level.

---

## Schema Lifecycle

When the planning agent identifies a data model change, it must:
1. Update `schema.md` with the new/modified entities
2. Update `erd.md` to reflect the changes
3. Create a new change record (`docs/knowledge/schema/migrations/YYYYMMDD_NNN_description.md`)
4. Update `docs/knowledge/blueprint/domain-model.md` to match
5. Note the change in `docs/knowledge/requirements/past-decisions.md` if it is a breaking change

---

## Quick Reference: Starter Entities

The initial `schema.md` includes:

| Entity | Purpose |
|--------|---------|
| `users` | People who have registered with your product |
| `organizations` | Teams or accounts that group users and resources |
| `organization_members` | Junction: which users belong to which organizations and in what role |

Replace or extend these entities to match your product's domain model.
