# Schema Conventions

> Rules every agent and developer must follow when modifying the data model. These conventions are **database-agnostic** — they apply whether the project uses a relational database, document store, graph database, columnar store, time-series database, or a combination.
>
> Technology-specific implementation details (SQL DDL, MongoDB schema validators, etc.) live in the codebase, not here.

---

## 1. Naming

### Entities / Collections / Tables
- **Plural, snake_case**: `pipeline_runs`, `stage_outputs`, `user_approvals`
- Avoid abbreviations: `user_approvals` not `usr_apprv`
- Junction / relationship entities: `<entity_a>_<entity_b>` alphabetically — e.g., `agents_tools` not `tools_agents`

### Fields / Attributes / Properties
- **Singular, snake_case**: `pipeline_run_id`, `created_at`, `raw_content`
- Identity field: always `id` (not `<entity>_id` on the entity itself)
- Reference fields (foreign keys / foreign IDs): `<referenced_entity_singular>_id` — e.g., `stage_id`, `session_id`
- Boolean fields: prefix with `is_` or `has_` — e.g., `is_active`, `has_been_notified`
- Timestamp fields: suffix `_at` — e.g., `created_at`, `approved_at`, `deleted_at`
- Enum fields: no suffix, named for what they represent — e.g., `status`, `type`, `decision`

### Enum / Categorical Values
- **Lowercase, snake_case** strings — e.g., `'in_progress'`, `'github_issue'`

---

## 2. Identity Fields

- Every entity must have an `id` field as its unique identifier.
- Prefer **UUIDs** (v4 or equivalent random) for public-facing entities — they prevent enumeration and are safe to expose in URLs and APIs.
- Sequential integers are acceptable for internal, non-exposed entities where enumeration is not a concern.
- Composite keys are acceptable for pure junction / relationship entities where they avoid redundant data.

---

## 3. Timestamps

- Every entity must have `created_at` (required, set on insert, never updated).
- Mutable entities must also have `updated_at` (nullable, set on every update by application code).
- Entities requiring audit trails or soft-delete behaviour must have `deleted_at` (nullable; `null` = record is active).

```
created_at  timestamp  required   Set once at creation
updated_at  timestamp  optional   Set on every mutation (mutable entities only)
deleted_at  timestamp  optional   Soft-delete marker (audit-trail entities only)
```

---

## 4. Nullability

- Default to **required** (not null) — make a field optional only when `null` has a distinct semantic meaning.
- `null` means "unknown or not yet set", not "empty string" or "zero".
- Do not use empty string `""` as a sentinel for "no value" — use `null`.
- Lists / arrays: default to an **empty collection**, not `null`, when a list is always present but may be empty.

---

## 5. Soft Deletes

- Use soft deletes (`deleted_at` timestamp) for any entity where history matters or hard deletes would cause orphaned references.
- Hard deletes are acceptable for ephemeral / disposable data where there is no audit requirement.
- Queries on soft-deleted entities should filter `deleted_at IS NULL` (or equivalent) by default.

---

## 6. References Between Entities

- Declare the **cardinality** and **deletion behaviour** of every reference:
  - **Cascade**: deleting the parent removes child records (use when children have no meaning without the parent).
  - **Restrict / protect**: deletion of the parent is blocked while children exist.
  - **Nullify**: child reference is set to `null` when the parent is deleted (child remains valid without the parent).
- Document this in `schema.md` and `erd.md`.

---

## 7. Enumerations

- Use an **enumeration type** when the set of values is small, well-defined, and unlikely to change frequently — it gives type safety at the application or database level.
- Use a **plain string with validation** when values may be extended without a schema migration or when the set is user-extensible.

---

## 8. Multi-Tenant / Scoped Data

- If an entity's records are scoped to a specific user or organisation, the scoping field must be:
  - Required (not null).
  - Indexed / used as a partition key for efficient scoped queries.
  - Enforced by the application or database access-control layer.

---

## 9. Schema Change Rules

1. **Document every change** in `schema.md` and `erd.md` before or alongside the implementation.
2. **Never rename a field** without a migration strategy (add new → migrate data → remove old).
3. **Never change a field's type** destructively — add a new field and backfill.
4. **Never remove an entity or field** without confirming no live code references it.
5. **Adding a required field to an existing entity** requires a default value or a data-migration step.
6. **Record all breaking changes** in `docs/knowledge/requirements/past-decisions.md`.
7. **Update `erd.md`** whenever an entity or relationship changes.
8. **Update `domain-model.md`** whenever entities are added, removed, or significantly restructured.
